class UnitConverter {
  UnitConverter._();

  /// Factor de conversión matemático requerido: 1 kg ≈ 2.20462 lbs.
  static const double kgToLbsFactor = 2.20462;

  static const String kg = 'kg';
  static const String lbs = 'lbs';

  /// Normaliza cualquier entrada de unidad a 'kg' o 'lbs'.
  static String normalizeUnit(String rawUnit) {
    final cleaned = rawUnit.trim().toLowerCase();
    if (cleaned == 'lbs' || cleaned == 'lb' || cleaned == 'libras') {
      return lbs;
    }
    return kg;
  }

  /// Alterna entre 'kg' y 'lbs'.
  static String toggleUnit(String currentUnit) {
    return normalizeUnit(currentUnit) == kg ? lbs : kg;
  }

  /// Convierte un peso entre 'kg' y 'lbs' con precisión matemática.
  static double convert(
    double value, {
    required String from,
    required String to,
  }) {
    final source = normalizeUnit(from);
    final target = normalizeUnit(to);

    if (source == target) {
      return value;
    }
    if (source == kg && target == lbs) {
      return value * kgToLbsFactor;
    }
    if (source == lbs && target == kg) {
      return value / kgToLbsFactor;
    }
    return value;
  }

  /// Convierte a kilogramos desde la unidad indicada.
  static double toKg(double value, String fromUnit) =>
      convert(value, from: fromUnit, to: kg);

  /// Convierte a libras desde la unidad indicada.
  static double toLbs(double value, String fromUnit) =>
      convert(value, from: fromUnit, to: lbs);

  /// Redondea a 1 decimal limpio para campos de entrada tras una conversión.
  static double roundForInput(double value) {
    return (value * 10).roundToDouble() / 10.0;
  }

  /// Formatea el peso para mostrar sin '.0' innecesario (ej. 80 o 82.5).
  static String formatWeight(double value) {
    final rounded = roundForInput(value);
    if ((rounded - rounded.roundToDouble()).abs() < 0.001) {
      return rounded.toInt().toString();
    }
    return rounded.toStringAsFixed(1);
  }

  /// Incremento táctil sugerido al usar botones +/- según la unidad activa.
  static double stepForUnit(String unit) {
    return normalizeUnit(unit) == kg ? 2.5 : 5.0;
  }
}
