import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../domain/entities/app_entities.dart';
import '../../controllers/app_controllers.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({
    super.key,
    required this.controller,
  });

  final TransactionsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final recurring = controller.transactions
            .where((t) => t.isRecurring)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Recurring Transactions'),
          ),
          body: recurring.isEmpty
              ? const Center(
                  child: Text('No recurring transactions found'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: recurring.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final transaction = recurring[index];
                    final isIncome =
                        transaction.type == TransactionTypeEntity.income;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.repeat_rounded,
                                color: isIncome
                                    ? Theme.of(context)
                                        .extension<AppColors>()!
                                        .success
                                    : Theme.of(context)
                                        .extension<AppColors>()!
                                        .danger,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.title,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(transaction.category),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyUtils.format(transaction.amount),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _intervalText(transaction.recurringInterval),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await controller.deleteTransaction(
                                  transaction.id,
                                );
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  String _intervalText(RecurringIntervalEntity? interval) {
    switch (interval) {
      case RecurringIntervalEntity.daily:
        return 'Daily';
      case RecurringIntervalEntity.weekly:
        return 'Weekly';
      case RecurringIntervalEntity.monthly:
        return 'Monthly';
      default:
        return 'Recurring';
    }
  }
}