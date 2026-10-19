# @data_engine — Agente de Persistencia y Lógica de Negocio (Gymini)

## Rol y Alcance
Responsable exclusivo de la capa de dominio, persistencia local Offline-First y gestión de estado reactiva:
- `pubspec.yaml` (Dependencias de estado, persistencia local, UUID, tipografía e iconos)
- `lib/models/` (`exercise.dart`, `routine.dart`, `session_record.dart`)
- `lib/services/` (`unit_converter.dart`, `storage_service.dart`, `overload_engine.dart`)
- `lib/controllers/` (`workout_controller.dart`)

---

## Especificaciones Técnicas

### 1. Persistencia Local Offline-First (`StorageService`)
- Almacenamiento local embebido, sin necesidad de conexión a internet ni autenticación.
- Utiliza **Hive** (`hive` + `hive_flutter`) para almacenamiento de cajas locales rápidas y transaccionales:
  - `routines_box`: Almacena todas las instancias de `Routine` con su lista de `Exercise` y estado de la última sesión.
  - `sessions_box`: Almacena el historial cronológico (`SessionRecord`) de entrenamientos finalizados.
  - `settings_box`: Almacena preferencias globales del usuario (`preferred_unit`: `'kg'` o `'lbs'`, semilla inicial cargada).
- **Datos Semilla Iniciales (Seed Data)**:
  - Si es la primera ejecución de Gymini, precarga 3 rutinas estructuradas realistas (`"Empuje (Push)"`, `"Tracción (Pull)"` y `"Pierna & Core"`) con ejercicios reales (ej. *Press de Banca*, *Press Inclinado con Mancuernas*, *Sentadilla Búlgara*, *Peso Muerto Rumano*, *Dominadas Lastre*), incluyendo ejercicios marcados con `completedWithEase: true` en su sesión previa para demostrar de inmediato el motor de Sobrecarga Progresiva.

### 2. Conversión Matemática de Unidades (`UnitConverter`)
- Relación exacta:
  $$1\text{ kg} = 2.20462\text{ lbs}$$
  $$1\text{ lb} = \frac{1}{2.20462}\text{ kg}$$
- Funciones clave:
  - `double convert(double value, {required String from, required String to})`
  - `double toKg(double value, String unit)`
  - `double toLbs(double value, String unit)`
  - `String formatWeight(double value)`: Muestra enteros sin `.0` (ej. `80`) o 1 decimal limpio (ej. `82.5`) para evitar ruido visual.

### 3. Motor de Sobrecarga Progresiva (`OverloadEngine`)
- **Precarga de Última Sesión**:
  - Cada `Routine` conserva los pesos (`weight`), unidades (`unit`), repeticiones (`targetReps`) y bandera `completedWithEase` registrados al finalizar la última sesión.
- **Detección de Ejercicios Candidatos a Sobrecarga**:
  - `List<Exercise> detectOverloadCandidates(Routine routine)` devuelve la lista de ejercicios de la rutina donde `exercise.completedWithEase == true`.
- **Actualización al Finalizar Entrenamiento**:
  - Cuando el usuario pulsa `"Finalizar Entrenamiento"`, `WorkoutController`:
    1. Actualiza cada `Exercise` de la `Routine` con el nuevo peso, unidad, repeticiones realizadas, bandera `completedWithEase` de la sesión actual y `lastUpdated = DateTime.now()`.
    2. Actualiza `routine.lastPerformed = DateTime.now()`.
    3. Guarda un nuevo `SessionRecord` en `sessions_box`.
    4. Persiste los cambios en `routines_box` y notifica a la UI.
