class MathHelpers {
  static double percent(double current, double total) {
    if (total == 0) return 0;
    return (current / total) * 100;
  }

  static double remaining(double total, double paid) {
    return total - paid;
  }

  static double sum(List<double> values) {
    return values.fold(0, (a, b) => a + b);
  }
}