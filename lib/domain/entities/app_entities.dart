enum TransactionTypeEntity {
  income,
  expense,
}

enum RecurringIntervalEntity {
  daily,
  weekly,
  monthly,
}

class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final TransactionTypeEntity type;
  final String category;
  final DateTime date;
  final String note;
  final bool isRecurring;
  final RecurringIntervalEntity? recurringInterval;
  final bool isRecurringActive; 

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
    this.isRecurring = false,
    this.recurringInterval,
    this.isRecurringActive = true,
  });
  

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionTypeEntity? type,
    String? category,
    DateTime? date,
    String? note,
    bool? isRecurring,
    RecurringIntervalEntity? recurringInterval,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
    );
  }
}