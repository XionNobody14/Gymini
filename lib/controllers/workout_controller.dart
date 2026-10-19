import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/session_record.dart';
import '../services/overload_engine.dart';
import '../services/storage_service.dart';
import '../services/unit_converter.dart';

class WorkoutController extends ChangeNotifier {
  final StorageService _storageService;
  final OverloadEngine _overloadEngine;
  final Uuid _uuid = const Uuid();

  List<Routine> _routines = [];
  List<SessionRecord> _sessionHistory = [];
  String _preferredUnit = UnitConverter.kg;
  bool _isReady = false;

  WorkoutController({
    required StorageService storageService,
    OverloadEngine overloadEngine = const OverloadEngine(),
  })  : _storageService = storageService,
        _overloadEngine = overloadEngine;

  List<Routine> get routines => List.unmodifiable(_routines);
  List<SessionRecord> get sessionHistory => List.unmodifiable(_sessionHistory);
  String get preferredUnit => _preferredUnit;
  bool get isReady => _isReady;

  /// Total de ejercicios listos para sobrecarga progresiva en todas las rutinas.
  int get totalOverloadCandidatesCount => _routines.fold<int>(
        0,
        (sum, routine) => sum + routine.overloadReadyCount,
      );

  /// Rutina sugerida para el botón de acceso rápido "Entrenar Hoy".
  Routine? get recommendedRoutineForToday {
    if (_routines.isEmpty) return null;
    final withOverload = _routines.where((r) => r.overloadReadyCount > 0);
    if (withOverload.isNotEmpty) {
      return withOverload.first;
    }
    return _routines.first;
  }

  /// Calcula la racha activa de días consecutivos con entrenamiento completado.
  int get currentStreakDays {
    if (_sessionHistory.isEmpty) return 0;

    final uniqueDays = <DateTime>{};
    for (final session in _sessionHistory) {
      final d = session.performedAt;
      uniqueDays.add(DateTime(d.year, d.month, d.day));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime cursor;
    if (uniqueDays.contains(today)) {
      cursor = today;
    } else if (uniqueDays.contains(yesterday)) {
      cursor = yesterday;
    } else {
      return 0;
    }

    int streak = 0;
    while (uniqueDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Devuelve las sesiones realizadas en una fecha específica (año, mes, día).
  List<SessionRecord> sessionsForDay(DateTime day) {
    return _sessionHistory
        .where(
          (s) =>
              s.performedAt.year == day.year &&
              s.performedAt.month == day.month &&
              s.performedAt.day == day.day,
        )
        .toList(growable: false);
  }

  /// Devuelve la cantidad de días con asistencia en un mes determinado.
  int activeDaysInMonth(int year, int month) {
    final days = <int>{};
    for (final s in _sessionHistory) {
      if (s.performedAt.year == year && s.performedAt.month == month) {
        days.add(s.performedAt.day);
      }
    }
    return days.length;
  }

  Future<void> initialize() async {
    await _storageService.init();
    _preferredUnit = _storageService.getPreferredUnit();
    _routines = _storageService.loadRoutines();
    _sessionHistory = _storageService.loadSessionHistory();
    _isReady = true;
    notifyListeners();
  }

  Routine? getRoutineById(String routineId) {
    for (final routine in _routines) {
      if (routine.id == routineId) return routine;
    }
    return null;
  }

  /// Alterna o establece la unidad preferida ('kg' o 'lbs') y convierte
  /// matemáticamente (1 kg ≈ 2.20462 lbs) los ejercicios almacenados.
  Future<void> setPreferredUnit(
    String newUnit, {
    bool convertStoredExercises = true,
  }) async {
    final normalized = UnitConverter.normalizeUnit(newUnit);
    if (_preferredUnit == normalized && !convertStoredExercises) return;

    _preferredUnit = normalized;
    await _storageService.setPreferredUnit(normalized);

    if (convertStoredExercises) {
      final updatedRoutines = <Routine>[];
      for (final routine in _routines) {
        final convertedExercises = routine.exercises.map((exercise) {
          final converted = exercise.inUnit(normalized);
          return converted.copyWith(
            weight: UnitConverter.roundForInput(converted.weight),
          );
        }).toList();
        final updated = routine.copyWith(exercises: convertedExercises);
        updatedRoutines.add(updated);
        await _storageService.saveRoutine(updated);
      }
      _routines = updatedRoutines;
    }
    notifyListeners();
  }

  Future<void> togglePreferredUnit() async {
    final nextUnit = UnitConverter.toggleUnit(_preferredUnit);
    await setPreferredUnit(nextUnit, convertStoredExercises: true);
  }

  OverloadAssessment evaluateRoutine(String routineId) {
    final routine = getRoutineById(routineId);
    if (routine == null) {
      throw StateError('No se encontró la rutina con ID $routineId');
    }
    return _overloadEngine.evaluateRoutineForSession(routine);
  }

  Future<Routine> createRoutine({
    required String name,
    String? subtitle,
    List<Exercise>? initialExercises,
  }) async {
    final routine = Routine(
      id: _uuid.v4(),
      name: name.trim(),
      subtitle: (subtitle != null && subtitle.trim().isNotEmpty)
          ? subtitle.trim()
          : null,
      exercises: initialExercises ?? const [],
      lastPerformed: null,
    );
    await _storageService.saveRoutine(routine);
    _routines = [routine, ..._routines];
    notifyListeners();
    return routine;
  }

  Future<void> updateRoutine(Routine updatedRoutine) async {
    await _storageService.saveRoutine(updatedRoutine);
    final idx = _routines.indexWhere((r) => r.id == updatedRoutine.id);
    if (idx >= 0) {
      _routines[idx] = updatedRoutine;
      notifyListeners();
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    await _storageService.deleteRoutine(routineId);
    _routines.removeWhere((r) => r.id == routineId);
    notifyListeners();
  }

  Future<Exercise> addExerciseToRoutine({
    required String routineId,
    required String name,
    required double weight,
    required String unit,
    required int targetReps,
    int sets = 3,
    String? muscleGroup,
  }) async {
    final routine = getRoutineById(routineId);
    if (routine == null) {
      throw StateError('Rutina no encontrada: $routineId');
    }

    final exercise = Exercise(
      id: _uuid.v4(),
      name: name.trim(),
      targetReps: targetReps,
      weight: weight,
      unit: UnitConverter.normalizeUnit(unit),
      completedWithEase: false,
      lastUpdated: DateTime.now(),
      sets: sets,
      muscleGroup: (muscleGroup != null && muscleGroup.trim().isNotEmpty)
          ? muscleGroup.trim()
          : null,
    );

    final updatedRoutine = routine.copyWith(
      exercises: [...routine.exercises, exercise],
    );
    await updateRoutine(updatedRoutine);
    return exercise;
  }

  Future<void> updateExerciseInRoutine({
    required String routineId,
    required Exercise updatedExercise,
  }) async {
    final routine = getRoutineById(routineId);
    if (routine == null) return;

    final updatedList = routine.exercises.map((e) {
      if (e.id == updatedExercise.id) {
        return updatedExercise.copyWith(lastUpdated: DateTime.now());
      }
      return e;
    }).toList();

    await updateRoutine(routine.copyWith(exercises: updatedList));
  }

  Future<void> removeExerciseFromRoutine({
    required String routineId,
    required String exerciseId,
  }) async {
    final routine = getRoutineById(routineId);
    if (routine == null) return;

    final updatedList =
        routine.exercises.where((e) => e.id != exerciseId).toList();
    await updateRoutine(routine.copyWith(exercises: updatedList));
  }

  Future<SessionRecord> completeWorkoutSession({
    required String routineId,
    required List<Exercise> sessionExercises,
    required int durationSeconds,
  }) async {
    final routine = getRoutineById(routineId);
    if (routine == null) {
      throw StateError('Rutina no encontrada: $routineId');
    }

    final now = DateTime.now();
    final stampedExercises = sessionExercises
        .map(
          (e) => e.copyWith(
            unit: UnitConverter.normalizeUnit(e.unit),
            lastUpdated: now,
          ),
        )
        .toList();

    final updatedRoutine = routine.copyWith(
      exercises: stampedExercises,
      lastPerformed: now,
    );

    await _storageService.saveRoutine(updatedRoutine);
    final idx = _routines.indexWhere((r) => r.id == routineId);
    if (idx >= 0) {
      _routines[idx] = updatedRoutine;
    }

    final record = SessionRecord(
      id: _uuid.v4(),
      routineId: routine.id,
      routineName: routine.name,
      performedAt: now,
      durationSeconds: durationSeconds,
      exercises: stampedExercises,
    );
    await _storageService.saveSessionRecord(record);
    _sessionHistory = [record, ..._sessionHistory];

    notifyListeners();
    return record;
  }
}
