class FileHelpers {
  static String fileNameFromDate(String prefix, String extension) {
    final now = DateTime.now();
    return '${prefix}_${now.year}_${now.month}_${now.day}.$extension';
  }
}