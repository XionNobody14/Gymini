import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';
import '../services/unit_converter.dart';
import '../theme/gymini_theme.dart';
import 'unit_toggle_pill.dart';

class ExerciseFormResult {
  final String name;
  final double weight;
  final String unit;
  final int targetReps;
  final int sets;
  final String? muscleGroup;

  const ExerciseFormResult({
    required this.name,
    required this.weight,
    required this.unit,
    required this.targetReps,
    required this.sets,
    this.muscleGroup,
  });
}

class ExerciseFormModal extends StatefulWidget {
  final Exercise? initialExercise;
  final String defaultUnit;

  const ExerciseFormModal({
    super.key,
    this.initialExercise,
    required this.defaultUnit,
  });

  static Future<ExerciseFormResult?> show(
    BuildContext context, {
    Exercise? initialExercise,
    required String defaultUnit,
  }) {
    return showModalBottomSheet<ExerciseFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GyminiTheme.scaffoldSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GyminiTheme.modalRadius),
        ),
        side: BorderSide(color: GyminiTheme.borderSubtle, width: 1.0),
      ),
      builder: (ctx) => ExerciseFormModal(
        initialExercise: initialExercise,
        defaultUnit: defaultUnit,
      ),
    );
  }

  @override
  State<ExerciseFormModal> createState() => _ExerciseFormModalState();
}

class _ExerciseFormModalState extends State<ExerciseFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final TextEditingController _muscleController;
  late String _selectedUnit;
  late int _selectedSets;

  @override
  void initState() {
    super.initState();
    final existing = widget.initialExercise;
    _selectedUnit = existing != null
        ? UnitConverter.normalizeUnit(existing.unit)
        : UnitConverter.normalizeUnit(widget.defaultUnit);
    _selectedSets = (existing?.sets ?? 3).clamp(1, 10);

    _nameController = TextEditingController(text: existing?.name ?? '');
    _weightController = TextEditingController(
      text: existing != null
          ? UnitConverter.formatWeight(existing.weight)
          : '40',
    );
    _repsController = TextEditingController(
      text: (existing?.targetReps ?? 8).toString(),
    );
    _muscleController = TextEditingController(
      text: existing?.muscleGroup ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _muscleController.dispose();
    super.dispose();
  }

  void _handleUnitSwitch(String newUnit) {
    final normalized = UnitConverter.normalizeUnit(newUnit);
    if (normalized == _selectedUnit) return;

    final rawWeight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );
    if (rawWeight != null) {
      final converted = UnitConverter.convert(
        rawWeight,
        from: _selectedUnit,
        to: normalized,
      );
      _weightController.text = UnitConverter.formatWeight(converted);
    }
    setState(() {
      _selectedUnit = normalized;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final name = _nameController.text.trim();
    final weight = double.tryParse(
          _weightController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;
    final reps = int.tryParse(_repsController.text.trim()) ?? 8;
    final muscle = _muscleController.text.trim();

    Navigator.of(context).pop(
      ExerciseFormResult(
        name: name,
        weight: weight,
        unit: _selectedUnit,
        targetReps: reps,
        sets: _selectedSets.clamp(1, 10),
        muscleGroup: muscle.isNotEmpty ? muscle : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExercise != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(22, 16, 22, bottomInset + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GyminiTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Ejercicio' : 'Nuevo Ejercicio',
                    style: const TextStyle(
                      color: GyminiTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  UnitTogglePill(
                    currentUnit: _selectedUnit,
                    onUnitChanged: _handleUnitSwitch,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Nombre del ejercicio',
                style: TextStyle(
                  color: GyminiTheme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: GyminiTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ej. Press de Banca, Sentadilla Búlgara',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa el nombre del ejercicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Fila de Series (Dropdown 1 a 10), Peso y Repeticiones
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector Dropdown de Series (1 a 10)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Series',
                          style: TextStyle(
                            color: GyminiTheme.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _selectedSets,
                          dropdownColor: GyminiTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: GyminiTheme.primaryLavender,
                            size: 20,
                          ),
                          style: const TextStyle(
                            color: GyminiTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: List.generate(10, (index) {
                            final s = index + 1;
                            return DropdownMenuItem<int>(
                              value: s,
                              child: Text('$s ${s == 1 ? 'serie' : 'series'}'),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedSets = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Peso
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peso (${_selectedUnit.toUpperCase()})',
                          style: const TextStyle(
                            color: GyminiTheme.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            color: GyminiTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.0',
                            suffixText: _selectedUnit.toUpperCase(),
                            suffixStyle: const TextStyle(
                              color: GyminiTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          validator: (val) {
                            final parsed = double.tryParse(
                              (val ?? '').trim().replaceAll(',', '.'),
                            );
                            if (parsed == null || parsed < 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Repeticiones objetivo
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reps',
                          style: TextStyle(
                            color: GyminiTheme.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _repsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: GyminiTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: '8',
                          ),
                          validator: (val) {
                            final parsed = int.tryParse((val ?? '').trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text(
                'Enfoque muscular (opcional)',
                style: TextStyle(
                  color: GyminiTheme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _muscleController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: GyminiTheme.textPrimary,
                  fontSize: 14.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ej. Pectoral, Cuádriceps, Dorsal',
                ),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(
                        isEditing ? Icons.check_rounded : Icons.add_rounded,
                        size: 19,
                      ),
                      label: Text(
                        isEditing ? 'Guardar cambios' : 'Añadir ejercicio',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
