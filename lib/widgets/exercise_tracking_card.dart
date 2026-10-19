import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';
import '../services/unit_converter.dart';
import '../theme/gymini_theme.dart';
import 'unit_toggle_pill.dart';

class ExerciseTrackingCard extends StatefulWidget {
  final int index;
  final Exercise exercise;
  final double previousSessionWeight;
  final String previousSessionUnit;
  final int previousSessionReps;
  final bool highlightOverloadSuggestion;
  final ValueChanged<Exercise> onChanged;
  final VoidCallback? onEditMetadata;

  const ExerciseTrackingCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.previousSessionWeight,
    required this.previousSessionUnit,
    required this.previousSessionReps,
    required this.highlightOverloadSuggestion,
    required this.onChanged,
    this.onEditMetadata,
  });

  @override
  State<ExerciseTrackingCard> createState() => _ExerciseTrackingCardState();
}

class _ExerciseTrackingCardState extends State<ExerciseTrackingCard> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late FocusNode _weightFocus;
  late FocusNode _repsFocus;

  @override
  void initState() {
    super.initState();
    _weightFocus = FocusNode();
    _repsFocus = FocusNode();
    _weightController = TextEditingController(
      text: UnitConverter.formatWeight(widget.exercise.weight),
    );
    _repsController = TextEditingController(
      text: widget.exercise.targetReps.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ExerciseTrackingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_weightFocus.hasFocus &&
        (oldWidget.exercise.weight != widget.exercise.weight ||
            oldWidget.exercise.unit != widget.exercise.unit)) {
      _weightController.text =
          UnitConverter.formatWeight(widget.exercise.weight);
    }
    if (!_repsFocus.hasFocus &&
        oldWidget.exercise.targetReps != widget.exercise.targetReps) {
      _repsController.text = widget.exercise.targetReps.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  void _updateWeight(double newWeight) {
    final clamped = newWeight < 0 ? 0.0 : newWeight;
    final rounded = UnitConverter.roundForInput(clamped);
    _weightController.text = UnitConverter.formatWeight(rounded);
    widget.onChanged(widget.exercise.copyWith(weight: rounded));
  }

  void _updateReps(int newReps) {
    final clamped = newReps.clamp(1, 999);
    _repsController.text = clamped.toString();
    widget.onChanged(widget.exercise.copyWith(targetReps: clamped));
  }

  void _updateSets(int newSets) {
    HapticFeedback.selectionClick();
    widget.onChanged(widget.exercise.copyWith(sets: newSets.clamp(1, 10)));
  }

  void _handleUnitToggle(String targetUnit) {
    final normalizedTarget = UnitConverter.normalizeUnit(targetUnit);
    final currentUnit = UnitConverter.normalizeUnit(widget.exercise.unit);
    if (normalizedTarget == currentUnit) return;

    final converted = UnitConverter.convert(
      widget.exercise.weight,
      from: currentUnit,
      to: normalizedTarget,
    );
    final rounded = UnitConverter.roundForInput(converted);
    _weightController.text = UnitConverter.formatWeight(rounded);

    widget.onChanged(
      widget.exercise.copyWith(
        weight: rounded,
        unit: normalizedTarget,
      ),
    );
  }

  void _toggleCompletedWithEase() {
    HapticFeedback.lightImpact();
    widget.onChanged(
      widget.exercise.copyWith(
        completedWithEase: !widget.exercise.completedWithEase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final isEasy = exercise.completedWithEase;
    final showOverloadBanner = widget.highlightOverloadSuggestion;
    final step = UnitConverter.stepForUnit(exercise.unit);
    final currentSets = exercise.sets.clamp(1, 10);

    final prevWeightInCurrentUnit = UnitConverter.convert(
      widget.previousSessionWeight,
      from: widget.previousSessionUnit,
      to: exercise.unit,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GyminiTheme.surfaceCard,
        borderRadius: BorderRadius.circular(GyminiTheme.cardRadius),
        border: Border.all(
          color: isEasy
              ? GyminiTheme.sageSuccess.withOpacity(0.5)
              : (showOverloadBanner
                  ? GyminiTheme.primaryLavender.withOpacity(0.38)
                  : GyminiTheme.borderSubtle),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado minimalista: Nombre, historial sutil y Toggle KG/LBS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.index + 1}. ',
                          style: const TextStyle(
                            color: GyminiTheme.primaryLavender,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(
                              color: GyminiTheme.textPrimary,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anterior: ${UnitConverter.formatWeight(prevWeightInCurrentUnit)} ${exercise.unit.toUpperCase()} × ${widget.previousSessionReps} reps',
                      style: const TextStyle(
                        color: GyminiTheme.textSecondary,
                        fontSize: 12.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              UnitTogglePill(
                currentUnit: exercise.unit,
                onUnitChanged: _handleUnitToggle,
                compact: true,
              ),
            ],
          ),

          // Sugerencia minimalista de sobrecarga progresiva
          if (showOverloadBanner) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: GyminiTheme.sageSurfaceTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GyminiTheme.sageSuccess.withOpacity(0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: GyminiTheme.mintOverload,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sobrecarga sugerida hoy',
                      style: TextStyle(
                        color: GyminiTheme.sageSuccess,
                        fontSize: 12.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _updateWeight(exercise.weight + step);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GyminiTheme.sageSuccess.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: GyminiTheme.mintOverload.withOpacity(0.45),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '+${UnitConverter.formatWeight(step)} ${exercise.unit.toUpperCase()}',
                        style: const TextStyle(
                          color: GyminiTheme.mintOverload,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Fila de 3 controles limpios: Series (Dropdown 1-10), Peso y Repeticiones
          Row(
            children: [
              // 1. Selector Dropdown de Series (1 a 10)
              Expanded(
                flex: 3,
                child: _SeriesDropdownField(
                  selectedSets: currentSets,
                  onChanged: _updateSets,
                ),
              ),
              const SizedBox(width: 10),
              // 2. Bloque de Peso
              Expanded(
                flex: 4,
                child: _NumericMetricField(
                  label: 'PESO (${exercise.unit.toUpperCase()})',
                  controller: _weightController,
                  focusNode: _weightFocus,
                  isDecimal: true,
                  onDecrement: () {
                    HapticFeedback.selectionClick();
                    _updateWeight(exercise.weight - step);
                  },
                  onIncrement: () {
                    HapticFeedback.selectionClick();
                    _updateWeight(exercise.weight + step);
                  },
                  onSubmitted: (val) {
                    final parsed =
                        double.tryParse(val.trim().replaceAll(',', '.'));
                    if (parsed != null && parsed >= 0) {
                      _updateWeight(parsed);
                    } else {
                      _weightController.text =
                          UnitConverter.formatWeight(exercise.weight);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              // 3. Bloque de Repeticiones
              Expanded(
                flex: 4,
                child: _NumericMetricField(
                  label: 'REPS',
                  controller: _repsController,
                  focusNode: _repsFocus,
                  isDecimal: false,
                  onDecrement: () {
                    HapticFeedback.selectionClick();
                    _updateReps(exercise.targetReps - 1);
                  },
                  onIncrement: () {
                    HapticFeedback.selectionClick();
                    _updateReps(exercise.targetReps + 1);
                  },
                  onSubmitted: (val) {
                    final parsed = int.tryParse(val.trim());
                    if (parsed != null && parsed > 0) {
                      _updateReps(parsed);
                    } else {
                      _repsController.text = exercise.targetReps.toString();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Toggle minimalista: "¿Completado con facilidad?"
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleCompletedWithEase,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isEasy
                    ? GyminiTheme.sageSurfaceTint
                    : GyminiTheme.surfaceInput,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isEasy
                      ? GyminiTheme.sageSuccess.withOpacity(0.5)
                      : GyminiTheme.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEasy
                        ? Icons.local_fire_department_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 18,
                    color: isEasy
                        ? GyminiTheme.mintOverload
                        : GyminiTheme.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¿Completado con facilidad?',
                      style: TextStyle(
                        color: isEasy
                            ? GyminiTheme.sageSuccess
                            : GyminiTheme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 22,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: isEasy
                          ? GyminiTheme.sageSuccess
                          : GyminiTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isEasy
                            ? GyminiTheme.sageSuccess
                            : GyminiTheme.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    alignment:
                        isEasy ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isEasy
                            ? GyminiTheme.onPrimaryDark
                            : GyminiTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesDropdownField extends StatelessWidget {
  final int selectedSets;
  final ValueChanged<int> onChanged;

  const _SeriesDropdownField({
    required this.selectedSets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: GyminiTheme.surfaceInput,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: GyminiTheme.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SERIES',
            style: TextStyle(
              color: GyminiTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 30,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedSets.clamp(1, 10),
                isExpanded: true,
                isDense: true,
                dropdownColor: GyminiTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(13),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: GyminiTheme.primaryLavender,
                  size: 18,
                ),
                style: const TextStyle(
                  color: GyminiTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                items: List.generate(10, (index) {
                  final count = index + 1;
                  return DropdownMenuItem<int>(
                    value: count,
                    child: Text(
                      '$count ${count == 1 ? 'serie' : 'series'}',
                      style: const TextStyle(
                        color: GyminiTheme.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
                selectedItemBuilder: (context) {
                  return List.generate(10, (index) {
                    final count = index + 1;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$count ×',
                        style: const TextStyle(
                          color: GyminiTheme.textPrimary,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  });
                },
                onChanged: (val) {
                  if (val != null) {
                    onChanged(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericMetricField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDecimal;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onSubmitted;

  const _NumericMetricField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isDecimal,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: GyminiTheme.surfaceInput,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: GyminiTheme.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: GyminiTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 30,
            child: Row(
              children: [
                _StepperIconButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrement,
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: isDecimal,
                    ),
                    style: const TextStyle(
                      color: GyminiTheme.textPrimary,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 2),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: onSubmitted,
                    onSubmitted: onSubmitted,
                  ),
                ),
                _StepperIconButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: GyminiTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: GyminiTheme.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: GyminiTheme.primaryLavender,
        ),
      ),
    );
  }
}
