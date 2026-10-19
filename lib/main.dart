import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'controllers/workout_controller.dart';
import 'screens/dashboard_screen.dart';
import 'services/storage_service.dart';
import 'theme/gymini_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GyminiTheme.scaffoldBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = StorageService();
  final workoutController = WorkoutController(storageService: storageService);
  await workoutController.initialize();

  runApp(
    GyminiApp(workoutController: workoutController),
  );
}

class GyminiApp extends StatelessWidget {
  final WorkoutController workoutController;

  const GyminiApp({
    super.key,
    required this.workoutController,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WorkoutController>.value(
      value: workoutController,
      child: MaterialApp(
        title: 'Gymini',
        debugShowCheckedModeBanner: false,
        theme: GyminiTheme.darkTheme,
        darkTheme: GyminiTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const DashboardScreen(),
      ),
    );
  }
}
