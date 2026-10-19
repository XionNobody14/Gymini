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
import 'active_workout_screen.dart';

class RoutineEditorScreen extends StatefulWidget {
  final Routine? existingRoutine;

  const RoutineEditorScreen({
    super.key,
    this.existingRoutine,
  });

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  late final TextEditingController _nameController;
  late final TextEditingController _subtitleController;
  late List<Exercise> _exercises;

  bool get _isEditing => widget.existingRoutine != null;

  @override
  void initState() {
    super.initState();
    final routine = widget.existingRoutine;
    _nameController = TextEditingController(text: routine?.name ?? '');
    _subtitleController =
        TextEditingController(text: routine?.subtitle ?? '');
    _exercises = routine != null
        ? routine.exercises.map((e) => e.copyWith()).toList()
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _openExerciseModal({Exercise? existing, int? index}) async {
    final defaultUnit = context.read<WorkoutController>().preferredUnit;
    final result = await ExerciseFormModal.show(
      context,
      initialExercise: existing,
      defaultUnit: defaultUnit,
    );
    if (result == null || !mounted) return;

    setState(() {
      if (existing != null && index != null) {
        _exercises[index] = existing.copyWith(
          name: result.name,
          weight: result.weight,
          unit: result.unit,
          targetReps: result.targetReps,
          sets: result.sets,
          muscleGroup: result.muscleGroup,
          lastUpdated: DateTime.now(),
        );
      } else {
        _exercises.add(
          Exercise(
            id: _uuid.v4(),
            name: result.name,
            targetReps: result.targetReps,
            weight: result.weight,
            unit: result.unit,
            completedWithEase: false,
            lastUpdated: DateTime.now(),
            sets: result.sets,
            muscleGroup: result.muscleGroup,
          ),
        );
      }
    });
  }

  Future<Routine?> _saveRoutineInternal() async {
    if (!_formKey.currentState!.validate()) return null;
    HapticFeedback.lightImpact();

    final controller = context.read<WorkoutController>();
    final name = _nameController.text.trim();
    final subtitle = _subtitleController.text.trim();

    if (_isEditing) {
      final updated = widget.existingRoutine!.copyWith(
        name: name,
        subtitle: subtitle.isNotEmpty ? subtitle : null,
        exercises: _exercises,
      );
      await controller.updateRoutine(updated);
      return updated;
    } else {
      final created = await controller.createRoutine(
        name: name,
        subtitle: subtitle.isNotEmpty ? subtitle : null,
        initialExercises: _exercises,
      );
      return created;
    }
  }

  Future<void> _saveAndClose() async {
    final saved = await _saveRoutineInternal();
    if (saved != null && mounted) {
      Navigator.of(context).pop(saved);
    }
  }

  Future<void> _saveAndStartWorkout() async {
    final saved = await _saveRoutineInternal();
    if (saved == null || !mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ActiveWorkoutScreen(routine: saved),
      ),
    );
  }

  Future<void> _confirmDeleteRoutine() async {
    final existing = widget.existingRoutine;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GyminiTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: GyminiTheme.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Eliminar rutina',
          style: TextStyle(
            color: GyminiTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Deseas eliminar "${existing.name}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: GyminiTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: GyminiTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: GyminiTheme.dangerCoral,
              foregroundColor: GyminiTheme.onPrimaryDark,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<WorkoutController>().deleteRoutine(existing.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GyminiTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: GyminiTheme.scaffoldBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Configurar Rutina' : 'Nueva Rutina',
          style: const TextStyle(
            color: GyminiTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _confirmDeleteRoutine,
              tooltip: 'Eliminar rutina',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: GyminiTheme.dangerCoral,
                size: 21,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _saveAndClose,
              style: TextButton.styleFrom(
                foregroundColor: GyminiTheme.primaryLavender,
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          children: [
            // Tarjeta de datos generales de la rutina
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: GyminiTheme.surfaceCard,
                borderRadius: BorderRadius.circular(GyminiTheme.cardRadius),
                border: Border.all(
                  color: GyminiTheme.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IDENTIDAD DE LA RUTINA',
                    style: TextStyle(
                      color: GyminiTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: GyminiTheme.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la rutina',
                      hintText: 'Ej. Empuje (Push), Pierna & Core',
                      prefixIcon: Icon(
                        Icons.bolt_rounded,
                        color: GyminiTheme.primaryLavender,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa un nombre para la rutina';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subtitleController,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: GyminiTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Enfoque muscular o nota (opcional)',
                      hintText: 'Ej. Pectoral · Hombro · Tríceps',
                      prefixIcon: Icon(
                        Icons.notes_rounded,
                        color: GyminiTheme.textSecondary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Cabecera de lista de ejercicios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ejercicios de la Rutina',
                      style: TextStyle(
                        color: GyminiTheme.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_exercises.length} ${_exercises.length == 1 ? 'ejercicio configurado' : 'ejercicios configurados'}',
                      style: const TextStyle(
                        color: GyminiTheme.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _openExerciseModal(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GyminiTheme.primaryLavender,
                    side: const BorderSide(
                      color: GyminiTheme.borderActiveLavender,
                      width: 1.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Añadir Ejercicio',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_exercises.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: GyminiTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(GyminiTheme.cardRadius),
                  border: Border.all(
                    color: GyminiTheme.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_chart_rounded,
                      color: GyminiTheme.textSecondary,
                      size: 34,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sin ejercicios añadidos',
                      style: TextStyle(
                        color: GyminiTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Agrega ejercicios indicando su peso inicial, unidad (KG o LBS) y repeticiones objetivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: GyminiTheme.textSecondary,
                        fontSize: 12.8,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _openExerciseModal(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Crear primer ejercicio'),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_exercises.length, (index) {
                final ex = _exercises[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GyminiTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ex.completedWithEase
                            ? GyminiTheme.sageSuccess.withOpacity(0.4)
                            : GyminiTheme.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: GyminiTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: GyminiTheme.primaryLavender,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: const TextStyle(
                                  color: GyminiTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${UnitConverter.formatWeight(ex.weight)} ${ex.unit.toUpperCase()} · ${ex.targetReps} reps · ${ex.sets} series'
                                '${ex.muscleGroup != null ? ' · ${ex.muscleGroup}' : ''}',
                                style: const TextStyle(
                                  color: GyminiTheme.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openExerciseModal(
                            existing: ex,
                            index: index,
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: GyminiTheme.textSecondary,
                            size: 19,
                          ),
                          tooltip: 'Editar ejercicio',
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _exercises.removeAt(index);
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: GyminiTheme.dangerCoral,
                            size: 19,
                          ),
                          tooltip: 'Quitar ejercicio',
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          MediaQuery.of(context).padding.bottom + 14,
        ),
        decoration: const BoxDecoration(
          color: GyminiTheme.scaffoldSecondary,
          border: Border(
            top: BorderSide(color: GyminiTheme.borderSubtle, width: 1.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saveAndClose,
                  child: const Text('Guardar Rutina'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exercises.isEmpty ? null : _saveAndStartWorkout,
                  icon: const Icon(Icons.play_arrow_rounded, size: 19),
                  label: const Text('Guardar y Entrenar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
