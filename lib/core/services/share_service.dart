import 'dart:io';

import 'package:share_plus/share_plus.dart';

/// Handles sharing files or text via the system share sheet.
class ShareService {
  ShareService._();

  static final ShareService instance = ShareService._();

  /// Share a text message (e.g. summary or report) via OS share sheet.
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Share a single file (e.g. PDF or Excel export).
  Future<void> shareFile(File file, {String? subject, String? text}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: text,
    );
  }

  /// Share multiple files at once if needed.
  Future<void> shareFiles(List<File> files,
      {String? subject, String? text}) async {
    final xFiles = files.map((f) => XFile(f.path)).toList();
    await Share.shareXFiles(
      xFiles,
      subject: subject,
      text: text,
    );
  }
}