import 'dart:io';

import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/database/app_database.dart';
import '../../data/models/enums.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

abstract final class ExportService {
  // ---------------------------------------------------------------------------
  // XLSX
  // ---------------------------------------------------------------------------

  static Future<void> exportXlsx({
    required List<TransactionEntry> transactions,
    required List<CategoryEntry> categories,
    required List<AccountEntry> accounts,
  }) async {
    final catMap = {for (final c in categories) c.id: c.name};
    final accMap = {for (final a in accounts) a.id: a.name};

    final xl = Excel.createExcel();
    if (xl.sheets.containsKey('Sheet1')) xl.delete('Sheet1');

    // ── Shared styles ─────────────────────────────────────────────────────────

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0D9488'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final altBg = ExcelColor.fromHexString('#F0FDFA');

    // NumFormat.standard_3 = #,##0 → displays 1234567 as "1,234,567" in
    // Microsoft Excel, Google Sheets, LibreOffice, WPS, Edge Office Online.
    final amountGreen = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#26A69A'),
      bold: true,
      horizontalAlign: HorizontalAlign.Right,
      numberFormat: NumFormat.standard_3,
    );
    final amountRed = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#EF5350'),
      bold: true,
      horizontalAlign: HorizontalAlign.Right,
      numberFormat: NumFormat.standard_3,
    );
    final amountNeutral = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Right,
      numberFormat: NumFormat.standard_3,
    );
    final boldStyle = CellStyle(bold: true);

    // ── Helpers ───────────────────────────────────────────────────────────────

    void addHeader(Sheet sheet, int col, int row, String label) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = TextCellValue(label);
      cell.cellStyle = headerStyle;
    }

    void addCell(Sheet sheet, int col, int row, CellValue value,
        {CellStyle? style}) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = value;
      if (style != null) cell.cellStyle = style;
    }

    // ── Transactions sheet ────────────────────────────────────────────────────

    final txSheet = xl['Transactions'];
    txSheet.setColumnWidth(0, 14);  // Date
    txSheet.setColumnWidth(1, 9);   // Time
    txSheet.setColumnWidth(2, 12);  // Type
    txSheet.setColumnWidth(3, 28);  // Category
    txSheet.setColumnWidth(4, 28);  // Account
    txSheet.setColumnWidth(5, 22);  // Amount (TZS)
    txSheet.setColumnWidth(6, 44);  // Note

    const txHeaders = [
      'Date', 'Time', 'Type', 'Category', 'Account', 'Amount (TZS)', 'Note',
    ];
    for (int i = 0; i < txHeaders.length; i++) {
      addHeader(txSheet, i, 0, txHeaders[i]);
    }

    for (int r = 0; r < transactions.length; r++) {
      final t = transactions[r];
      final isIncome = t.type == TransactionType.income;
      final isAlt = r.isOdd;
      final base = isAlt ? CellStyle(backgroundColorHex: altBg) : null;

      addCell(txSheet, 0, r + 1, TextCellValue(DateFormatter.iso(t.date)),
          style: base);
      addCell(txSheet, 1, r + 1, TextCellValue(DateFormatter.time(t.date)),
          style: base);
      addCell(txSheet, 2, r + 1, TextCellValue(t.type.label), style: base);
      addCell(txSheet, 3, r + 1, TextCellValue(catMap[t.categoryId] ?? ''),
          style: base);
      addCell(txSheet, 4, r + 1, TextCellValue(accMap[t.accountId] ?? ''),
          style: base);
      addCell(txSheet, 5, r + 1, IntCellValue(t.amount.round()),
          style: isIncome ? amountGreen : amountRed);
      // WrapText so long notes expand the row instead of being cut off
      addCell(txSheet, 6, r + 1, TextCellValue(t.note ?? ''),
          style: isAlt
              ? CellStyle(
                  textWrapping: TextWrapping.WrapText,
                  backgroundColorHex: altBg)
              : CellStyle(textWrapping: TextWrapping.WrapText));
    }

    // ── Budget sheet ──────────────────────────────────────────────────────────

    final budgetSheet = xl['Budget'];
    budgetSheet.setColumnWidth(0, 28);  // Category
    budgetSheet.setColumnWidth(1, 14);  // Type
    budgetSheet.setColumnWidth(2, 26);  // Monthly Limit (TZS)
    budgetSheet.setColumnWidth(3, 28);  // This Month Spent (TZS)
    budgetSheet.setColumnWidth(4, 22);  // Remaining (TZS)
    budgetSheet.setColumnWidth(5, 16);  // Status

    const budgetHeaders = [
      'Category', 'Type', 'Monthly Limit (TZS)',
      'This Month Spent (TZS)', 'Remaining (TZS)', 'Status',
    ];
    for (int i = 0; i < budgetHeaders.length; i++) {
      addHeader(budgetSheet, i, 0, budgetHeaders[i]);
    }

    final now = DateTime.now();
    final Map<String, double> monthSpend = {};
    for (final t in transactions) {
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        monthSpend[t.categoryId] =
            (monthSpend[t.categoryId] ?? 0) + t.amount;
      }
    }

    for (int i = 0; i < categories.length; i++) {
      final c = categories[i];
      final spent = monthSpend[c.id] ?? 0;
      final hasLimit = c.monthlyLimit > 0;
      final remaining = hasLimit ? c.monthlyLimit - spent : 0.0;
      final isOver = hasLimit && spent > c.monthlyLimit;
      final isNear = hasLimit && !isOver && spent / c.monthlyLimit >= 0.8;
      final base = i.isOdd ? CellStyle(backgroundColorHex: altBg) : null;

      addCell(budgetSheet, 0, i + 1, TextCellValue(c.name), style: base);
      addCell(budgetSheet, 1, i + 1,
          TextCellValue(c.categoryType == 'income' ? 'Income' : 'Expense'),
          style: base);
      addCell(
          budgetSheet, 2, i + 1,
          hasLimit
              ? IntCellValue(c.monthlyLimit.round())
              : TextCellValue('No limit'),
          style: hasLimit ? amountNeutral : base);
      addCell(budgetSheet, 3, i + 1, IntCellValue(spent.round()),
          style: isOver ? amountRed : amountNeutral);
      addCell(
          budgetSheet, 4, i + 1,
          hasLimit ? IntCellValue(remaining.round()) : TextCellValue('-'),
          style: isOver ? amountRed : (hasLimit ? amountNeutral : base));

      final statusLabel = !hasLimit
          ? '-'
          : isOver
              ? 'Over Budget'
              : isNear
                  ? 'Near Limit'
                  : 'On Track';
      final statusStyle = !hasLimit
          ? (base ?? CellStyle())
          : isOver
              ? CellStyle(
                  fontColorHex: ExcelColor.fromHexString('#EF5350'),
                  bold: true)
              : isNear
                  ? CellStyle(
                      fontColorHex: ExcelColor.fromHexString('#F59E0B'),
                      bold: true)
                  : CellStyle(
                      fontColorHex: ExcelColor.fromHexString('#26A69A'),
                      bold: true);
      addCell(budgetSheet, 5, i + 1, TextCellValue(statusLabel),
          style: statusStyle);
    }

    // ── Summary sheet ─────────────────────────────────────────────────────────

    final sumSheet = xl['Summary'];
    sumSheet.setColumnWidth(0, 34);
    sumSheet.setColumnWidth(1, 26);

    addHeader(sumSheet, 0, 0, 'Metric');
    addHeader(sumSheet, 1, 0, 'Value (TZS)');

    double totalIncome = 0, totalExpense = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }
    final net = totalIncome - totalExpense;

    final summaryData = [
      ('Total Income', totalIncome, amountGreen),
      ('Total Expenses', totalExpense, amountRed),
      ('Net Balance', net, net >= 0 ? amountGreen : amountRed),
      ('Total Transactions', transactions.length.toDouble(), amountNeutral),
    ];
    for (int i = 0; i < summaryData.length; i++) {
      final (label, value, style) = summaryData[i];
      addCell(sumSheet, 0, i + 1, TextCellValue(label), style: boldStyle);
      addCell(sumSheet, 1, i + 1, IntCellValue(value.round()), style: style);
    }

    addHeader(sumSheet, 0, summaryData.length + 2, 'Account Name');
    addHeader(sumSheet, 1, summaryData.length + 2, 'Balance (TZS)');
    for (int i = 0; i < accounts.length; i++) {
      final a = accounts[i];
      final row = summaryData.length + 3 + i;
      addCell(sumSheet, 0, row, TextCellValue(a.name));
      addCell(sumSheet, 1, row, IntCellValue(a.balance.round()),
          style: a.balance >= 0 ? amountNeutral : amountRed);
    }

    final bytes = xl.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/nuruwallet_export.xlsx');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }

  // ---------------------------------------------------------------------------
  // PDF
  // ---------------------------------------------------------------------------

  static Future<void> exportPdf({
    required List<TransactionEntry> transactions,
    required List<CategoryEntry> categories,
    required List<AccountEntry> accounts,
  }) async {
    final catMap = {for (final c in categories) c.id: c.name};
    final accMap = {for (final a in accounts) a.id: a.name};

    double totalIncome = 0, totalExpense = 0;
    final Map<String, double> catSpend = {};
    final now = DateTime.now();
    final Map<String, double> monthSpend = {};

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
        final name = catMap[t.categoryId] ?? 'Other';
        catSpend[name] = (catSpend[name] ?? 0) + t.amount;
      }
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        monthSpend[t.categoryId] =
            (monthSpend[t.categoryId] ?? 0) + t.amount;
      }
    }

    final net = totalIncome - totalExpense;
    final sortedCats = catSpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final budgetedCats =
        categories.where((c) => c.monthlyLimit > 0).toList();

    // Colours
    const teal = PdfColor(0.051, 0.596, 0.533);
    const incomeGreen = PdfColor(0.149, 0.651, 0.604);
    const expenseRed = PdfColor(0.937, 0.325, 0.314);
    const warningOrange = PdfColor(1.0, 0.596, 0.0);
    const altRow = PdfColor(0.941, 0.992, 0.980);

    final doc = pw.Document();

    // ── Pages 1..n  Portrait — Summary / Analytics / Budget / Accounts ─────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        header: (_) => _pdfPageHeader(
          'NuruWallet Report',
          'Generated: ${DateFormatter.full(DateTime.now())}',
          teal,
        ),
        build: (_) => [
          // Summary boxes
          pw.Row(children: [
            _summaryBox(
                'Income', CurrencyFormatter.format(totalIncome), incomeGreen),
            pw.SizedBox(width: 8),
            _summaryBox(
                'Expenses', CurrencyFormatter.format(totalExpense), expenseRed),
            pw.SizedBox(width: 8),
            _summaryBox(
              net >= 0 ? 'Net Income' : 'Net Loss',
              CurrencyFormatter.format(net.abs()),
              net >= 0 ? incomeGreen : expenseRed,
            ),
          ]),
          pw.SizedBox(height: 18),

          // Analytics
          _sectionTitle('Analytics'),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Income vs Expenses',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                _pdfBarRow('Income', totalIncome,
                    totalIncome + totalExpense, incomeGreen),
                pw.SizedBox(height: 6),
                _pdfBarRow('Expenses', totalExpense,
                    totalIncome + totalExpense, expenseRed),
                if (sortedCats.isNotEmpty) ...[
                  pw.SizedBox(height: 14),
                  pw.Text('Top Spending Categories',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700)),
                  pw.SizedBox(height: 8),
                  for (final e in sortedCats.take(5))
                    _pdfCategoryRow(e.key, e.value, totalExpense),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // Budget overview
          if (budgetedCats.isNotEmpty) ...[
            _sectionTitle(
                'Budget Overview — ${DateFormatter.monthYear(now)}'),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.grey300, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(3.0),
                1: pw.FlexColumnWidth(2.5),
                2: pw.FlexColumnWidth(2.5),
                3: pw.FlexColumnWidth(2.5),
                4: pw.FlexColumnWidth(1.5),
              },
              children: [
                _headerRow(
                    ['Category', 'Limit', 'Spent', 'Remaining', 'Status'],
                    teal),
                for (int i = 0; i < budgetedCats.length; i++)
                  _budgetRow(
                    budgetedCats[i],
                    monthSpend[budgetedCats[i].id] ?? 0,
                    i.isOdd ? altRow : PdfColors.white,
                    incomeGreen,
                    expenseRed,
                    warningOrange,
                  ),
              ],
            ),
            pw.SizedBox(height: 18),
          ],

          // Accounts
          _sectionTitle('Accounts'),
          pw.SizedBox(height: 6),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(3.0),
              1: pw.FlexColumnWidth(2.0),
              2: pw.FlexColumnWidth(2.5),
            },
            children: [
              _headerRow(['Account Name', 'Type', 'Balance'], teal),
              for (int i = 0; i < accounts.length; i++) ...[
                _dataRow([
                  accounts[i].name,
                  accounts[i].type.label,
                  CurrencyFormatter.format(accounts[i].balance),
                ], i.isOdd),
              ],
            ],
          ),
        ],
      ),
    );

    // ── Transactions pages: Landscape for wide table ────────────────────────
    // Landscape A4 gives ~770 pt usable width vs ~523 pt portrait — each
    // column gets ~47 % more space, making long text fully readable.
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        header: (_) => _pdfPageHeader(
          'All Transactions (${transactions.length})',
          DateFormatter.monthYear(now),
          teal,
        ),
        build: (_) => [
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(3.2),  // Date & Time
              1: pw.FlexColumnWidth(1.2),  // Type
              2: pw.FlexColumnWidth(2.6),  // Category
              3: pw.FlexColumnWidth(2.4),  // Account
              4: pw.FlexColumnWidth(2.8),  // Amount
              5: pw.FlexColumnWidth(2.8),  // Note
            },
            children: [
              _headerRow(
                  ['Date & Time', 'Type', 'Category',
                      'Account', 'Amount', 'Note'],
                  teal),
              for (int i = 0; i < transactions.length; i++)
                _txRow(
                  transactions[i],
                  catMap,
                  accMap,
                  i.isOdd ? altRow : PdfColors.white,
                  incomeGreen,
                  expenseRed,
                ),
            ],
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/nuruwallet_report.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }

  // ---------------------------------------------------------------------------
  // PDF layout helpers
  // ---------------------------------------------------------------------------

  static pw.Widget _pdfPageHeader(
      String title, String subtitle, PdfColor teal) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: teal),
                ),
              ),
              pw.Text(
                subtitle,
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Divider(color: teal, thickness: 1.5),
          pw.SizedBox(height: 4),
        ],
      );

  static pw.Widget _sectionTitle(String text) => pw.Text(
        text,
        style:
            pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      );

  static pw.Widget _summaryBox(
          String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color, width: 0.8),
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
              pw.SizedBox(height: 3),
              pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      );

  // ---------------------------------------------------------------------------
  // Analytics bar helpers
  // ---------------------------------------------------------------------------

  static pw.Widget _pdfBarRow(
      String label, double value, double total, PdfColor color) {
    final frac = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    final filled = ((frac * 100).round()).clamp(1, 99).toInt();
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 65,
          child: pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey800)),
        ),
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: filled,
                child: pw.Container(height: 14, color: color),
              ),
              pw.Expanded(
                flex: 100 - filled,
                child: pw.Container(height: 14, color: PdfColors.grey200),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            CurrencyFormatter.format(value),
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: color),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static pw.Widget _pdfCategoryRow(
      String name, double value, double totalExpense) {
    final pct = totalExpense > 0 ? (value / totalExpense * 100) : 0.0;
    final filled = (pct.round()).clamp(1, 99).toInt();
    const barColor = PdfColor(0.937, 0.325, 0.314);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(name,
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey800)),
          ),
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: filled,
                  child: pw.Container(height: 9, color: barColor),
                ),
                pw.Expanded(
                  flex: 100 - filled,
                  child: pw.Container(
                      height: 9, color: PdfColors.grey200),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              '${pct.toStringAsFixed(1)}%  ${CurrencyFormatter.format(value)}',
              style: const pw.TextStyle(
                  fontSize: 8, color: PdfColors.grey700),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PDF table helpers
  // ---------------------------------------------------------------------------

  static pw.TableRow _headerRow(List<String> cells, PdfColor bg) =>
      pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 7, vertical: 5),
                  child: pw.Text(c,
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                ))
            .toList(),
      );

  static pw.TableRow _dataRow(List<String> cells, bool alt) =>
      pw.TableRow(
        decoration: alt
            ? const pw.BoxDecoration(
                color: PdfColor(0.941, 0.992, 0.980))
            : null,
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 7, vertical: 4),
                  child: pw.Text(c,
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                      style: const pw.TextStyle(fontSize: 9)),
                ))
            .toList(),
      );

  static pw.TableRow _budgetRow(
    CategoryEntry cat,
    double spent,
    PdfColor rowColor,
    PdfColor okColor,
    PdfColor overColor,
    PdfColor warnColor,
  ) {
    final hasLimit = cat.monthlyLimit > 0;
    final isOver = hasLimit && spent > cat.monthlyLimit;
    final pct = hasLimit ? spent / cat.monthlyLimit : 0.0;
    final statusColor =
        isOver ? overColor : pct >= 0.8 ? warnColor : okColor;

    pw.Widget cell(String text,
            {PdfColor? color, bool bold = false, int maxLines = 1}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(
              horizontal: 7, vertical: 4),
          child: pw.Text(text,
              maxLines: maxLines,
              overflow: pw.TextOverflow.clip,
              style: pw.TextStyle(
                  fontSize: 9,
                  color: color ?? PdfColors.black,
                  fontWeight: bold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
        );

    final remaining = hasLimit ? cat.monthlyLimit - spent : 0.0;
    final status = !hasLimit
        ? '-'
        : isOver
            ? 'Over Budget'
            : pct >= 0.8
                ? 'Near Limit'
                : 'On Track';

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: rowColor),
      children: [
        cell(cat.name),
        cell(hasLimit
            ? CurrencyFormatter.format(cat.monthlyLimit)
            : 'No limit'),
        cell(CurrencyFormatter.format(spent)),
        cell(
            hasLimit ? CurrencyFormatter.format(remaining.abs()) : '-',
            color: isOver ? overColor : null),
        cell(status, color: statusColor, bold: true),
      ],
    );
  }

  static pw.TableRow _txRow(
    TransactionEntry t,
    Map<String, String> catMap,
    Map<String, String> accMap,
    PdfColor rowColor,
    PdfColor incomeColor,
    PdfColor expenseColor,
  ) {
    final isIncome = t.type == TransactionType.income;

    pw.Widget cell(String text,
            {PdfColor? color, int maxLines = 1}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(
              horizontal: 7, vertical: 4),
          child: pw.Text(text,
              maxLines: maxLines,
              overflow: pw.TextOverflow.clip,
              style: pw.TextStyle(
                  fontSize: 9, color: color ?? PdfColors.black)),
        );

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: rowColor),
      children: [
        cell(DateFormatter.dateTimeFull(t.date)),
        cell(t.type.label,
            color: isIncome ? incomeColor : expenseColor),
        cell(catMap[t.categoryId] ?? ''),
        cell(accMap[t.accountId] ?? ''),
        cell(CurrencyFormatter.format(t.amount),
            color: isIncome ? incomeColor : expenseColor),
        cell(t.note ?? '', maxLines: 2),
      ],
    );
  }

}
