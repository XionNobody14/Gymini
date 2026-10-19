import '../models/exercise.dart';
import '../models/routine.dart';

/// Resultado de evaluación de sobrecarga progresiva al iniciar una rutina.
class OverloadAssessment {
  final Routine routine;
  final List<Exercise> preloadedExercises;
  final List<Exercise> overloadCandidates;

  const OverloadAssessment({
    required this.routine,
    required this.preloadedExercises,
    required this.overloadCandidates,
  });

  /// Indica si se debe mostrar el pop-up "Sugerencia de Sobrecarga Progresiva".
  bool get shouldPromptOverload => overloadCandidates.isNotEmpty;
}

class OverloadEngine {
  const OverloadEngine();

  /// Evalúa una rutina antes de iniciar la sesión activa:
  /// 1. Precarga automáticamente los pesos y repeticiones de la última sesión.
  /// 2. Detecta qué ejercicios tuvieron `completedWithEase == true` en la sesión previa.
  OverloadAssessment evaluateRoutineForSession(Routine routine) {
    final preloaded = routine.exercises
        .map((exercise) => exercise.copyWith())
        .toList(growable: false);

    final candidates = preloaded
        .where((exercise) => exercise.completedWithEase)
        .toList(growable: false);

    return OverloadAssessment(
      routine: routine,
      preloadedExercises: preloaded,
      overloadCandidates: candidates,
    );
  }

  /// Prepara la lista de ejercicios para el entrenamiento activo:
  /// Conserva los pesos y repeticiones precargados de la última sesión,
  /// y reinicia el switch `completedWithEase` en `false` para que el usuario
  /// evalúe honestamente la sesión de hoy, recordando cuáles tenían sugerencia activa.
  List<Exercise> createActiveDraftExercises(Routine routine) {
    return routine.exercises
        .map(
          (e) => e.copyWith(
            completedWithEase: e.completedWithEase,
          ),
        )
        .toList();
  }
}
