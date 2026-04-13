import '../../domain/entities/app_entities.dart';
import '../../domain/repositories/app_repositories.dart';
import '../datasources/local_datasources.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  const TransactionsRepositoryImpl();

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final models = await TransactionsDataSource.fetchTransactions();

    return models
        .map(
          (transaction) => TransactionEntity(
            id: transaction.id,
            title: transaction.title,
            amount: transaction.amount,
            type: transaction.type == TransactionType.income
                ? TransactionTypeEntity.income
                : TransactionTypeEntity.expense,
            category: transaction.category,
            date: transaction.date,
            note: transaction.note ?? '',
            isRecurring: transaction.isRecurring,
            recurringInterval: _mapRecurringIntervalFromModel(
              transaction.recurringInterval,
            ),
          ),
        )
        .toList();
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      type: transaction.type == TransactionTypeEntity.income
          ? TransactionType.income
          : TransactionType.expense,
      category: transaction.category,
      date: transaction.date,
      note: transaction.note,
      isRecurring: transaction.isRecurring,
      recurringInterval: _mapRecurringIntervalToModel(
        transaction.recurringInterval,
      ),
    );

    await TransactionsDataSource.addTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await TransactionsDataSource.deleteTransaction(id);
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      type: transaction.type == TransactionTypeEntity.income
          ? TransactionType.income
          : TransactionType.expense,
      category: transaction.category,
      date: transaction.date,
      note: transaction.note,
      isRecurring: transaction.isRecurring,
      recurringInterval: _mapRecurringIntervalToModel(
        transaction.recurringInterval,
      ),
    );

    await TransactionsDataSource.updateTransaction(model);
  }

  @override
  double getTotalBalance() {
    return TransactionsDataSource.getTotalBalance();
  }

  @override
  double getTotalIncome() {
    return TransactionsDataSource.getTotalIncome();
  }

  @override
  double getTotalExpense() {
    return TransactionsDataSource.getTotalExpense();
  }

  RecurringIntervalEntity? _mapRecurringIntervalFromModel(
    RecurringInterval? interval,
  ) {
    switch (interval) {
      case RecurringInterval.daily:
        return RecurringIntervalEntity.daily;
      case RecurringInterval.weekly:
        return RecurringIntervalEntity.weekly;
      case RecurringInterval.monthly:
        return RecurringIntervalEntity.monthly;
      case null:
        return null;
    }
  }

  RecurringInterval? _mapRecurringIntervalToModel(
    RecurringIntervalEntity? interval,
  ) {
    switch (interval) {
      case RecurringIntervalEntity.daily:
        return RecurringInterval.daily;
      case RecurringIntervalEntity.weekly:
        return RecurringInterval.weekly;
      case RecurringIntervalEntity.monthly:
        return RecurringInterval.monthly;
      case null:
        return null;
    }
  }
}