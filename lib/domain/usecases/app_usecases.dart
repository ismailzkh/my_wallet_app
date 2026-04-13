import '../entities/app_entities.dart';
import '../repositories/app_repositories.dart';

class GetTransactionsUseCase {
  final TransactionsRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call() {
    return repository.getTransactions();
  }
}

class AddTransactionUseCase {
  final TransactionsRepository repository;

  AddTransactionUseCase(this.repository);

  Future<void> call(TransactionEntity transaction) {
    return repository.addTransaction(transaction);
  }
}

class DeleteTransactionUseCase {
  final TransactionsRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteTransaction(id);
  }
}

class UpdateTransactionUseCase {
  final TransactionsRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<void> call(TransactionEntity transaction) {
    return repository.updateTransaction(transaction);
  }
}

class GetTotalBalanceUseCase {
  final TransactionsRepository repository;

  GetTotalBalanceUseCase(this.repository);

  double call() {
    return repository.getTotalBalance();
  }
}

class GetTotalIncomeUseCase {
  final TransactionsRepository repository;

  GetTotalIncomeUseCase(this.repository);

  double call() {
    return repository.getTotalIncome();
  }
}

class GetTotalExpenseUseCase {
  final TransactionsRepository repository;

  GetTotalExpenseUseCase(this.repository);

  double call() {
    return repository.getTotalExpense();
  }
}
