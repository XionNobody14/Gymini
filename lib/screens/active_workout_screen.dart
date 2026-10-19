import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../controllers/workout_controller.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/unit_converter.dart';
import '../theme/gymini_theme.dart';
import '../widgets/exercise_form_modal.dart';
import '../widgets/exercise_tracking_card.dart';
import '../widgets/progressive_overload_modal.dart';
import '../widgets/unit_toggle_pill.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Routine routine;

  const ActiveWorkoutScreen({
    super.key,
    required this.routine,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final Uuid _uuid = const Uuid();
  late List<Exercise> _sessionExercises;
  late Map<String, Exercise> _previousSessionSnapshot;
  late Set<String> _overloadCandidateIds;

  bool _highlightOverloadSuggestions = true;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // 1. Precarga automática de los pesos y repeticiones de la última sesión.
    // 2. Detección de ejercicios que tuvieron `completedWithEase == true` en la sesión previa.
    _previousSessionSnapshot = {
      for (final ex in widget.routine.exercises) ex.id: ex.copyWith(),
    };

    final candidates = widget.routine.exercises
        .where((ex) => ex.completedWithEase)
        .map((ex) => ex.copyWith())
        .toList(growable: false);

    _overloadCandidateIds = candidates.map((e) => e.id).toSet();

    // Inicializamos las tarjetas con los pesos y repeticiones precargados de la última sesión.
    // Reiniciamos `completedWithEase` en false para que el usuario marque cómo sintió la sesión de hoy.
    _sessionExercises = widget.routine.exercises
        .map(
          (ex) => ex.copyWith(
            completedWithEase: false,
          ),
        )
        .toList();

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });

    // Si existen ejercicios con `completedWithEase == true` en la sesión previa,
    // desplegamos automáticamente el pop-up "Sugerencia de Sobrecarga Progresiva".
    if (candidates.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _presentProgressiveOverloadPopup(candidates);
      });
    }
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  Future<void> _presentProgressiveOverloadPopup(
    List<Exercise> candidates,
  ) async {
    if (!mounted) return;
    final decision = await ProgressiveOverloadModal.show(
      context,
      routineName: widget.routine.name,
      candidateExercises: candidates,
    );
    if (!mounted) return;
    setState(() {
      _highlightOverloadSuggestions =
          decision != OverloadDecision.keepCurrentWeight;
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _convertAllSessionUnits(String targetUnit) {
    final normalized = UnitConverter.normalizeUnit(targetUnit);
    setState(() {
      _sessionExercises = _sessionExercises.map((ex) {
        final converted = ex.inUnit(normalized);
        return converted.copyWith(
          weight: UnitConverter.roundForInput(converted.weight),
        );
      }).toList();
    });
    context.read<WorkoutController>().setPreferredUnit(
          normalized,
          convertStoredExercises: true,
        );
  }

  Future<void> _addExerciseDuringSession() async {
    final controller = context.read<WorkoutController>();
    final result = await ExerciseFormModal.show(
      context,
      defaultUnit: controller.preferredUnit,
    );
    if (result == null || !mounted) return;

    final newExercise = Exercise(
      id: _uuid.v4(),
      name: result.name,
      targetReps: result.targetReps,
      weight: result.weight,
      unit: result.unit,
      completedWithEase: false,
      lastUpdated: DateTime.now(),
      sets: result.sets,
      muscleGroup: result.muscleGroup,
    );

    setState(() {
      _previousSessionSnapshot[newExercise.id] = newExercise;
      _sessionExercises = [..._sessionExercises, newExercise];
    });
  }

  Future<void> _finishWorkout() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    setState(() {
      _isSaving = true;
    });

    final controller = context.read<WorkoutController>();
    final record = await controller.completeWorkoutSession(
      routineId: widget.routine.id,
      sessionExercises: _sessionExercises,
      durationSeconds: _elapsedSeconds,
    );

    if (!mounted) return;
    final easyCount = record.completedWithEaseCount;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: GyminiTheme.mintOverload,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                easyCount > 0
                    ? 'Entrenamiento guardado · $easyCount ${easyCount == 1 ? 'ejercicio tendrá' : 'ejercicios tendrán'} sugerencia de sobrecarga en la próxima sesión.'
                    : 'Entrenamiento guardado. Los pesos y repeticiones se precargarán en tu próxima sesión.',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final preferredUnit = context.watch<WorkoutController>().preferredUnit;
    final currentOverloadCount =
        _sessionExercises.where((e) => e.completedWithEase).length;

    return Scaffold(
      backgroundColor: GyminiTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: GyminiTheme.scaffoldBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.routine.name,
              style: const TextStyle(
                color: GyminiTheme.textPrimary,
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: GyminiTheme.mintOverload,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sesión activa · ${_formatDuration(_elapsedSeconds)}',
                  style: const TextStyle(
                    color: GyminiTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_overloadCandidateIds.isNotEmpty)
            IconButton(
              tooltip: 'Ver sugerencias de sobrecarga progresiva',
              onPressed: () {
                final candidates = widget.routine.exercises
                    .where((e) => _overloadCandidateIds.contains(e.id))
                    .toList();
                _presentProgressiveOverloadPopup(candidates);
              },
              icon: const Icon(
                Icons.trending_up_rounded,
                color: GyminiTheme.mintOverload,
                size: 21,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: UnitTogglePill(
                currentUnit: preferredUnit,
                onUnitChanged: _convertAllSessionUnits,
                compact: true,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra informativa de precarga y estado de sobrecarga
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(18, 8, 18, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: GyminiTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: GyminiTheme.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history_toggle_off_rounded,
                  color: GyminiTheme.primaryLavender,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Pesos y repeticiones precargados de tu última sesión.',
                    style: TextStyle(
                      color: GyminiTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                if (currentOverloadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: GyminiTheme.sageSurfaceTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$currentOverloadCount con facilidad',
                      style: const TextStyle(
                        color: GyminiTheme.sageSuccess,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Lista de tarjetas de seguimiento por ejercicio
          Expanded(
            child: _sessionExercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            color: GyminiTheme.textSecondary,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Esta rutina aún no tiene ejercicios.',
                            style: TextStyle(
                              color: GyminiTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Añade tu primer ejercicio para registrar tus series y activar el motor de sobrecarga progresiva.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: GyminiTheme.textSecondary,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: _addExerciseDuringSession,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Añadir ejercicio'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                    itemCount: _sessionExercises.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == _sessionExercises.length) {
                        return OutlinedButton.icon(
                          onPressed: _addExerciseDuringSession,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: GyminiTheme.primaryLavender,
                            side: const BorderSide(
                              color: GyminiTheme.borderSubtle,
                              width: 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 19),
                          label: const Text(
                            'Añadir ejercicio a esta sesión',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }

                      final exercise = _sessionExercises[index];
                      final prev =
                          _previousSessionSnapshot[exercise.id] ?? exercise;
                      final wasOverloadCandidate =
                          _overloadCandidateIds.contains(exercise.id);

                      return ExerciseTrackingCard(
                        key: ValueKey(exercise.id),
                        index: index,
                        exercise: exercise,
                        previousSessionWeight: prev.weight,
                        previousSessionUnit: prev.unit,
                        previousSessionReps: prev.targetReps,
                        highlightOverloadSuggestion:
                            _highlightOverloadSuggestions &&
                                wasOverloadCandidate,
                        onChanged: (updated) {
                          setState(() {
                            _sessionExercises[index] = updated;
                          });
                        },
                      );
                    },
                  ),
          ),

          // Barra inferior fija: Botón "Finalizar Entrenamiento"
          Container(
            padding: EdgeInsets.fromLTRB(
              18,
              14,
              18,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: const BoxDecoration(
              color: GyminiTheme.scaffoldSecondary,
              border: Border(
                top: BorderSide(
                  color: GyminiTheme.borderSubtle,
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sessionExercises.isEmpty || _isSaving
                      ? null
                      : _finishWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GyminiTheme.primaryLavender,
                    foregroundColor: GyminiTheme.onPrimaryDark,
                    disabledBackgroundColor: GyminiTheme.surfaceElevated,
                    disabledForegroundColor: GyminiTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: Text(
                    _isSaving
                        ? 'Guardando sesión...'
                        : 'Finalizar Entrenamiento',
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
