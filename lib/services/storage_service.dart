import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/session_record.dart';
import 'unit_converter.dart';

class StorageService {
  static const String _routinesBoxName = 'gymini_routines_box';
  static const String _sessionsBoxName = 'gymini_sessions_box';
  static const String _settingsBoxName = 'gymini_settings_box';

  static const String _keyPreferredUnit = 'preferred_unit';
  static const String _keySeedInitialized = 'seed_initialized_v2';

  late Box<dynamic> _routinesBox;
  late Box<dynamic> _sessionsBox;
  late Box<dynamic> _settingsBox;

  bool _isInitialized = false;

  Future<void> init({String? customStoragePath}) async {
    if (_isInitialized) return;
    if (!kIsWeb) {
      if (customStoragePath != null) {
        Hive.init(customStoragePath);
      } else {
        try {
          final dir = await getApplicationDocumentsDirectory();
          Hive.init(dir.path);
        } catch (_) {
          Hive.init(Directory.systemTemp.path);
        }
      }
    }
    _routinesBox = await Hive.openBox<dynamic>(_routinesBoxName);
    _sessionsBox = await Hive.openBox<dynamic>(_sessionsBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);

    final seeded =
        _settingsBox.get(_keySeedInitialized, defaultValue: false) == true;
    if (!seeded) {
      if (_routinesBox.isEmpty) {
        await _seedInitialData();
      } else if (_sessionsBox.isEmpty) {
        await _seedInitialSessionsFromRoutines();
      }
      await _settingsBox.put(_keySeedInitialized, true);
    }
    _isInitialized = true;
  }

  String getPreferredUnit() {
    if (!_isInitialized) return UnitConverter.kg;
    final raw =
        _settingsBox.get(_keyPreferredUnit, defaultValue: UnitConverter.kg);
    return UnitConverter.normalizeUnit(raw?.toString() ?? UnitConverter.kg);
  }

  Future<void> setPreferredUnit(String unit) async {
    await _settingsBox.put(
      _keyPreferredUnit,
      UnitConverter.normalizeUnit(unit),
    );
  }

  List<Routine> loadRoutines() {
    final routines = <Routine>[];
    for (final key in _routinesBox.keys) {
      final raw = _routinesBox.get(key);
      if (raw is Map) {
        routines.add(Routine.fromMap(raw));
      }
    }
    routines.sort((a, b) {
      final aDate = a.lastPerformed ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.lastPerformed ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return routines;
  }

  Future<void> saveRoutine(Routine routine) async {
    await _routinesBox.put(routine.id, routine.toMap());
  }

  Future<void> deleteRoutine(String routineId) async {
    await _routinesBox.delete(routineId);
  }

  List<SessionRecord> loadSessionHistory() {
    final records = <SessionRecord>[];
    for (final key in _sessionsBox.keys) {
      final raw = _sessionsBox.get(key);
      if (raw is Map) {
        records.add(SessionRecord.fromMap(raw));
      }
    }
    records.sort((a, b) => b.performedAt.compareTo(a.performedAt));
    return records;
  }

  Future<void> saveSessionRecord(SessionRecord record) async {
    await _sessionsBox.put(record.id, record.toMap());
  }

  Future<void> _seedInitialSessionsFromRoutines() async {
    const uuid = Uuid();
    final routines = loadRoutines();
    final now = DateTime.now();
    for (var i = 0; i < routines.length; i++) {
      final r = routines[i];
      final date = now.subtract(Duration(days: i + 1));
      await saveSessionRecord(
        SessionRecord(
          id: uuid.v4(),
          routineId: r.id,
          routineName: r.name,
          performedAt: DateTime(date.year, date.month, date.day, 18, 30),
          durationSeconds: 2850 + (i * 180),
          exercises: r.exercises,
        ),
      );
    }
  }

  Future<void> _seedInitialData() async {
    const uuid = Uuid();
    final now = DateTime.now();
    final oneDayAgo = DateTime(now.year, now.month, now.day, 19, 15)
        .subtract(const Duration(days: 1));
    final twoDaysAgo = DateTime(now.year, now.month, now.day, 18, 40)
        .subtract(const Duration(days: 2));
    final threeDaysAgo = DateTime(now.year, now.month, now.day, 18, 10)
        .subtract(const Duration(days: 3));

    final pushRoutine = Routine(
      id: uuid.v4(),
      name: 'Empuje (Push)',
      subtitle: 'Pectoral · Deltoides · Tríceps',
      lastPerformed: oneDayAgo,
      exercises: [
        Exercise(
          id: uuid.v4(),
          name: 'Press de Banca con Barra',
          targetReps: 8,
          weight: 80.0,
          unit: 'kg',
          completedWithEase: true,
          lastUpdated: oneDayAgo,
          sets: 4,
          muscleGroup: 'Pectoral Medio',
        ),
        Exercise(
          id: uuid.v4(),
          name: 'Press Inclinado con Mancuernas',
          targetReps: 10,
          weight: 30.0,
          unit: 'kg',
          completedWithEase: true,
          lastUpdated: oneDayAgo,
          sets: 3,
          muscleGroup: 'Pectoral Superior',
        ),
        Exercise(
          id: uuid.v4(),
          name: 'Press Militar de Pie (OHP)',
          targetReps: 8,
          weight: 50.0,
          unit: 'kg',
          completedWithEase: false,
          lastUpdated: oneDayAgo,
          sets: 3,
          muscleGroup: 'Hombros',
        ),
        Exercise(
          id: uuid.v4(),
          name: 'Elevaciones Laterales en Polea',
          targetReps: 14,
          weight: 12.5,
          unit: 'kg',
          completedWithEase: true,
          lastUpdated: oneDayAgo,
          sets: 4,
          muscleGroup: 'Deltoides Lateral',
        ),
      ],
    );

    final legRoutine = Routine(
      id: uuid.v4(),
      name: 'Pierna & Core',
      subtitle: 'Cuádriceps · Isquios · Glúteo · Core',
      lastPerformed: twoDaysAgo,
      exercises: [
        Exercise(
          id: uuid.v4(),
          name: 'Sentadilla Búlgara con Mancuernas',
          targetReps: 10,
          weight: 24.0,
          unit: 'kg',
          completedWithEase: true,
          lastUpdated: twoDaysAgo,
          sets: 3,
          muscleGroup: 'Cuádriceps / Glúteo',
        ),
        Exercise(
          id: uuid.v4(),
          name: 'Peso Muerto Rumano (RDL)',
          targetReps: 8,
          weight: 105.0,
          unit: 'kg',
          completedWithEase: false,
          lastUpdated: twoDaysAgo,
          sets: 4,
          muscleGroup: 'Isquiosurales',
        ),
        Exercise(
          id: uuid.v4(),
          name: 'Prensa Inclinada 45°',
          targetReps: 12,
          weight: 180.0,
          unit: 'kg',
          completedWithEase: true,
          lastUpdated: twoDaysAgo,
          sets: 3,
          muscleGroup: 'Cuádriceps',
        ),
      ],
    );

    final pullRoutine = Routine(
      id: uuid.v4(),
      name: 'Tracción (Pull)',
      subtitle: 'Dorsal · Espalda Alta · Bíceps',
      lastPerformed: threeDaysAgo,
      exercises: [
        Exercise(
          id: uuid.v4(),
          name: 'Dominadas con Lastre',
          targetReps: 8,
          weight: 15.0,
          unit: 'kg',
          completedWithEase: true,
          lastUpdated: threeDaysAgo,
          sets: 4,
          muscleGroup: 'Dorsal Ancho',
        ),
        Exercise(
          id: uuid.v4(),
          name: 'Remo con Barra Pendlay',
          targetReps: 8,
          weight: 75.0,
          unit: 'kg',
          completedWithEase: false,
          lastUpdated: threeDaysAgo,
          sets: 4,
          muscleGroup: 'Espalda Media',
        ),
        Exercise(
          id: uuid.v4(),
          name: 'Curl de Bíceps Inclinado',
          targetReps: 12,
          weight: 16.0,
          unit: 'kg',
          completedWithEase: true,
          lastUpdated: threeDaysAgo,
          sets: 3,
          muscleGroup: 'Bíceps Braquial',
        ),
      ],
    );

    await saveRoutine(pushRoutine);
    await saveRoutine(legRoutine);
    await saveRoutine(pullRoutine);

    // Semilla de historial para mostrar rachas y calendario activos desde el primer uso
    await saveSessionRecord(
      SessionRecord(
        id: uuid.v4(),
        routineId: pushRoutine.id,
        routineName: pushRoutine.name,
        performedAt: oneDayAgo,
        durationSeconds: 3120,
        exercises: pushRoutine.exercises,
      ),
    );
    await saveSessionRecord(
      SessionRecord(
        id: uuid.v4(),
        routineId: legRoutine.id,
        routineName: legRoutine.name,
        performedAt: twoDaysAgo,
        durationSeconds: 3420,
        exercises: legRoutine.exercises,
      ),
    );
    await saveSessionRecord(
      SessionRecord(
        id: uuid.v4(),
        routineId: pullRoutine.id,
        routineName: pullRoutine.name,
        performedAt: threeDaysAgo,
        durationSeconds: 2940,
        exercises: pullRoutine.exercises,
      ),
    );
  }
}
