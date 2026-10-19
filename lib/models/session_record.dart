import 'exercise.dart';

class SessionRecord {
  final String id;
  final String routineId;
  final String routineName;
  final DateTime performedAt;
  final int durationSeconds;
  final List<Exercise> exercises;

  const SessionRecord({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.performedAt,
    required this.durationSeconds,
    required this.exercises,
  });

  int get completedWithEaseCount =>
      exercises.where((e) => e.completedWithEase).length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'routineName': routineName,
      'performedAt': performedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory SessionRecord.fromMap(Map<dynamic, dynamic> map) {
    final rawExercises = (map['exercises'] as List<dynamic>?) ?? const [];
    return SessionRecord(
      id: map['id']?.toString() ?? '',
      routineId: map['routineId']?.toString() ?? '',
      routineName: map['routineName']?.toString() ?? '',
      performedAt: map['performedAt'] != null
          ? DateTime.tryParse(map['performedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      exercises: rawExercises
          .whereType<Map<dynamic, dynamic>>()
          .map(Exercise.fromMap)
          .toList(),
    );
  }
}
