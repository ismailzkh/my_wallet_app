import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/app_entities.dart';

class TransactionFilterChips extends StatelessWidget {
  const TransactionFilterChips({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final TransactionTypeEntity? selectedType;
  final ValueChanged<TransactionTypeEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    Widget buildChip(String label, bool selected, VoidCallback onTap) {
      final bg = selected
          ? appColors.success.withValues(alpha: 0.18)
          : appColors.surfaceAlt;
      final fg = selected ? appColors.success : appColors.textSecondary;

      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildChip('All', selectedType == null, () => onChanged(null)),
        const SizedBox(width: 8),
        buildChip(
          'Income',
          selectedType == TransactionTypeEntity.income,
          () => onChanged(TransactionTypeEntity.income),
        ),
        const SizedBox(width: 8),
        buildChip(
          'Expense',
          selectedType == TransactionTypeEntity.expense,
          () => onChanged(TransactionTypeEntity.expense),
        ),
      ],
    );
  }
}

class TransactionCardItem extends StatelessWidget {
  const TransactionCardItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final TransactionEntity transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final isIncome = transaction.type == TransactionTypeEntity.income;
    final amountColor = isIncome ? appColors.success : appColors.danger;
    final amountPrefix = isIncome ? '+' : '-';

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.12),
          child: Icon(
            isIncome
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${transaction.category} • ${_formatDate(transaction.date)}',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Text(
          '$amountPrefix${transaction.amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: amountColor,
            fontWeight: FontWeight.w700,
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

class TransactionEmptyState extends StatelessWidget {
  const TransactionEmptyState({
    super.key,
    this.title = 'No transactions found',
    this.subtitle = 'Add transactions or change the selected filter.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 56,
              color: appColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}