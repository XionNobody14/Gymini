import 'exercise.dart';

class Routine {
  final String id;
  final String name;
  final String? subtitle;
  final List<Exercise> exercises;
  final DateTime? lastPerformed;

  const Routine({
    required this.id,
    required this.name,
    required this.exercises,
    this.subtitle,
    this.lastPerformed,
  });

  /// Cantidad de ejercicios marcados con `completedWithEase == true` en la última sesión.
  int get overloadReadyCount =>
      exercises.where((e) => e.completedWithEase).length;

  /// Lista de ejercicios candidatos a sobrecarga progresiva.
  List<Exercise> get overloadCandidates =>
      exercises.where((e) => e.completedWithEase).toList(growable: false);

  Routine copyWith({
    String? id,
    String? name,
    String? subtitle,
    List<Exercise>? exercises,
    DateTime? lastPerformed,
    bool clearLastPerformed = false,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      exercises: exercises ?? this.exercises,
      lastPerformed:
          clearLastPerformed ? null : (lastPerformed ?? this.lastPerformed),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'lastPerformed': lastPerformed?.toIso8601String(),
    };
  }

  factory Routine.fromMap(Map<dynamic, dynamic> map) {
    final rawExercises = (map['exercises'] as List<dynamic>?) ?? const [];
    return Routine(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Rutina',
      subtitle: map['subtitle']?.toString(),
      exercises: rawExercises
          .whereType<Map<dynamic, dynamic>>()
          .map(Exercise.fromMap)
          .toList(),
      lastPerformed: map['lastPerformed'] != null
          ? DateTime.tryParse(map['lastPerformed'].toString())
          : null,
    );
  }
}
