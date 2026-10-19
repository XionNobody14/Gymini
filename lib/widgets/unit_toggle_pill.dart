import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/unit_converter.dart';
import '../theme/gymini_theme.dart';

class UnitTogglePill extends StatelessWidget {
  final String currentUnit;
  final ValueChanged<String> onUnitChanged;
  final bool compact;

  const UnitTogglePill({
    super.key,
    required this.currentUnit,
    required this.onUnitChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = UnitConverter.normalizeUnit(currentUnit);
    final isKg = normalized == UnitConverter.kg;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: GyminiTheme.surfaceInput,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(
          color: GyminiTheme.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UnitOptionButton(
            label: 'KG',
            selected: isKg,
            compact: compact,
            onTap: () {
              if (!isKg) {
                HapticFeedback.selectionClick();
                onUnitChanged(UnitConverter.kg);
              }
            },
          ),
          const SizedBox(width: 2),
          _UnitOptionButton(
            label: 'LBS',
            selected: !isKg,
            compact: compact,
            onTap: () {
              if (isKg) {
                HapticFeedback.selectionClick();
                onUnitChanged(UnitConverter.lbs);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _UnitOptionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _UnitOptionButton({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 12,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: selected ? GyminiTheme.primaryLavender : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 7 : 9),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? GyminiTheme.onPrimaryDark
                : GyminiTheme.textSecondary,
            fontSize: compact ? 11.5 : 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
