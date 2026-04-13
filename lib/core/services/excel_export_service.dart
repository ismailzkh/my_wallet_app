import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExportService {
  ExcelExportService._();

  static final ExcelExportService instance = ExcelExportService._();

  Future<File> exportTable({
    required String fileName,
    required String sheetName,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];

    sheet.appendRow(
      headers.map<CellValue?>((value) => TextCellValue(value)).toList(),
    );

    for (final row in rows) {
      sheet.appendRow(
        row.map<CellValue?>((value) => TextCellValue(value)).toList(),
      );
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}