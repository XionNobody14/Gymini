import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymini/controllers/workout_controller.dart';
import 'package:gymini/main.dart';
import 'package:gymini/models/exercise.dart';
import 'package:gymini/models/routine.dart';
import 'package:gymini/services/overload_engine.dart';
import 'package:gymini/services/storage_service.dart';
import 'package:gymini/services/unit_converter.dart';

void main() {
  group('Gymini Core & UI Tests', () {
    test('UnitConverter converts kg <-> lbs accurately (1 kg = 2.20462 lbs)', () {
      final lbs = UnitConverter.convert(100.0, from: 'kg', to: 'lbs');
      expect(lbs, closeTo(220.462, 0.0001));

      final kg = UnitConverter.convert(lbs, from: 'lbs', to: 'kg');
      expect(kg, closeTo(100.0, 0.0001));
    });

    test('OverloadEngine detects exercises with completedWithEase == true', () {
      const engine = OverloadEngine();
      final now = DateTime.now();
      final routine = Routine(
        id: 'r1',
        name: 'Empuje (Push)',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Press de Banca',
            targetReps: 8,
            weight: 80.0,
            unit: 'kg',
            completedWithEase: true,
            lastUpdated: now,
            sets: 4,
          ),
          Exercise(
            id: 'e2',
            name: 'Press Militar',
            targetReps: 8,
            weight: 50.0,
            unit: 'kg',
            completedWithEase: false,
            lastUpdated: now,
            sets: 3,
          ),
        ],
      );

      final assessment = engine.evaluateRoutineForSession(routine);
      expect(assessment.shouldPromptOverload, isTrue);
      expect(assessment.overloadCandidates.length, 1);
      expect(assessment.overloadCandidates.first.name, 'Press de Banca');
    });

    testWidgets(
        'Gymini Dashboard renders routines, Drawer opens, and Calendar & Streaks works',
        (WidgetTester tester) async {
      late WorkoutController controller;
      await tester.runAsync(() async {
        final tempDir = await Directory.systemTemp.createTemp('gymini_test_');
        final storage = StorageService();
        await storage.init(customStoragePath: tempDir.path);
        controller = WorkoutController(storageService: storage);
        await controller.initialize();
      });

      await tester.pumpWidget(GyminiApp(workoutController: controller));
      await tester.pumpAndSettle();

      expect(find.text('Gymini'), findsOneWidget);
      expect(find.text('Entrenar Hoy'), findsOneWidget);
      expect(find.text('+ Nueva Rutina'), findsOneWidget);

      // Abrir Navigation Drawer y navegar a "Calendario y Rachas"
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Mis Rutinas / Entrenar'), findsOneWidget);
      expect(find.text('Calendario y Rachas'), findsOneWidget);

      await tester.tap(find.text('Calendario y Rachas'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Racha:'), findsOneWidget);
    });
  });
}
