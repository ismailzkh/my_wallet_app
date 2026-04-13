import 'dart:convert';

import '../constants/storage_keys.dart';
import 'file_service.dart';
import 'local_storage_service.dart';

/// Handles creating and restoring local backup bundles.
/// Everything is stored/exported locally (no cloud, no account).
class BackupService {
  BackupService._();

  static final BackupService instance = BackupService._();

  final _storage = LocalStorageService.instance;
  final _fileService = FileService.instance;

  /// Create a JSON string representing all important boxes.
  Future<String> createBackupJson() async {
    // Each "box" here is just JSON in SharedPreferences keyed by StorageKeys.
    final data = <String, dynamic>{
      StorageKeys.accounts: _storage.getJson(StorageKeys.accounts),
      StorageKeys.transactions: _storage.getJson(StorageKeys.transactions),
      StorageKeys.categories: _storage.getJson(StorageKeys.categories),
      StorageKeys.budgets: _storage.getJson(StorageKeys.budgets),
      StorageKeys.debts: _storage.getJson(StorageKeys.debts),
      StorageKeys.goals: _storage.getJson(StorageKeys.goals),
      StorageKeys.settings: _storage.getJson(StorageKeys.settings),
    };

    return jsonEncode(data);
  }

  /// Save backup to a local file (e.g. for manual export/share later).
  Future<String> saveBackupToFile(String fileName) async {
    final json = await createBackupJson();
    await _fileService.writeString(fileName: fileName, contents: json);
    return fileName;
  }

  /// Load backup JSON from a string and restore into local storage.
  Future<void> restoreBackupFromJson(String json) async {
    final decoded = jsonDecode(json) as Map<String, dynamic>;

    if (decoded.containsKey(StorageKeys.accounts)) {
      await _storage.setJson(StorageKeys.accounts, decoded[StorageKeys.accounts]);
    }
    if (decoded.containsKey(StorageKeys.transactions)) {
      await _storage.setJson(
        StorageKeys.transactions,
        decoded[StorageKeys.transactions],
      );
    }
    if (decoded.containsKey(StorageKeys.categories)) {
      await _storage.setJson(
        StorageKeys.categories,
        decoded[StorageKeys.categories],
      );
    }
    if (decoded.containsKey(StorageKeys.budgets)) {
      await _storage.setJson(StorageKeys.budgets, decoded[StorageKeys.budgets]);
    }
    if (decoded.containsKey(StorageKeys.debts)) {
      await _storage.setJson(StorageKeys.debts, decoded[StorageKeys.debts]);
    }
    if (decoded.containsKey(StorageKeys.goals)) {
      await _storage.setJson(StorageKeys.goals, decoded[StorageKeys.goals]);
    }
    if (decoded.containsKey(StorageKeys.settings)) {
      await _storage.setJson(StorageKeys.settings, decoded[StorageKeys.settings]);
    }
  }

  /// Load backup JSON from file and restore into local storage.
  Future<void> restoreBackupFromFile(String fileName) async {
    final content = await _fileService.readString(fileName);
    if (content == null) {
      throw Exception('Backup file not found or empty: $fileName');
    }
    await restoreBackupFromJson(content);
  }
}