import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/category_icon.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Period model
// ---------------------------------------------------------------------------

enum _Period { week, month, sixMonths, year }

extension _PeriodX on _Period {
  String get label => switch (this) {
        _Period.week => 'Week',
        _Period.month => 'Month',
        _Period.sixMonths => '6 Months',
        _Period.year => 'Year',
      };
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Period _period = _Period.month;
  String? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final allTxAsync = ref.watch(allTransactionsProvider);
    final accountsAsync = ref.watch(allAccountsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: _Period.values.map((p) {
                final selected = p == _period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _period = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        p.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: selected
                              ? Colors.white
                              : scheme.onSurface
                                  .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Account filter chips
          accountsAsync.maybeWhen(
            data: (accounts) {
              if (accounts.length <= 1) return const SizedBox.shrink();
              return SizedBox(
                height: 36,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _AccountChip(
                      label: 'All',
                      selected: _selectedAccountId == null,
                      onTap: () =>
                          setState(() => _selectedAccountId = null),
                    ),
                    for (final a in accounts) ...[
                      const SizedBox(width: 6),
                      _AccountChip(
                        label: a.name,
                        selected: _selectedAccountId == a.id,
                        onTap: () =>
                            setState(() => _selectedAccountId = a.id),
                      ),
                    ],
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          // Body
          Expanded(
            child: allTxAsync.when(
              data: (all) {
                final accountFiltered = _selectedAccountId == null
                    ? all
                    : all
                        .where((t) => t.accountId == _selectedAccountId)
                        .toList();
                final now = DateTime.now();
                final filtered = _filterByPeriod(accountFiltered, now);
                final summary = _summarize(filtered);
                final barPoints = _buildBarPoints(accountFiltered, now);
                final catSpend = _categorySpend(filtered);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    // Summary row
                    _SummaryRow(
                        income: summary.income,
                        expense: summary.expense),
                    const SizedBox(height: 20),

                    // Trend chart
                    _SectionHeader(_trendTitle),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 16, 12, 12),
                        child: barPoints.every(
                                (p) => p.income == 0 && p.expense == 0)
                            ? _EmptyHint('Add transactions to see trends')
                            : Column(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    child: CustomPaint(
                                      painter: _AreaChartPainter(
                                        points: barPoints,
                                        incomeColor: AppColors.income,
                                        expenseColor: AppColors.expense,
                                        gridColor: scheme.onSurface
                                            .withValues(alpha: 0.07),
                                        labelColor: scheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      _LegendDot(
                                          color: AppColors.income,
                                          label: 'Income'),
                                      const SizedBox(width: 24),
                                      _LegendDot(
                                          color: AppColors.expense,
                                          label: 'Expense'),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category donut + list
                    _SectionHeader('Spending by Category'),
                    const SizedBox(height: 10),
                    if (catSpend.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: _EmptyHint(
                              'No expenses recorded for this period'),
                        ),
                      )
                    else ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 130,
                                height: 130,
                                child: CustomPaint(
                                  painter: _DonutChartPainter(
                                    segments: catSpend
                                        .take(6)
                                        .map((e) => _DonutSegment(
                                              value: e.value,
                                              color: e.key != null
                                                  ? Color(e.key!
                                                      .colorValue)
                                                  : scheme.onSurface
                                                      .withValues(
                                                          alpha: 0.3),
                                            ))
                                        .toList(),
                                    holeRatio: 0.55,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          CurrencyFormatter
                                              .formatCompact(
                                            catSpend.fold<double>(
                                                0,
                                                (s, e) =>
                                                    s + e.value),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'total',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: scheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: catSpend
                                      .take(5)
                                      .map((e) => _DonutLegendRow(
                                            category: e.key,
                                            amount: e.value,
                                            total: catSpend.fold<double>(
                                                0, (s, x) => s + x.value),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: [
                            for (int i = 0;
                                i < catSpend.length;
                                i++) ...[
                              _CategoryBar(
                                category: catSpend[i].key,
                                amount: catSpend[i].value,
                                share: catSpend.fold<double>(
                                            0,
                                            (s, e) => s + e.value) >
                                        0
                                    ? catSpend[i].value /
                                        catSpend.fold<double>(
                                            0, (s, e) => s + e.value)
                                    : 0,
                              ),
                              if (i < catSpend.length - 1)
                                const Divider(height: 1, indent: 56),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  // --- Data helpers ---

  String get _trendTitle => switch (_period) {
        _Period.week => 'This Week (Daily)',
        _Period.month => 'This Month (Weekly)',
        _Period.sixMonths => 'Last 6 Months',
        _Period.year => 'Last 12 Months',
      };

  List<TransactionEntry> _filterByPeriod(
      List<TransactionEntry> all, DateTime now) {
    final from = switch (_period) {
      _Period.week      => DateTime(now.year, now.month, now.day - 6),
      _Period.month     => DateTime(now.year, now.month),
      _Period.sixMonths => DateTime(now.year, now.month - 5),
      _Period.year      => DateTime(now.year, now.month - 11),
    };
    return all.where((t) => !t.date.isBefore(from)).toList();
  }

  ({double income, double expense}) _summarize(
      List<TransactionEntry> txs) {
    double inc = 0, exp = 0;
    for (final t in txs) {
      if (t.type == TransactionType.income) {
        inc += t.amount;
      } else {
        exp += t.amount;
      }
    }
    return (income: inc, expense: exp);
  }

  List<_ChartPoint> _buildBarPoints(
      List<TransactionEntry> all, DateTime now) {
    return switch (_period) {
      _Period.week => _groupByDay(all, now, 7),
      _Period.month => _groupByWeekOfMonth(all, now),
      _Period.sixMonths => _groupByMonth(all, now, 6),
      _Period.year => _groupByMonth(all, now, 12),
    };
  }

  List<_ChartPoint> _groupByDay(
      List<TransactionEntry> all, DateTime now, int days) {
    final points = <_ChartPoint>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final txs = all.where((t) =>
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day);
      final label = _dayAbbr(day.weekday);
      double inc = 0, exp = 0;
      for (final t in txs) {
        if (t.type == TransactionType.income) { inc += t.amount; }
        else { exp += t.amount; }
      }
      points.add(_ChartPoint(label: label, income: inc, expense: exp));
    }
    return points;
  }

  List<_ChartPoint> _groupByWeekOfMonth(
      List<TransactionEntry> all, DateTime now) {
    final txs = all.where((t) =>
        t.date.year == now.year && t.date.month == now.month);
    final weeks = <int, ({double income, double expense})>{};
    for (final t in txs) {
      final wk = ((t.date.day - 1) ~/ 7) + 1;
      final cur = weeks[wk] ?? (income: 0.0, expense: 0.0);
      if (t.type == TransactionType.income) {
        weeks[wk] = (income: cur.income + t.amount, expense: cur.expense);
      } else {
        weeks[wk] = (income: cur.income, expense: cur.expense + t.amount);
      }
    }
    final totalWeeks = ((DateTime(now.year, now.month + 1, 0).day - 1) ~/ 7) + 1;
    return List.generate(totalWeeks, (i) {
      final wk = i + 1;
      final v = weeks[wk] ?? (income: 0.0, expense: 0.0);
      return _ChartPoint(
          label: 'W$wk', income: v.income, expense: v.expense);
    });
  }

  List<_ChartPoint> _groupByMonth(
      List<TransactionEntry> all, DateTime now, int count) {
    final points = <_ChartPoint>[];
    for (int i = count - 1; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i);
      final txs = all.where(
          (t) => t.date.year == dt.year && t.date.month == dt.month);
      double inc = 0, exp = 0;
      for (final t in txs) {
        if (t.type == TransactionType.income) { inc += t.amount; }
        else { exp += t.amount; }
      }
      points.add(_ChartPoint(
          label: _monthAbbr(dt.month), income: inc, expense: exp));
    }
    return points;
  }

  List<MapEntry<CategoryEntry?, double>> _categorySpend(
      List<TransactionEntry> txs) {
    final catsMap = ref.read(categoriesMapProvider).valueOrNull ?? {};
    final map = <String, double>{};
    for (final t in txs) {
      if (t.type == TransactionType.expense) {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    final entries = map.entries
        .map((e) => MapEntry(catsMap[e.key], e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  static String _dayAbbr(int wd) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd - 1];

  static String _monthAbbr(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _ChartPoint {
  const _ChartPoint(
      {required this.label,
      required this.income,
      required this.expense});
  final String label;
  final double income;
  final double expense;
}

class _DonutSegment {
  const _DonutSegment({required this.value, required this.color});
  final double value;
  final Color color;
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.points,
    required this.incomeColor,
    required this.expenseColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<_ChartPoint> points;
  final Color incomeColor;
  final Color expenseColor;
  final Color gridColor;
  final Color labelColor;

  static const _bottomPad = 24.0;
  static const _topPad = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxVal = points.fold<double>(
      1,
      (m, p) => math.max(m, math.max(p.income, p.expense)),
    );

    final chartH = size.height - _bottomPad - _topPad;
    final step = size.width / (points.length - 1).clamp(1, 9999);

    // Grid
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 3; i++) {
      final y = _topPad + chartH * (1 - i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    void drawArea(
        List<_ChartPoint> pts,
        double Function(_ChartPoint) getValue,
        Color color) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      final path = Path();
      final fillPath = Path();

      final bottomY = _topPad + chartH;
      fillPath.moveTo(0, bottomY);

      for (int i = 0; i < pts.length; i++) {
        final x = i * step;
        final y = _topPad + chartH * (1 - getValue(pts[i]) / maxVal);
        if (i == 0) {
          path.moveTo(x, y);
          fillPath.lineTo(x, y);
        } else {
          final prev = (i - 1) * step;
          final prevY = _topPad +
              chartH * (1 - getValue(pts[i - 1]) / maxVal);
          final cx = (prev + x) / 2;
          path.cubicTo(cx, prevY, cx, y, x, y);
          fillPath.cubicTo(cx, prevY, cx, y, x, y);
        }
      }

      fillPath.lineTo((pts.length - 1) * step, bottomY);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);

      // Dots
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (int i = 0; i < pts.length; i++) {
        final x = i * step;
        final y = _topPad + chartH * (1 - getValue(pts[i]) / maxVal);
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }

    drawArea(points, (p) => p.income, incomeColor);
    drawArea(points, (p) => p.expense, expenseColor);

    // X-axis labels
    for (int i = 0; i < points.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: points[i].label,
          style: TextStyle(color: labelColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = i * step;
      tp.paint(
          canvas,
          Offset(
            (x - tp.width / 2).clamp(0, size.width - tp.width),
            size.height - _bottomPad + 5,
          ));
    }
  }

  @override
  bool shouldRepaint(_AreaChartPainter old) => old.points != points;
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.segments, this.holeRatio = 0.6});

  final List<_DonutSegment> segments;
  final double holeRatio;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius =
        math.min(size.width, size.height) / 2 - 4;
    final innerRadius = outerRadius * holeRatio;

    final strokeWidth = outerRadius - innerRadius;
    final midRadius = (outerRadius + innerRadius) / 2;
    final midRect = Rect.fromCircle(center: center, radius: midRadius);

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * math.pi * 2;
      canvas.drawArc(
        midRect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) =>
      old.segments != segments;
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.income, required this.expense});
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Income',
            amount: income,
            color: AppColors.income,
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Expenses',
            amount: expense,
            color: AppColors.expense,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Net',
            amount: net.abs(),
            color: net >= 0 ? AppColors.income : AppColors.expense,
            icon: net >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.4),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _DonutLegendRow extends StatelessWidget {
  const _DonutLegendRow({
    required this.category,
    required this.amount,
    required this.total,
  });
  final CategoryEntry? category;
  final double amount;
  final double total;

  @override
  Widget build(BuildContext context) {
    final color = category != null
        ? Color(category!.colorValue)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              category?.name ?? 'Other',
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${(total > 0 ? amount / total * 100 : 0).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? Colors.white : scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.share,
  });
  final CategoryEntry? category;
  final double amount;
  final double share;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = category != null
        ? Color(category!.colorValue)
        : scheme.onSurface.withValues(alpha: 0.3);
    final name = category?.name ?? 'Unknown';
    final icon = category != null
        ? CategoryIcon.get(category!.iconName)
        : Icons.help_outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(amount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: 4,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(share * 100).toStringAsFixed(1)}% of total',
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
