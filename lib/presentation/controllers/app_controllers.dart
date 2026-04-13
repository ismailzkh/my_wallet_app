import 'package:flutter/foundation.dart';

import '../../domain/entities/app_entities.dart';
import '../../domain/usecases/app_usecases.dart';

class TransactionsController extends ChangeNotifier {
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final GetTotalBalanceUseCase getTotalBalanceUseCase;
  final GetTotalIncomeUseCase getTotalIncomeUseCase;
  final GetTotalExpenseUseCase getTotalExpenseUseCase;

  TransactionsController({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.getTotalBalanceUseCase,
    required this.getTotalIncomeUseCase,
    required this.getTotalExpenseUseCase,
  });

  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBalance => getTotalBalanceUseCase();
  double get totalIncome => getTotalIncomeUseCase();
  double get totalExpense => getTotalExpenseUseCase();

  Future<void> loadTransactions() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _transactions = await getTransactionsUseCase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      await addTransactionUseCase(transaction);
      await loadTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await deleteTransactionUseCase(id);
      await loadTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      await updateTransactionUseCase(transaction);
      await loadTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
