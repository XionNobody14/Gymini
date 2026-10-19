import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';
import '../services/unit_converter.dart';
import '../theme/gymini_theme.dart';

enum OverloadDecision {
  increaseWeight,
  keepCurrentWeight,
}

class ProgressiveOverloadModal extends StatelessWidget {
  final String routineName;
  final List<Exercise> candidateExercises;

  const ProgressiveOverloadModal({
    super.key,
    required this.routineName,
    required this.candidateExercises,
  });

  static Future<OverloadDecision?> show(
    BuildContext context, {
    required String routineName,
    required List<Exercise> candidateExercises,
  }) {
    HapticFeedback.mediumImpact();
    return showDialog<OverloadDecision>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.76),
      builder: (ctx) => ProgressiveOverloadModal(
        routineName: routineName,
        candidateExercises: candidateExercises,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: GyminiTheme.surfaceCard,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GyminiTheme.modalRadius),
        side: BorderSide(
          color: GyminiTheme.sageSuccess.withOpacity(0.45),
          width: 1.0,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con insignia verde salvia / menta tenue (#A7D7C5 / #86EFAC)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: GyminiTheme.sageSurfaceTint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: GyminiTheme.sageSuccess.withOpacity(0.5),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: GyminiTheme.mintOverload,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: GyminiTheme.sageSurfaceTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            routineName.toUpperCase(),
                            style: const TextStyle(
                              color: GyminiTheme.sageSuccess,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sugerencia de Sobrecarga Progresiva',
                          style: TextStyle(
                            color: GyminiTheme.textPrimary,
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mensaje amigable sin forzar cifra fija
              const Text(
                'En tu última sesión completaste las repeticiones objetivo con facilidad en los siguientes ejercicios. '
                'Te recomendamos subir el peso hoy según tu sensación para mantener el estímulo de sobrecarga progresiva:',
                style: TextStyle(
                  color: GyminiTheme.textSecondary,
                  fontSize: 13.8,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),

              // Lista de ejercicios con completedWithEase == true
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: candidateExercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final exercise = candidateExercises[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: GyminiTheme.sageSurfaceTint,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: GyminiTheme.mintOverload,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    color: GyminiTheme.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Última sesión: ${UnitConverter.formatWeight(exercise.weight)} ${exercise.unit.toUpperCase()} × ${exercise.targetReps} reps',
                                  style: const TextStyle(
                                    color: GyminiTheme.textSecondary,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: GyminiTheme.sageSurfaceTint,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: GyminiTheme.sageSuccess
                                    .withOpacity(0.4),
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  color: GyminiTheme.mintOverload,
                                  size: 13,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Subir carga',
                                  style: TextStyle(
                                    color: GyminiTheme.sageSuccess,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Opciones requeridas del pop-up:
              // 1. "Entendido / Aumentar peso"
              // 2. "Mantener peso actual"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(OverloadDecision.increaseWeight);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GyminiTheme.primaryLavender,
                    foregroundColor: GyminiTheme.onPrimaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.trending_up_rounded, size: 19),
                  label: const Text('Entendido / Aumentar peso'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context)
                        .pop(OverloadDecision.keepCurrentWeight);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GyminiTheme.textSecondary,
                    side: const BorderSide(
                      color: GyminiTheme.borderSubtle,
                      width: 1.0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Mantener peso actual'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
