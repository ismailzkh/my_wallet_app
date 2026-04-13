import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../domain/entities/app_entities.dart';
import '../../controllers/app_controllers.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.transactionsController,
    required this.onAddTransaction,
    this.showLocalFab = true,
    this.showAppBarAddButton = true,
  });

  final TransactionsController transactionsController;
  final VoidCallback onAddTransaction;
  final bool showLocalFab;
  final bool showAppBarAddButton;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AnimatedBuilder(
      animation: transactionsController,
      builder: (context, _) {
        final transactions = transactionsController.transactions;
        final income = _income(transactions);
        final expense = _expense(transactions);
        final balance = income - expense;

        return Scaffold(
          backgroundColor: colors.bg,
          appBar: AppBar(
            title: const Text('Overview'),
            actions: showAppBarAddButton
                ? [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton.icon(
                        onPressed: onAddTransaction,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ]
                : null,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _BalanceCard(
                  balance: balance,
                  income: income,
                  expense: expense,
                ),
                const SizedBox(height: 12),
                _ThisMonthSummary(transactions: transactions),
                const SizedBox(height: 12),
                _ThisMonthBarChart(transactions: transactions),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        title: 'Income',
                        value: income,
                        color: colors.success,
                        icon: Icons.south_west_rounded,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _MiniStatCard(
                        title: 'Expense',
                        value: expense,
                        color: colors.danger,
                        icon: Icons.north_east_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${transactions.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  const _EmptyState()
                else
                  ...transactions.take(6).map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TransactionTile(transaction: t),
                        ),
                      ),
              ],
            ),
          ),
          floatingActionButton: showLocalFab
              ? FloatingActionButton(
                  onPressed: onAddTransaction,
                  child: const Icon(Icons.add_rounded, size: 24),
                )
              : null,
        );
      },
    );
  }

  double _income(List<TransactionEntity> t) => t
      .where((e) => e.type == TransactionTypeEntity.income)
      .fold(0.0, (s, e) => s + e.amount);

  double _expense(List<TransactionEntity> t) => t
      .where((e) => e.type == TransactionTypeEntity.expense)
      .fold(0.0, (s, e) => s + e.amount);
}

// helper to format date + time
String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year  $hour:$minute';
}

class _ThisMonthSummary extends StatelessWidget {
  const _ThisMonthSummary({
    required this.transactions,
  });

  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    double monthIncome = 0;
    double monthExpense = 0;

    for (final t in transactions) {
      if (t.date.isBefore(startOfMonth)) continue;
      if (t.date.isAfter(now)) continue;

      if (t.type == TransactionTypeEntity.income) {
        monthIncome += t.amount;
      } else if (t.type == TransactionTypeEntity.expense) {
        monthExpense += t.amount;
      }
    }

    final monthNet = monthIncome - monthExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Income',
                    value: monthIncome,
                    color: colors.success,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Expense',
                    value: monthExpense,
                    color: colors.danger,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Net',
                    value: monthNet,
                    color: monthNet >= 0 ? colors.success : colors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============== BAR CHART (THIS MONTH) ==============

class _ThisMonthBarChart extends StatelessWidget {
  const _ThisMonthBarChart({
    required this.transactions,
  });

  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
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

    final maxAbs = dailyNet.fold<double>(0, (prev, v) {
      final abs = v.abs();
      return abs > prev ? abs : prev;
    });

    if (maxAbs == 0) {
      return const SizedBox.shrink();
    }

    final maxY = maxAbs * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Net',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Income minus expense for each day',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${now.month}/${now.year}',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _ChartLegendDot(
                  color: colors.success,
                  label: 'Positive',
                ),
                const SizedBox(width: 14),
                _ChartLegendDot(
                  color: colors.danger,
                  label: 'Negative',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 230,
              child: BarChart(
                BarChartData(
                  minY: -maxY,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 6,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = group.x + 1;
                        final value = rod.toY;
                        final prefix = value >= 0 ? '+' : '-';
                        return BarTooltipItem(
                          'Day $day\n$prefix${CurrencyUtils.compact(value.abs())}',
                          textTheme.bodySmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        );
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 3,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colors.surfaceAlt,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 64,
                        interval: maxY / 3,
                        getTitlesWidget: (value, meta) {
                          final text = CurrencyUtils.compactPlain(value);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              text,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final day = value.toInt() + 1;
                          if (day < 1 || day > daysInMonth) {
                            return const SizedBox.shrink();
                          }

                          final shouldShow =
                              day == 1 || day == 5 ||day == 10 || day == 15 || day == 20 ||day == 25 || day == daysInMonth;

                          if (!shouldShow) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '$day',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
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
                          color: isPositive ? colors.success : colors.danger,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegendDot extends StatelessWidget {
  const _ChartLegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        Text(
          CurrencyUtils.format(value),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ================= BALANCE CARD =================

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
  });

  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final total = (income + expense) <= 0 ? 1.0 : (income + expense);
    final ratio = (income / total).clamp(0.05, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.format(balance),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.greenBright,
                            colors.green,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Green = income • Red = expense',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MINI CARDS =================

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              CurrencyUtils.format(value),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= TRANSACTION TILE =================

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isIncome = transaction.type == TransactionTypeEntity.income;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: isIncome ? colors.success : colors.danger,
            size: 18,
          ),
        ),
        title: Text(
          transaction.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${transaction.category} • ${_formatDateTime(transaction.date)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${CurrencyUtils.format(transaction.amount.abs())}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isIncome ? colors.success : colors.danger,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

// ================= EMPTY =================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
