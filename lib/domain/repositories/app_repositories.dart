import '../entities/app_entities.dart';

abstract class TransactionsRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<void> updateTransaction(TransactionEntity transaction);
  double getTotalBalance();
  double getTotalIncome();
  double getTotalExpense();
}
