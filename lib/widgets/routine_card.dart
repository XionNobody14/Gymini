import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/routine.dart';
import '../services/unit_converter.dart';
import '../theme/gymini_theme.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onStartWorkout;
  final VoidCallback onManageRoutine;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onStartWorkout,
    required this.onManageRoutine,
  });

  String _formatLastPerformed(DateTime? date) {
    if (date == null) return 'Sin sesiones previas';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes.clamp(1, 59)} min';
    }
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    }
    if (diff.inDays == 1) {
      return 'Ayer';
    }
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final overloadCount = routine.overloadReadyCount;

    return Container(
      decoration: BoxDecoration(
        color: GyminiTheme.surfaceCard,
        borderRadius: BorderRadius.circular(GyminiTheme.cardRadius),
        border: Border.all(
          color: overloadCount > 0
              ? GyminiTheme.sageSuccess.withOpacity(0.32)
              : GyminiTheme.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(GyminiTheme.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(GyminiTheme.cardRadius),
          onTap: () {
            HapticFeedback.selectionClick();
            onStartWorkout();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera limpia: Nombre, subtítulo y botón sutil de configuración
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.name,
                            style: const TextStyle(
                              color: GyminiTheme.textPrimary,
                              fontSize: 17.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            routine.subtitle?.isNotEmpty == true
                                ? routine.subtitle!
                                : '${routine.exercises.length} ejercicios',
                            style: const TextStyle(
                              color: GyminiTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onManageRoutine();
                      },
                      tooltip: 'Editar rutina',
                      style: IconButton.styleFrom(
                        backgroundColor: GyminiTheme.surfaceElevated,
                        minimumSize: const Size(34, 34),
                        padding: const EdgeInsets.all(7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: GyminiTheme.borderSubtle,
                            width: 1.0,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: GyminiTheme.textSecondary,
                        size: 17,
                      ),
                    ),
                  ],
                ),

                if (routine.exercises.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: routine.exercises.take(4).map((exercise) {
                      final isOverload = exercise.completedWithEase;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isOverload
                              ? GyminiTheme.sageSurfaceTint.withOpacity(0.6)
                              : GyminiTheme.surfaceInput,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: isOverload
                                ? GyminiTheme.sageSuccess.withOpacity(0.32)
                                : GyminiTheme.borderSubtle,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '${exercise.name} · ${exercise.sets}×${exercise.targetReps} (${UnitConverter.formatWeight(exercise.weight)} ${exercise.unit.toUpperCase()})',
                          style: TextStyle(
                            color: isOverload
                                ? GyminiTheme.textPrimary
                                : GyminiTheme.textSecondary,
                            fontSize: 11.8,
                            fontWeight:
                                isOverload ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1, color: GyminiTheme.borderSubtle),
                const SizedBox(height: 12),

                // Pie minimalista: Estado de sobrecarga / última sesión + botón Entrenar
                Row(
                  children: [
                    if (overloadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GyminiTheme.sageSurfaceTint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: GyminiTheme.sageSuccess.withOpacity(0.4),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: GyminiTheme.mintOverload,
                              size: 13.5,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$overloadCount para subir peso',
                              style: const TextStyle(
                                color: GyminiTheme.sageSuccess,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        _formatLastPerformed(routine.lastPerformed),
                        style: const TextStyle(
                          color: GyminiTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onStartWorkout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GyminiTheme.primaryLavender,
                        foregroundColor: GyminiTheme.onPrimaryDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 17),
                      label: const Text(
                        'Entrenar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
