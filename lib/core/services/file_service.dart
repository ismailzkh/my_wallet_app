import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Handles reading/writing simple files in the app's documents directory.
/// Used for exports, backups, and other local-only files.
class FileService {
  FileService._();

  static final FileService instance = FileService._();

  /// Get the app's documents directory path.
  Future<Directory> _getDocumentsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  /// Build a file reference inside the app documents directory.
  Future<File> _fileInDocuments(String fileName) async {
    final dir = await _getDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Write raw string content to a file (overwrites if exists).
  Future<File> writeString({
    required String fileName,
    required String contents,
  }) async {
    final file = await _fileInDocuments(fileName);
    return file.writeAsString(contents, flush: true);
  }

  /// Read raw string content from a file.
  Future<String?> readString(String fileName) async {
    try {
      final file = await _fileInDocuments(fileName);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  /// Write binary bytes to a file.
  Future<File> writeBytes({
    required String fileName,
    required List<int> bytes,
  }) async {
    final file = await _fileInDocuments(fileName);
    return file.writeAsBytes(bytes, flush: true);
  }

  /// Read binary bytes from a file.
  Future<List<int>?> readBytes(String fileName) async {
    try {
      final file = await _fileInDocuments(fileName);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// Delete a file by name.
  Future<bool> delete(String fileName) async {
    try {
      final file = await _fileInDocuments(fileName);
      if (!await file.exists()) return true;
      await file.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check if a file exists.
  Future<bool> exists(String fileName) async {
    final file = await _fileInDocuments(fileName);
    return file.exists();
  }
}