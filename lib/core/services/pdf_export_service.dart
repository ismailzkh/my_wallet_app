import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

/// Exports simple PDF reports (e.g. transactions summary, debts, etc.).
class PdfExportService {
  PdfExportService._();

  static final PdfExportService instance = PdfExportService._();

  /// Generate a basic PDF with given title and lines of text.
  Future<File> generateSimplePdf({
    required String fileName,
    required String title,
    required List<String> lines,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          ...lines.map(
            (line) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(line),
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }
}