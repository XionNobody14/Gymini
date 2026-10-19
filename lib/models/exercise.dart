import '../services/unit_converter.dart';

class Exercise {
  final String id;
  final String name;
  final int targetReps;
  final double weight;
  final String unit; // 'kg' o 'lbs'
  final bool completedWithEase;
  final DateTime lastUpdated;
  final int sets;
  final String? muscleGroup;

  const Exercise({
    required this.id,
    required this.name,
    required this.targetReps,
    required this.weight,
    required this.unit,
    required this.completedWithEase,
    required this.lastUpdated,
    this.sets = 3,
    this.muscleGroup,
  });

  /// Devuelve una copia del ejercicio con el peso convertido a la unidad destino
  /// aplicando la relación matemática 1 kg = 2.20462 lbs.
  Exercise inUnit(String targetUnit) {
    final normalizedTarget = UnitConverter.normalizeUnit(targetUnit);
    final normalizedCurrent = UnitConverter.normalizeUnit(unit);
    if (normalizedCurrent == normalizedTarget) {
      return this;
    }
    final convertedWeight = UnitConverter.convert(
      weight,
      from: normalizedCurrent,
      to: normalizedTarget,
    );
    return copyWith(
      weight: convertedWeight,
      unit: normalizedTarget,
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    int? targetReps,
    double? weight,
    String? unit,
    bool? completedWithEase,
    DateTime? lastUpdated,
    int? sets,
    String? muscleGroup,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      targetReps: targetReps ?? this.targetReps,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      completedWithEase: completedWithEase ?? this.completedWithEase,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sets: sets ?? this.sets,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetReps': targetReps,
      'weight': weight,
      'unit': UnitConverter.normalizeUnit(unit),
      'completedWithEase': completedWithEase,
      'lastUpdated': lastUpdated.toIso8601String(),
      'sets': sets,
      'muscleGroup': muscleGroup,
    };
  }

  factory Exercise.fromMap(Map<dynamic, dynamic> map) {
    return Exercise(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Ejercicio',
      targetReps: (map['targetReps'] as num?)?.toInt() ?? 8,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      unit: UnitConverter.normalizeUnit(map['unit']?.toString() ?? 'kg'),
      completedWithEase: map['completedWithEase'] == true,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      muscleGroup: map['muscleGroup']?.toString(),
    );
  }
}
