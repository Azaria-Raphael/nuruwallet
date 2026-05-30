import 'dart:io';

import 'package:excel/excel.dart';
import 'package:open_file_plus/open_file_plus.dart';
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

    // ── Transactions sheet ──────────────────────────────────────────────────
    final txSheet = xl['Transactions'];
    if (xl.sheets.containsKey('Sheet1')) xl.delete('Sheet1');

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0D9488'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final headers = [
      'Date', 'Time', 'Type', 'Category', 'Account', 'Amount (TZS)', 'Note'
    ];
    for (int i = 0; i < headers.length; i++) {
      final cell = txSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    final altStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#F0FDFA'),
    );

    for (int r = 0; r < transactions.length; r++) {
      final t = transactions[r];
      final values = <CellValue>[
        TextCellValue(DateFormatter.iso(t.date)),
        TextCellValue(DateFormatter.time(t.date)),
        TextCellValue(t.type.label),
        TextCellValue(catMap[t.categoryId] ?? ''),
        TextCellValue(accMap[t.accountId] ?? ''),
        DoubleCellValue(t.amount),
        TextCellValue(t.note ?? ''),
      ];
      for (int c = 0; c < values.length; c++) {
        final cell = txSheet.cell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
        cell.value = values[c];
        if (r.isOdd) cell.cellStyle = altStyle;
      }
    }

    // ── Summary sheet ───────────────────────────────────────────────────────
    final sumSheet = xl['Summary'];

    final sumHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0D9488'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    void addHeader(int col, int row, String label) {
      final cell = sumSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = TextCellValue(label);
      cell.cellStyle = sumHeaderStyle;
    }

    addHeader(0, 0, 'Metric');
    addHeader(1, 0, 'Value (TZS)');

    double totalIncome = 0, totalExpense = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    final summaryRows = [
      ('Total Income', totalIncome),
      ('Total Expenses', totalExpense),
      ('Net Balance', totalIncome - totalExpense),
      ('Total Transactions', transactions.length.toDouble()),
    ];
    for (int i = 0; i < summaryRows.length; i++) {
      final (label, value) = summaryRows[i];
      sumSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(label);
      sumSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = DoubleCellValue(value);
    }

    addHeader(0, summaryRows.length + 2, 'Account');
    addHeader(1, summaryRows.length + 2, 'Balance (TZS)');
    for (int i = 0; i < accounts.length; i++) {
      final a = accounts[i];
      final row = summaryRows.length + 3 + i;
      sumSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(a.name);
      sumSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = DoubleCellValue(a.balance);
    }

    final bytes = xl.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/nuruwallet_export.xlsx');
    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);
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

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
        final name = catMap[t.categoryId] ?? 'Other';
        catSpend[name] = (catSpend[name] ?? 0) + t.amount;
      }
    }
    final net = totalIncome - totalExpense;
    final sortedCats = catSpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Colours
    const teal = PdfColor(0.051, 0.596, 0.533);
    const incomeGreen = PdfColor(0.149, 0.651, 0.604);
    const expenseRed = PdfColor(0.937, 0.325, 0.314);
    const altRow = PdfColor(0.941, 0.992, 0.980);

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'NuruWallet Report',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: teal,
                  ),
                ),
                pw.Text(
                  'Generated: ${DateFormatter.full(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Divider(color: teal, thickness: 1.5),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (_) => [
          // --- Summary boxes ---
          pw.Row(children: [
            _summaryBox('Income', CurrencyFormatter.format(totalIncome),
                incomeGreen),
            pw.SizedBox(width: 8),
            _summaryBox('Expenses', CurrencyFormatter.format(totalExpense),
                expenseRed),
            pw.SizedBox(width: 8),
            _summaryBox(
              net >= 0 ? 'Net Income' : 'Net Loss',
              CurrencyFormatter.format(net.abs()),
              net >= 0 ? incomeGreen : expenseRed,
            ),
          ]),
          pw.SizedBox(height: 16),

          // --- Analytics ---
          pw.Text('Analytics',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
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
                        fontSize: 9,
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
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700)),
                  pw.SizedBox(height: 8),
                  for (final e in sortedCats.take(5))
                    _pdfCategoryRow(e.key, e.value, totalExpense),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // --- Accounts ---
          pw.Text('Accounts',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              _headerRow(['Account Name', 'Type', 'Balance'], teal),
              for (final a in accounts)
                _dataRow([
                  a.name,
                  a.type.label,
                  CurrencyFormatter.format(a.balance),
                ], false),
            ],
          ),
          pw.SizedBox(height: 16),

          // --- Transactions ---
          pw.Text(
            'All Transactions (${transactions.length})',
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.5),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(2.0),
              3: pw.FlexColumnWidth(2.0),
              4: pw.FlexColumnWidth(2.2),
              5: pw.FlexColumnWidth(2.0),
            },
            children: [
              _headerRow(
                  ['Date & Time', 'Type', 'Category', 'Account',
                      'Amount', 'Note'],
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

    await OpenFile.open(file.path);
  }

  // ---------------------------------------------------------------------------
  // PDF analytics helpers
  // ---------------------------------------------------------------------------

  static pw.Widget _pdfBarRow(
      String label, double value, double total, PdfColor color) {
    final frac = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    final filled = ((frac * 100).round()).clamp(1, 99).toInt();
    final empty = 100 - filled;
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 60,
          child: pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 8, color: PdfColors.grey800)),
        ),
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: filled,
                child: pw.Container(height: 14, color: color),
              ),
              pw.Expanded(
                flex: empty,
                child: pw.Container(height: 14, color: PdfColors.grey200),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 6),
        pw.SizedBox(
          width: 90,
          child: pw.Text(
            CurrencyFormatter.format(value),
            style: pw.TextStyle(
                fontSize: 8,
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
            width: 90,
            child: pw.Text(name,
                overflow: pw.TextOverflow.clip,
                maxLines: 1,
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey800)),
          ),
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: filled,
                  child: pw.Container(height: 8, color: barColor),
                ),
                pw.Expanded(
                  flex: 100 - filled,
                  child:
                      pw.Container(height: 8, color: PdfColors.grey200),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 6),
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '${pct.toStringAsFixed(1)}% · ${CurrencyFormatter.format(value)}',
              style: const pw.TextStyle(
                  fontSize: 7, color: PdfColors.grey700),
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

  static pw.Widget _summaryBox(
          String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color),
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label,
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey700)),
              pw.SizedBox(height: 2),
              pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      );

  static pw.TableRow _headerRow(List<String> cells, PdfColor bg) =>
      pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 5, vertical: 4),
                  child: pw.Text(c,
                      style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                ))
            .toList(),
      );

  static pw.TableRow _dataRow(List<String> cells, bool alt) =>
      pw.TableRow(
        decoration: alt
            ? const pw.BoxDecoration(color: PdfColors.grey100)
            : null,
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 5, vertical: 3),
                  child: pw.Text(c,
                      style: const pw.TextStyle(fontSize: 8)),
                ))
            .toList(),
      );

  static pw.TableRow _txRow(
    TransactionEntry t,
    Map<String, String> catMap,
    Map<String, String> accMap,
    PdfColor rowColor,
    PdfColor incomeColor,
    PdfColor expenseColor,
  ) {
    final isIncome = t.type == TransactionType.income;

    pw.Widget cell(String text, {PdfColor? color}) => pw.Padding(
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: pw.Text(text,
              style: pw.TextStyle(
                  fontSize: 8, color: color ?? PdfColors.black)),
        );

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: rowColor),
      children: [
        cell(DateFormatter.dateTime(t.date)),
        cell(t.type.label,
            color: isIncome ? incomeColor : expenseColor),
        cell(catMap[t.categoryId] ?? ''),
        cell(accMap[t.accountId] ?? ''),
        cell(CurrencyFormatter.format(t.amount)),
        cell(t.note ?? ''),
      ],
    );
  }
}
