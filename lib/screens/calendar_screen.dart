import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/workout_controller.dart';
import '../models/session_record.dart';
import '../services/unit_converter.dart';
import '../theme/gymini_theme.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const CalendarScreen({
    super.key,
    this.onOpenDrawer,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;

  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const List<String> _weekDays = [
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _jumpToCurrentMonth() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month, 1);
    });
  }

  String _formatDateLabel(DateTime date) {
    final monthName = _monthNames[date.month - 1];
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${date.day} de $monthName, ${date.year} · $hh:$mm';
  }

  String _formatDurationMin(int seconds) {
    final mins = (seconds / 60).round().clamp(1, 300);
    return '$mins min';
  }

  /// Abre el Modal Detalle al Centro (`showDialog`) con las sesiones del día seleccionado.
  Future<void> _showDaySessionDialog(
    BuildContext context,
    DateTime day,
    List<SessionRecord> sessions,
  ) {
    HapticFeedback.lightImpact();
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) {
        final session = sessions.first;
        return Dialog(
          backgroundColor: GyminiTheme.surfaceCard,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GyminiTheme.modalRadius),
            side: const BorderSide(
              color: GyminiTheme.borderSubtle,
              width: 1.0,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera del modal con nombre de la rutina y botón "✕"
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: GyminiTheme.sageSurfaceTint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: GyminiTheme.sageSuccess.withOpacity(0.45),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: GyminiTheme.mintOverload,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.routineName,
                              style: const TextStyle(
                                color: GyminiTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_formatDateLabel(session.performedAt)} · ${_formatDurationMin(session.durationSeconds)}',
                              style: const TextStyle(
                                color: GyminiTheme.textSecondary,
                                fontSize: 12.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        tooltip: 'Cerrar',
                        style: IconButton.styleFrom(
                          backgroundColor: GyminiTheme.surfaceElevated,
                          minimumSize: const Size(32, 32),
                          padding: const EdgeInsets.all(6),
                        ),
                        icon: const Text(
                          '✕',
                          style: TextStyle(
                            color: GyminiTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: GyminiTheme.borderSubtle),
                  const SizedBox(height: 14),

                  const Text(
                    'EJERCICIOS REALIZADOS',
                    style: TextStyle(
                      color: GyminiTheme.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Lista limpia de ejercicios realizados con series, repeticiones y peso
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: session.exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final ex = session.exercises[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: GyminiTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: ex.completedWithEase
                                  ? GyminiTheme.sageSuccess.withOpacity(0.35)
                                  : GyminiTheme.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: const TextStyle(
                                        color: GyminiTheme.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${ex.sets} series × ${ex.targetReps} reps',
                                      style: const TextStyle(
                                        color: GyminiTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: GyminiTheme.surfaceInput,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: GyminiTheme.borderSubtle,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  '${UnitConverter.formatWeight(ex.weight)} ${ex.unit.toUpperCase()}',
                                  style: const TextStyle(
                                    color: GyminiTheme.primaryLavender,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GyminiTheme.textPrimary,
                        side: const BorderSide(
                          color: GyminiTheme.borderSubtle,
                          width: 1.0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkoutController>();
    final streak = controller.currentStreakDays;
    final activeMonthDays = controller.activeDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );

    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // Lunes = 1 ... Domingo = 7 -> offset 0..6
    final leadingEmptyCells = firstDayOfMonth.weekday - 1;
    final totalGridCells = leadingEmptyCells + daysInMonth;

    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        // 1. Banner minimalista de Racha Activa (Streak Counter) y total del mes
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: GyminiTheme.surfaceCard,
            borderRadius: BorderRadius.circular(GyminiTheme.cardRadius),
            border: Border.all(
              color: GyminiTheme.borderActiveLavender,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GyminiTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: GyminiTheme.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak == 1
                          ? '🔥 Racha: 1 día consecutivo'
                          : '🔥 Racha: $streak días consecutivos',
                      style: const TextStyle(
                        color: GyminiTheme.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$activeMonthDays ${activeMonthDays == 1 ? 'día entrenado' : 'días entrenados'} en ${_monthNames[_focusedMonth.month - 1]}',
                      style: const TextStyle(
                        color: GyminiTheme.textSecondary,
                        fontSize: 12.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: GyminiTheme.sageSurfaceTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GyminiTheme.sageSuccess.withOpacity(0.4),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '${controller.sessionHistory.length} total',
                  style: const TextStyle(
                    color: GyminiTheme.sageSuccess,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 2. Cuadrícula de Calendario Mensual Minimalista
        Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
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
              // Selector de mes
              Row(
                children: [
                  Text(
                    '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                    style: const TextStyle(
                      color: GyminiTheme.textPrimary,
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _jumpToCurrentMonth,
                    style: TextButton.styleFrom(
                      foregroundColor: GyminiTheme.primaryLavender,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Hoy',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _MonthNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _previousMonth,
                  ),
                  const SizedBox(width: 6),
                  _MonthNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextMonth,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cabecera de días de la semana (L M X J V S D)
              Row(
                children: _weekDays
                    .map(
                      (label) => Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: GyminiTheme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),

              // Cuadrícula de días
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalGridCells,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  if (index < leadingEmptyCells) {
                    return const SizedBox.shrink();
                  }
                  final dayNumber = index - leadingEmptyCells + 1;
                  final cellDate = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month,
                    dayNumber,
                  );
                  final daySessions = controller.sessionsForDay(cellDate);
                  final hasWorkout = daySessions.isNotEmpty;
                  final isToday = now.year == cellDate.year &&
                      now.month == cellDate.month &&
                      now.day == cellDate.day;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: hasWorkout
                        ? () => _showDaySessionDialog(
                              context,
                              cellDate,
                              daySessions,
                            )
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: hasWorkout
                            ? GyminiTheme.surfaceElevated
                            : (isToday
                                ? GyminiTheme.surfaceInput
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasWorkout
                              ? GyminiTheme.primaryLavender.withOpacity(0.55)
                              : (isToday
                                  ? GyminiTheme.borderActiveLavender
                                  : GyminiTheme.borderSubtle.withOpacity(0.45)),
                          width: hasWorkout || isToday ? 1.1 : 0.8,
                        ),
                        boxShadow: hasWorkout
                            ? [
                                BoxShadow(
                                  color: GyminiTheme.primaryLavender
                                      .withOpacity(0.12),
                                  blurRadius: 8,
                                  spreadRadius: 0.5,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: hasWorkout
                                  ? GyminiTheme.textPrimary
                                  : (isToday
                                      ? GyminiTheme.primaryLavender
                                      : GyminiTheme.textSecondary),
                              fontSize: 13.5,
                              fontWeight: hasWorkout || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Indicador visual (punto en menta suave #86EFAC o morado pastel #C4B5FD)
                          Container(
                            width: 5.5,
                            height: 5.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasWorkout
                                  ? GyminiTheme.mintOverload
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: GyminiTheme.borderSubtle),
              const SizedBox(height: 12),

              // Leyenda minimalista
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: GyminiTheme.mintOverload,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Flexible(
                    child: Text(
                      'Toca cualquier día con entrenamiento para ver el detalle',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GyminiTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: GyminiTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: GyminiTheme.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          color: GyminiTheme.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}
