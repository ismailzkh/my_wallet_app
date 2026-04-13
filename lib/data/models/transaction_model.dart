enum TransactionType {
  income,
  expense,
}

enum RecurringInterval {
  daily,
  weekly,
  monthly,
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringInterval,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final RecurringInterval? recurringInterval;

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
    bool? isRecurring,
    RecurringInterval? recurringInterval,
  }) {
    return TransactionModel(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'isRecurring': isRecurring,
      'recurringInterval': recurringInterval?.name,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().toLowerCase();
    final rawDate = json['date']?.toString();
    final rawRecurringInterval =
        json['recurringInterval']?.toString().toLowerCase();

    return TransactionModel(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Untitled',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: rawType == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: json['category']?.toString() ?? 'General',
      date: rawDate != null
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : DateTime.now(),
      note: json['note']?.toString(),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringInterval: _parseRecurringInterval(rawRecurringInterval),
    );
  }

  static RecurringInterval? _parseRecurringInterval(String? value) {
    switch (value) {
      case 'daily':
        return RecurringInterval.daily;
      case 'weekly':
        return RecurringInterval.weekly;
      case 'monthly':
        return RecurringInterval.monthly;
      default:
        return null;
    }
  }
}