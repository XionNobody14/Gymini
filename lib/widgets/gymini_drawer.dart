import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/workout_controller.dart';
import '../theme/gymini_theme.dart';
import 'unit_toggle_pill.dart';

enum GyminiDrawerSection {
  routines,
  calendar,
}

class GyminiDrawer extends StatelessWidget {
  final GyminiDrawerSection activeSection;
  final ValueChanged<GyminiDrawerSection> onSelectSection;

  const GyminiDrawer({
    super.key,
    required this.activeSection,
    required this.onSelectSection,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkoutController>();
    final streak = controller.currentStreakDays;

    return Drawer(
      backgroundColor: GyminiTheme.scaffoldSecondary,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(22)),
        side: BorderSide(color: GyminiTheme.borderSubtle, width: 1.0),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera de identidad Gymini
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: GyminiTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: GyminiTheme.borderActiveLavender,
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: GyminiTheme.primaryLavender,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gymini',
                            style: TextStyle(
                              color: GyminiTheme.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Midnight Zen · Overload',
                            style: TextStyle(
                              color: GyminiTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Insignia compacta de racha activa
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: GyminiTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: GyminiTheme.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        streak == 1
                            ? 'Racha: 1 día consecutivo'
                            : 'Racha: $streak días consecutivos',
                        style: const TextStyle(
                          color: GyminiTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'NAVEGACIÓN',
                  style: TextStyle(
                    color: GyminiTheme.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Opción 1: "Mis Rutinas / Entrenar"
              _DrawerNavItem(
                icon: Icons.bolt_rounded,
                label: 'Mis Rutinas / Entrenar',
                subtitle: 'Dashboard y sobrecarga progresiva',
                selected: activeSection == GyminiDrawerSection.routines,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                  onSelectSection(GyminiDrawerSection.routines);
                },
              ),
              const SizedBox(height: 8),

              // Opción 2: "Calendario y Rachas"
              _DrawerNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Calendario y Rachas',
                subtitle: 'Asistencia mensual e historial',
                selected: activeSection == GyminiDrawerSection.calendar,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                  onSelectSection(GyminiDrawerSection.calendar);
                },
              ),

              const Spacer(),
              const Divider(color: GyminiTheme.borderSubtle, height: 1),
              const SizedBox(height: 14),

              // Preferencia global de unidades en el pie del Drawer
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Unidad',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GyminiTheme.textSecondary,
                        fontSize: 12.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  UnitTogglePill(
                    currentUnit: controller.preferredUnit,
                    compact: true,
                    onUnitChanged: (unit) {
                      controller.setPreferredUnit(
                        unit,
                        convertStoredExercises: true,
                      );
                    },
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

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? GyminiTheme.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? GyminiTheme.primaryLavender.withOpacity(0.45)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: selected
                    ? GyminiTheme.primaryLavender
                    : GyminiTheme.textSecondary,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? GyminiTheme.textPrimary
                            : GyminiTheme.textSecondary,
                        fontSize: 14.5,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: GyminiTheme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: GyminiTheme.primaryLavender,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
