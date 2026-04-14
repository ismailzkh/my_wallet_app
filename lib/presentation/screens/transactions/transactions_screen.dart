import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/app_entities.dart';
import '../../controllers/app_controllers.dart';
import '../../../core/utils/currency_utils.dart';
import '../transactions/add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    required this.controller,
    required this.onAddTransaction,
  });

  final TransactionsController controller;
  final VoidCallback onAddTransaction;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _search = '';
  TransactionTypeEntity? _filterType; // null = all

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final all = widget.controller.transactions;
        final filtered = all.where((t) {
          final matchesSearch = _search.isEmpty ||
              t.title.toLowerCase().contains(_search) ||
              t.category.toLowerCase().contains(_search);
          final matchesType = switch (_filterType) {
            TransactionTypeEntity.income =>
              t.type == TransactionTypeEntity.income,
            TransactionTypeEntity.expense =>
              t.type == TransactionTypeEntity.expense,
            _ => true,
          };
          return matchesSearch && matchesType;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transactions'),
            actions: [
              IconButton(
                onPressed: widget.onAddTransaction,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add transaction',
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search by title or category',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _search = value.trim().toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _TypeFilterChips(
                        selected: _filterType,
                        onChanged: (type) {
                          setState(() {
                            _filterType = type;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyTransactionsView(
                          onAddTransaction: widget.onAddTransaction,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final transaction = filtered[index];
                            return _TransactionCard(
                              transaction: transaction,
                              onDelete: () async {
                                final confirmed = await _confirmDelete(context);
                                if (confirmed != true) return;
                                await widget.controller
                                    .deleteTransaction(transaction.id);
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddTransactionScreen(
                                      controller: widget.controller,
                                      existing: transaction,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: widget.onAddTransaction,
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips({
    required this.selected,
    required this.onChanged,
  });

  final TransactionTypeEntity? selected;
  final ValueChanged<TransactionTypeEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Row(
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Income'),
          selected: selected == TransactionTypeEntity.income,
          selectedColor: appColors.success.withValues(alpha: 0.2),
          onSelected: (_) => onChanged(TransactionTypeEntity.income),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Expense'),
          selected: selected == TransactionTypeEntity.expense,
          selectedColor: appColors.danger.withValues(alpha: 0.2),
          onSelected: (_) => onChanged(TransactionTypeEntity.expense),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.onDelete,
    this.onEdit,
  });

  final TransactionEntity transaction;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isIncome = transaction.type == TransactionTypeEntity.income;

    return Card(
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isIncome
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: isIncome
                      ? colors.success.withValues(alpha: 0.88)
                      : colors.danger.withValues(alpha: 0.88),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.category} • ${_formatDateTime(transaction.date)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${isIncome ? '+' : '-'}${CurrencyUtils.format(transaction.amount.abs())}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isIncome
                          ? colors.success.withValues(alpha: 0.88)
                          : colors.danger.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: colors.danger,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// helper to format date + time (same as in HomeShell)
String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year  $hour:$minute';
}

class _EmptyTransactionsView extends StatelessWidget {
  const _EmptyTransactionsView({
    required this.onAddTransaction,
  });

  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: appColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: appColors.textPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'No transactions found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your transaction history will appear here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddTransaction,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
