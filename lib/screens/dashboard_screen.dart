import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/workout_controller.dart';
import '../models/routine.dart';
import '../theme/gymini_theme.dart';
import '../widgets/gymini_drawer.dart';
import '../widgets/routine_card.dart';
import '../widgets/unit_toggle_pill.dart';
import 'active_workout_screen.dart';
import 'calendar_screen.dart';
import 'routine_editor_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GyminiDrawerSection _activeSection = GyminiDrawerSection.routines;

  String _greetingByHour() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  void _openActiveWorkout(BuildContext context, Routine routine) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActiveWorkoutScreen(routine: routine),
      ),
    );
  }

  void _openRoutineEditor(BuildContext context, {Routine? routine}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoutineEditorScreen(existingRoutine: routine),
      ),
    );
  }

  Future<void> _showQuickTrainTodaySheet(
    BuildContext context,
    List<Routine> routines,
  ) async {
    if (routines.isEmpty) {
      _openRoutineEditor(context);
      return;
    }
    if (routines.length == 1) {
      _openActiveWorkout(context, routines.first);
      return;
    }

    HapticFeedback.lightImpact();
    final selected = await showModalBottomSheet<Routine>(
      context: context,
      backgroundColor: GyminiTheme.scaffoldSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GyminiTheme.modalRadius),
        ),
        side: BorderSide(color: GyminiTheme.borderSubtle, width: 1.0),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GyminiTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Entrenar Hoy',
                  style: TextStyle(
                    color: GyminiTheme.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecciona la rutina que deseas iniciar:',
                  style: TextStyle(
                    color: GyminiTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: routines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final r = routines[index];
                      final overload = r.overloadReadyCount;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(ctx).pop(r),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: GyminiTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: overload > 0
                                  ? GyminiTheme.sageSuccess.withOpacity(0.45)
                                  : GyminiTheme.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: GyminiTheme.surfaceElevated,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: GyminiTheme.primaryLavender,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: const TextStyle(
                                        color: GyminiTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${r.exercises.length} ejercicios'
                                      '${overload > 0 ? ' · $overload para subir peso' : ''}',
                                      style: TextStyle(
                                        color: overload > 0
                                            ? GyminiTheme.sageSuccess
                                            : GyminiTheme.textSecondary,
                                        fontSize: 12.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: GyminiTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && context.mounted) {
      _openActiveWorkout(context, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkoutController>();
    final routines = controller.routines;
    final recommended = controller.recommendedRoutineForToday;
    final streak = controller.currentStreakDays;
    final isCalendar = _activeSection == GyminiDrawerSection.calendar;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: GyminiTheme.scaffoldBg,
      drawer: GyminiDrawer(
        activeSection: _activeSection,
        onSelectSection: (section) {
          setState(() {
            _activeSection = section;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: GyminiTheme.scaffoldBg,
        leading: IconButton(
          tooltip: 'Menú de navegación',
          icon: const Icon(
            Icons.menu_rounded,
            color: GyminiTheme.textPrimary,
            size: 24,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCalendar ? 'Constancia' : _greetingByHour(),
              style: const TextStyle(
                color: GyminiTheme.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              isCalendar ? 'Calendario y Rachas' : 'Gymini',
              style: const TextStyle(
                color: GyminiTheme.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Acceso rápido al calendario / racha desde la barra superior
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _activeSection = isCalendar
                    ? GyminiDrawerSection.routines
                    : GyminiDrawerSection.calendar;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCalendar
                    ? GyminiTheme.surfaceElevated
                    : GyminiTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCalendar
                      ? GyminiTheme.primaryLavender.withOpacity(0.5)
                      : GyminiTheme.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '$streak d',
                    style: const TextStyle(
                      color: GyminiTheme.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: UnitTogglePill(
                currentUnit: controller.preferredUnit,
                compact: true,
                onUnitChanged: (unit) {
                  controller.setPreferredUnit(
                    unit,
                    convertStoredExercises: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isCalendar
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.lightImpact();
                _openRoutineEditor(context);
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                '+ Nueva Rutina',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
      body: SafeArea(
        child: isCalendar
            ? const CalendarScreen()
            : CustomScrollView(
                slivers: [
                  // 1. Tarjeta minimalista de Acceso Rápido "Entrenar Hoy"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: GyminiTheme.surfaceElevated,
                          borderRadius:
                              BorderRadius.circular(GyminiTheme.cardRadius),
                          border: Border.all(
                            color: GyminiTheme.borderActiveLavender,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommended != null
                                  ? 'Siguiente: ${recommended.name}'
                                  : 'Comienza tu entrenamiento',
                              style: const TextStyle(
                                color: GyminiTheme.textPrimary,
                                fontSize: 18.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              recommended != null
                                  ? 'Pesos precargados en ${controller.preferredUnit.toUpperCase()} y detección automática de sobrecarga progresiva.'
                                  : 'Crea tu primera rutina personalizada.',
                              style: const TextStyle(
                                color: GyminiTheme.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (recommended != null) {
                                        HapticFeedback.lightImpact();
                                        _openActiveWorkout(
                                          context,
                                          recommended,
                                        );
                                      } else {
                                        _openRoutineEditor(context);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.bolt_rounded,
                                      size: 19,
                                    ),
                                    label: const Text('Entrenar Hoy'),
                                  ),
                                ),
                                if (routines.length > 1) ...[
                                  const SizedBox(width: 10),
                                  OutlinedButton(
                                    onPressed: () => _showQuickTrainTodaySheet(
                                      context,
                                      routines,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 15,
                                      ),
                                    ),
                                    child: const Text('Elegir'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Cabecera "Mis Rutinas"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mis Rutinas',
                            style: TextStyle(
                              color: GyminiTheme.textPrimary,
                              fontSize: 17.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            '${routines.length} ${routines.length == 1 ? 'rutina' : 'rutinas'}',
                            style: const TextStyle(
                              color: GyminiTheme.textSecondary,
                              fontSize: 12.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Listado de rutinas
                  if (routines.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: GyminiTheme.surfaceCard,
                            borderRadius:
                                BorderRadius.circular(GyminiTheme.cardRadius),
                            border: Border.all(
                              color: GyminiTheme.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.fitness_center_rounded,
                                color: GyminiTheme.primaryLavender,
                                size: 36,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Aún no tienes rutinas configuradas',
                                style: TextStyle(
                                  color: GyminiTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Pulsa "+ Nueva Rutina" para estructurar tus ejercicios y seguir tu sobrecarga progresiva.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: GyminiTheme.textSecondary,
                                  fontSize: 13.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList.separated(
                        itemCount: routines.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          return RoutineCard(
                            routine: routine,
                            onStartWorkout: () =>
                                _openActiveWorkout(context, routine),
                            onManageRoutine: () => _openRoutineEditor(
                              context,
                              routine: routine,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
