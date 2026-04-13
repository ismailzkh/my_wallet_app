import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/chart_utils.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../domain/entities/app_entities.dart';
import '../../controllers/app_controllers.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
    required this.controller,
  });

  final TransactionsController controller;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

enum _ReportColorType {
  income,
  expense,
}

enum _ReportChartType {
  bar,
  line,
}

class _ReportsScreenState extends State<ReportsScreen> {
  _ReportChartType _chartType = _ReportChartType.bar;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final transactions = widget.controller.transactions;
        final income = widget.controller.totalIncome;
        final expense = widget.controller.totalExpense;
        final net = widget.controller.totalBalance;

        final expenseByCategory = <String, double>{};
        final incomeByCategory = <String, double>{};

        for (final t in transactions) {
          final category =
              t.category.trim().isEmpty ? 'General' : t.category.trim();

          if (t.type == TransactionTypeEntity.expense) {
            expenseByCategory[category] =
                (expenseByCategory[category] ?? 0) + t.amount;
          } else {
            incomeByCategory[category] =
                (incomeByCategory[category] ?? 0) + t.amount;
          }
        }

        final sortedExpenseCategories = expenseByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final sortedIncomeCategories = incomeByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final recentTransactions = [...transactions]
          ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
          ),
          body: SafeArea(
            child: transactions.isEmpty
                ? const _EmptyReportsView()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Income',
                              value: income,
                              colorType: _ReportColorType.income,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Expense',
                              value: expense,
                              colorType: _ReportColorType.expense,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryCard(
                        title: 'Net Balance',
                        value: net,
                        colorType: net >= 0
                            ? _ReportColorType.income
                            : _ReportColorType.expense,
                      ),
                      const SizedBox(height: 12),
                      _ReportChartSection(
                        transactions: transactions,
                        chartType: _chartType,
                        onChartTypeChanged: (value) {
                          setState(() {
                            _chartType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _CategoryPieSection(
                        title: 'Expense categories analysis',
                        data: expenseByCategory,
                        type: TransactionTypeEntity.expense,
                      ),
                      const SizedBox(height: 20),
                      _CategoryPieSection(
                        title: 'Income categories analysis',
                        data: incomeByCategory,
                        type: TransactionTypeEntity.income,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          title: const Text('Transactions count'),
                          trailing: Text(
                            transactions.length.toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Top expense categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (sortedExpenseCategories.isEmpty)
                        const _InfoCard(
                          text: 'No expense transactions yet.',
                        )
                      else
                        ...sortedExpenseCategories.take(5).map(
                              (entry) => _CategoryTile(
                                title: entry.key,
                                amount: entry.value,
                                total: expense,
                                type: TransactionTypeEntity.expense,
                              ),
                            ),
                      const SizedBox(height: 20),
                      Text(
                        'Top income categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (sortedIncomeCategories.isEmpty)
                        const _InfoCard(
                          text: 'No income transactions yet.',
                        )
                      else
                        ...sortedIncomeCategories.take(5).map(
                              (entry) => _CategoryTile(
                                title: entry.key,
                                amount: entry.value,
                                total: income,
                                type: TransactionTypeEntity.income,
                              ),
                            ),
                      const SizedBox(height: 20),
                      Text(
                        'Recent activity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ...recentTransactions.take(5).map(
                            (t) => _RecentTransactionTile(transaction: t),
                          ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.colorType,
  });

  final String title;
  final double value;
  final _ReportColorType colorType;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final color = colorType == _ReportColorType.income
        ? appColors.success
        : appColors.danger;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.format(value),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.amount,
    required this.total,
    required this.type,
  });

  final String title;
  final double amount;
  final double total;
  final TransactionTypeEntity type;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final color = type == TransactionTypeEntity.income
        ? appColors.success
        : appColors.danger;

    final percent = total <= 0 ? 0.0 : (amount / total) * 100;
    final progress = (percent / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _CategoryIcon(title: title, type: type),
                        const SizedBox(width: 8),
                        Expanded(child: Text(title)),
                      ],
                    ),
                  ),
                  Text(
  CurrencyUtils.format(amount.abs()),
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: appColors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyUtils.format(amount.abs()),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({
    required this.transaction,
  });

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isIncome = transaction.type == TransactionTypeEntity.income;
    final color = isIncome ? appColors.success : appColors.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: color,
          ),
          title: Text(transaction.title),
          subtitle: Text(
            '${transaction.category} • ${_formatDate(transaction.date)}',
          ),
          trailing: Text(
            CurrencyUtils.format(transaction.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _ReportChartSection extends StatelessWidget {
  const _ReportChartSection({
    required this.transactions,
    required this.chartType,
    required this.onChartTypeChanged,
  });

  final List<TransactionEntity> transactions;
  final _ReportChartType chartType;
  final ValueChanged<_ReportChartType> onChartTypeChanged;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final List<double> dailyNet = List.generate(daysInMonth, (_) => 0);

    for (final t in transactions) {
      if (t.date.isBefore(startOfMonth)) continue;
      if (t.date.isAfter(now)) continue;

      final dayIndex = t.date.day - 1;
      if (dayIndex < 0 || dayIndex >= daysInMonth) continue;

      if (t.type == TransactionTypeEntity.income) {
        dailyNet[dayIndex] += t.amount;
      } else if (t.type == TransactionTypeEntity.expense) {
        dailyNet[dayIndex] -= t.amount;
      }
    }

    final hasData = dailyNet.any((v) => v != 0);
    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net Flow This Month',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Income minus expense per day',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: appColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: appColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SegmentedButton<_ReportChartType>(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return appColors.success.withValues(alpha: 0.18);
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return appColors.success;
                      }
                      return colorScheme.onSurface.withValues(alpha: 0.72);
                    }),
                    side: const WidgetStatePropertyAll(BorderSide.none),
                    elevation: const WidgetStatePropertyAll(0),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  segments: const [
                    ButtonSegment<_ReportChartType>(
                      value: _ReportChartType.bar,
                      label: Text('Bar'),
                      icon: Icon(Icons.bar_chart_rounded),
                    ),
                    ButtonSegment<_ReportChartType>(
                      value: _ReportChartType.line,
                      label: Text('Line'),
                      icon: Icon(Icons.show_chart_rounded),
                    ),
                  ],
                  selected: {chartType},
                  onSelectionChanged: (values) {
                    onChartTypeChanged(values.first);
                  },
                  showSelectedIcon: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: switch (chartType) {
                _ReportChartType.bar => SimpleNetBarChart(dailyNet: dailyNet),
                _ReportChartType.line => SimpleNetLineChart(dailyNet: dailyNet),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleNetLineChart extends StatelessWidget {
  const SimpleNetLineChart({
    super.key,
    required this.dailyNet,
  });

  final List<double> dailyNet;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final daysInMonth = dailyNet.length;

    double minY = 0;
    double maxY = 0;
    for (final v in dailyNet) {
      if (v < minY) minY = v;
      if (v > maxY) maxY = v;
    }
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < daysInMonth; i++) {
      spots.add(FlSpot(i.toDouble(), dailyNet[i]));
    }

    final padding = (maxY - minY).abs() * 0.2;
    final minAxis = minY - padding;
    final maxAxis = maxY + padding;
    final interval = (maxAxis - minAxis) / 2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (daysInMonth - 1).toDouble(),
        minY: minAxis,
        maxY: maxAxis,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: appColors.surfaceAlt,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: appColors.surfaceAlt,
            width: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 64,
              interval: interval,
              getTitlesWidget: (value, meta) {
                final label = ChartUtils.formatMoneyAxis(value);
                return Text(
                  label,
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final day = value.toInt() + 1;

                if (day < 1 || day > daysInMonth) {
                  return const SizedBox.shrink();
                }

                if (!ChartUtils.showDayLabel(day, daysInMonth)) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: appColors.success,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}

class SimpleNetBarChart extends StatelessWidget {
  const SimpleNetBarChart({
    super.key,
    required this.dailyNet,
  });

  final List<double> dailyNet;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final daysInMonth = dailyNet.length;

    double minY = 0;
    double maxY = 0;
    for (final v in dailyNet) {
      if (v < minY) minY = v;
      if (v > maxY) maxY = v;
    }
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final padding = (maxY - minY).abs() * 0.2;
    final minAxis = minY - padding;
    final maxAxis = maxY + padding;
    final interval = (maxAxis - minAxis) / 2;

    return BarChart(
      BarChartData(
        minY: minAxis,
        maxY: maxAxis,
        alignment: BarChartAlignment.start,
        groupsSpace: 8,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: appColors.surfaceAlt,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: appColors.surfaceAlt,
            width: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 64,
              interval: interval,
              getTitlesWidget: (value, meta) {
                final label = ChartUtils.formatMoneyAxis(value);

                return Text(
                  label,
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final day = value.toInt() + 1;

                if (day < 1 || day > daysInMonth) {
                  return const SizedBox.shrink();
                }

                if (!ChartUtils.showDayLabel(day, daysInMonth)) {
                  return const SizedBox.shrink();
                }

                return Text(
                  day.toString(),
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(daysInMonth, (index) {
          final value = dailyNet[index];
          final isPositive = value >= 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 8,
                color: isPositive ? appColors.success : appColors.danger,
                borderRadius: BorderRadius.circular(99),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoryPieSection extends StatelessWidget {
  const _CategoryPieSection({
    required this.title,
    required this.data,
    required this.type,
  });

  final String title;
  final Map<String, double> data;
  final TransactionTypeEntity type;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    if (data.isEmpty) {
      return _InfoCard(
        text: type == TransactionTypeEntity.expense
            ? 'No expense category data yet.'
            : 'No income category data yet.',
      );
    }

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    final colors = <Color>[
      type == TransactionTypeEntity.expense
          ? appColors.danger
          : appColors.success,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 42,
                  sections: List.generate(entries.length, (index) {
                    final entry = entries[index];
                    final percent =
                        total <= 0 ? 0.0 : (entry.value / total) * 100;

                    return PieChartSectionData(
                      value: entry.value,
                      color: colors[index % colors.length],
                      radius: 58,
                      title: '${percent.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...entries.take(5).toList().asMap().entries.map((item) {
              final index = item.key;
              final entry = item.value;
              final percent = total <= 0 ? 0.0 : (entry.value / total) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 10),
                    Text(
  CurrencyUtils.format(entry.value.abs()),
  style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.title,
    required this.type,
  });

  final String title;
  final TransactionTypeEntity type;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final color = type == TransactionTypeEntity.income
        ? appColors.success
        : appColors.danger;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForCategory(title),
        size: 18,
        color: color,
      ),
    );
  }

  IconData _iconForCategory(String category) {
    final c = category.trim().toLowerCase();

    if (c.contains('food') ||
        c.contains('restaurant') ||
        c.contains('meal') ||
        c.contains('lunch') ||
        c.contains('dinner') ||
        c.contains('breakfast') ||
        c.contains('grocery') ||
        c.contains('groceries') ||
        c.contains('supermarket')) {
      return Icons.restaurant_rounded;
    }

    if (c.contains('coffee') ||
        c.contains('cafe') ||
        c.contains('tea') ||
        c.contains('drink')) {
      return Icons.local_cafe_rounded;
    }

    if (c.contains('car') ||
        c.contains('transport') ||
        c.contains('taxi') ||
        c.contains('uber') ||
        c.contains('bus') ||
        c.contains('fuel') ||
        c.contains('gas') ||
        c.contains('petrol')) {
      return Icons.directions_car_rounded;
    }

    if (c.contains('train') || c.contains('metro') || c.contains('subway')) {
      return Icons.train_rounded;
    }

    if (c.contains('bike') || c.contains('bicycle')) {
      return Icons.pedal_bike_rounded;
    }

    if (c.contains('flight') || c.contains('air') || c.contains('plane')) {
      return Icons.flight_rounded;
    }

    if (c.contains('travel') ||
        c.contains('trip') ||
        c.contains('vacation') ||
        c.contains('holiday')) {
      return Icons.luggage_rounded;
    }

    if (c.contains('hotel') || c.contains('stay')) {
      return Icons.hotel_rounded;
    }

    if (c.contains('shopping') ||
        c.contains('shop') ||
        c.contains('clothes') ||
        c.contains('clothing') ||
        c.contains('market') ||
        c.contains('mall')) {
      return Icons.shopping_bag_rounded;
    }

    if (c.contains('beauty') ||
        c.contains('cosmetic') ||
        c.contains('makeup') ||
        c.contains('skincare') ||
        c.contains('salon') ||
        c.contains('barber')) {
      return Icons.face_retouching_natural_rounded;
    }

    if (c.contains('home') ||
        c.contains('rent') ||
        c.contains('house') ||
        c.contains('apartment')) {
      return Icons.home_rounded;
    }

    if (c.contains('bill') ||
        c.contains('electric') ||
        c.contains('electricity') ||
        c.contains('water') ||
        c.contains('internet') ||
        c.contains('wifi') ||
        c.contains('utility') ||
        c.contains('utilities')) {
      return Icons.receipt_long_rounded;
    }

    if (c.contains('phone') ||
        c.contains('mobile') ||
        c.contains('call') ||
        c.contains('sim')) {
      return Icons.smartphone_rounded;
    }

    if (c.contains('health') ||
        c.contains('doctor') ||
        c.contains('hospital') ||
        c.contains('medicine') ||
        c.contains('medical') ||
        c.contains('clinic')) {
      return Icons.local_hospital_rounded;
    }

    if (c.contains('pharmacy') || c.contains('drug')) {
      return Icons.medication_rounded;
    }

    if (c.contains('gym') ||
        c.contains('fitness') ||
        c.contains('workout') ||
        c.contains('sport') ||
        c.contains('sports')) {
      return Icons.fitness_center_rounded;
    }

    if (c.contains('pet') ||
        c.contains('dog') ||
        c.contains('cat') ||
        c.contains('animal') ||
        c.contains('vet')) {
      return Icons.pets_rounded;
    }

    if (c.contains('baby') || c.contains('kids') || c.contains('child')) {
      return Icons.child_friendly_rounded;
    }

    if (c.contains('education') ||
        c.contains('school') ||
        c.contains('book') ||
        c.contains('course') ||
        c.contains('university') ||
        c.contains('study')) {
      return Icons.school_rounded;
    }

    if (c.contains('movie') || c.contains('cinema') || c.contains('film')) {
      return Icons.movie_rounded;
    }

    if (c.contains('music') || c.contains('song') || c.contains('spotify')) {
      return Icons.music_note_rounded;
    }

    if (c.contains('game') || c.contains('gaming')) {
      return Icons.sports_esports_rounded;
    }

    if (c.contains('entertainment') || c.contains('fun')) {
      return Icons.celebration_rounded;
    }

    if (c.contains('gift') || c.contains('bonus') || c.contains('present')) {
      return Icons.card_giftcard_rounded;
    }

    if (c.contains('salary') ||
        c.contains('income') ||
        c.contains('job') ||
        c.contains('work') ||
        c.contains('wage')) {
      return Icons.account_balance_wallet_rounded;
    }

    if (c.contains('freelance') ||
        c.contains('business') ||
        c.contains('project')) {
      return Icons.work_rounded;
    }

    if (c.contains('bank') ||
        c.contains('transfer') ||
        c.contains('card') ||
        c.contains('payment')) {
      return Icons.credit_card_rounded;
    }

    if (c.contains('saving') ||
        c.contains('savings') ||
        c.contains('deposit')) {
      return Icons.savings_rounded;
    }

    if (c.contains('investment') ||
        c.contains('stock') ||
        c.contains('crypto')) {
      return Icons.trending_up_rounded;
    }

    if (c.contains('tax')) {
      return Icons.account_balance_rounded;
    }

    if (c.contains('charity') || c.contains('donation')) {
      return Icons.volunteer_activism_rounded;
    }

    if (c.contains('repair') ||
        c.contains('maintenance') ||
        c.contains('tool')) {
      return Icons.build_rounded;
    }

    if (c.contains('office') ||
        c.contains('stationery') ||
        c.contains('supplies')) {
      return Icons.inventory_2_rounded;
    }

    if (c.contains('subscription') ||
        c.contains('netflix') ||
        c.contains('youtube')) {
      return Icons.subscriptions_rounded;
    }

    if (c.contains('security') || c.contains('insurance')) {
      return Icons.shield_rounded;
    }

    return Icons.category_rounded;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}

class _EmptyReportsView extends StatelessWidget {
  const _EmptyReportsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'No reports yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add transactions to see reports and category breakdown.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}