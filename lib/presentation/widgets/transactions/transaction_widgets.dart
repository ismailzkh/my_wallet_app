import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('All'),
            selected: selectedType == null,
            onSelected: (_) => onChanged(null),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text('Income'),
            selected: selectedType == TransactionTypeEntity.income,
            onSelected: (_) => onChanged(TransactionTypeEntity.income),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text('Expense'),
            selected: selectedType == TransactionTypeEntity.expense,
            onSelected: (_) => onChanged(TransactionTypeEntity.expense),
          ),
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
    final isIncome = transaction.type == TransactionTypeEntity.income;
    final amountColor = isIncome ? Colors.green : Colors.red;
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
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: amountColor,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category} • ${_formatDate(transaction.date)}',
        ),
        trailing: Text(
          '$amountPrefix\$${transaction.amount.toStringAsFixed(2)}',
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 56,
              color: theme.colorScheme.primary,
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