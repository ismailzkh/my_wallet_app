import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

class TransactionsDataSource {
  TransactionsDataSource._();

  static const String _transactionsKey = 'transactions';

  static final List<TransactionModel> _transactions = [];

  static Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_transactionsKey);

    _transactions.clear();

    if (savedList == null || savedList.isEmpty) {
      return;
    }

    final items = savedList
        .map((item) => TransactionModel.fromJson(jsonDecode(item)))
        .toList();

    _transactions.addAll(items);
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        _transactions.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList(_transactionsKey, encoded);
  }

  static Future<List<TransactionModel>> fetchTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _loadFromStorage();
    await _generateRecurringTransactionsIfNeeded();
    return List.unmodifiable(_transactions);
  }

  static List<TransactionModel> getTransactions() {
    return List.unmodifiable(_transactions);
  }

  static Future<void> addTransaction(TransactionModel transaction) async {
    await _loadFromStorage();
    _transactions.insert(0, transaction);
    await _saveToStorage();
  }

  static Future<void> deleteTransaction(String id) async {
    await _loadFromStorage();
    _transactions.removeWhere((item) => item.id == id);
    await _saveToStorage();
  }

  static Future<void> updateTransaction(TransactionModel updated) async {
    await _loadFromStorage();
    final index = _transactions.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      await _saveToStorage();
    }
  }

  static double getTotalBalance() {
    double income = 0;
    double expense = 0;

    for (final item in _transactions) {
      if (item.type == TransactionType.income) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    return income - expense;
  }

  static double getTotalIncome() {
    return _transactions
        .where((item) => item.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  static double getTotalExpense() {
    return _transactions
        .where((item) => item.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  static Future<void> _generateRecurringTransactionsIfNeeded() async {
    bool changed = false;
    final now = DateTime.now();

    final recurringTemplates = _transactions
        .where((item) => item.isRecurring && item.recurringInterval != null)
        .toList();

    for (final template in recurringTemplates) {
      DateTime nextDate = template.date;

      while (_shouldGenerateAnotherOccurrence(
        nextDate: nextDate,
        now: now,
        interval: template.recurringInterval!,
      )) {
        nextDate = _nextDate(nextDate, template.recurringInterval!);

        final alreadyExists = _transactions.any(
          (item) =>
              item.id != template.id &&
              item.title == template.title &&
              item.amount == template.amount &&
              item.type == template.type &&
              item.category == template.category &&
              _isSameDay(item.date, nextDate),
        );

        if (!alreadyExists && !nextDate.isAfter(now)) {
          final generated = template.copyWith(
            id: '${template.id}_${nextDate.millisecondsSinceEpoch}',
            date: nextDate,
            isRecurring: false,
            recurringInterval: null,
          );

          _transactions.add(generated);
          changed = true;
        }
      }
    }

    if (changed) {
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      await _saveToStorage();
    }
  }

  static bool _shouldGenerateAnotherOccurrence({
    required DateTime nextDate,
    required DateTime now,
    required RecurringInterval interval,
  }) {
    final candidate = _nextDate(nextDate, interval);
    return !candidate.isAfter(now);
  }

  static DateTime _nextDate(DateTime date, RecurringInterval interval) {
    switch (interval) {
      case RecurringInterval.daily:
        return date.add(const Duration(days: 1));
      case RecurringInterval.weekly:
        return date.add(const Duration(days: 7));
      case RecurringInterval.monthly:
        return DateTime(
          date.year,
          date.month + 1,
          date.day,
          date.hour,
          date.minute,
          date.second,
          date.millisecond,
          date.microsecond,
        );
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}