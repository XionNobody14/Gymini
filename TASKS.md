# 📋 Gymini — Pizarra de Control Multiagente (`TASKS.md`)

> **Arquitectura**: Patrón Coordinator-Workers  
> **Identidad Visual**: Dark Lavender / Midnight Zen (`#0D0B12` · `#1A1626` · `#C4B5FD` · `#A7D7C5`)  
> **Persistencia**: Offline-First Local Storage (Hive)

---

## Fase 1: Orquestación y Arquitectura (`@coordinator`)
- [x] Crear directorio `.antigravity/` con especificaciones de agentes (`coordinator.md`, `data_engine.md`, `ui_ux_designer.md`, `qa_reviewer.md`).
- [x] Inicializar pizarra de seguimiento `TASKS.md` con contratos de datos y estructura modular.
- [x] Inicializar proyecto base Flutter para Android/iOS y configurar estructura en `lib/`.

## Fase 2: Persistencia Offline-First y Lógica de Negocio (`@data_engine`)
- [x] Configurar `pubspec.yaml` con dependencias de estado (`provider`), persistencia local (`hive`, `path_provider`), identificadores (`uuid`) y utilidades (`intl`).
- [x] Implementar modelo `Exercise` (`id`, `name`, `targetReps`, `weight`, `unit`, `completedWithEase`, `lastUpdated`, `sets`, serialización JSON/Map).
- [x] Implementar modelos `Routine` (`id`, `name`, `exercises`, `lastPerformed`) y `SessionRecord` (historial de sesiones).
- [x] Implementar `UnitConverter` con conversión matemática precisa ($1\text{ kg} \approx 2.20462\text{ lbs}$) bidireccional y formateo numérico limpio.
- [x] Implementar `OverloadEngine` con precarga automática de la última sesión y detección de ejercicios con `completedWithEase == true`.
- [x] Implementar `StorageService` (Hive Offline-First) con persistencia de rutinas, sesiones, preferencia de unidad y datos semilla iniciales.
- [x] Implementar `WorkoutController` (`lib/controllers/workout_controller.dart`) con cálculo de racha activa (`currentStreakDays`), consultas por día/mes y gestión de sesiones.

## Fase 3: Sistema de Diseño, Minimalismo, Selector de Series y Calendario (`@ui_ux_designer`)
- [x] Implementar `GyminiTheme` (`lib/theme/gymini_theme.dart`) con paleta **Dark Lavender / Midnight Zen** (`#0D0B12`, `#1A1626`, `#201A2E`, `#C4B5FD`, `#A7D7C5`, `#F3F0F8`, `#A59FB3`, `#2E263D`), bordes de `1px` y radios de `16px-20px`.
- [x] Simplificar tarjetas de entrenamiento y añadir selector desplegable (`Dropdown` de `1 a 10 series`) en `ExerciseTrackingCard` y `ExerciseFormModal`.
- [x] Construir Menú Lateral Desplegable (`GyminiDrawer` en `lib/widgets/gymini_drawer.dart`) con opciones *"Mis Rutinas / Entrenar"* y *"Calendario y Rachas"*.
- [x] Construir Pantalla de Calendario Mensual (`CalendarScreen` en `lib/screens/calendar_screen.dart`) con cuadrícula oscura, días con asistencia resaltados en `#C4B5FD` / `#86EFAC`, contador de racha (`🔥 Racha: X días consecutivos`) y modal centrado (`showDialog`) con detalle de sesión.
- [x] Construir `ProgressiveOverloadModal`, `RoutineCard`, `DashboardScreen`, `ActiveWorkoutScreen` y `RoutineEditorScreen`.

## Fase 4: Compatibilidad Android Moderna, Icono Personalizado, QA y GitHub (`@qa_reviewer`)
- [x] Actualizar `android/app/build.gradle` con `compileSdkVersion 35`, `targetSdkVersion 35`, `buildToolsVersion "35.0.1"` y `minSdkVersion 24`.
- [x] Configurar `flutter_launcher_icons` en `pubspec.yaml`, generar `assets/icon/app_icon.png` y ejecutar `dart run flutter_launcher_icons`.
- [x] Ejecutar `flutter analyze` asegurando **0 errores y 0 advertencias** (`No issues found!`).
- [x] Compilar APK de producción (`flutter build apk --release`) y copiar a `./Gymini.apk`.
- [x] Inicializar repositorio Git, realizar commit y publicar en GitHub mediante `gh repo create Gymini --public --source=. --remote=origin --push`.
