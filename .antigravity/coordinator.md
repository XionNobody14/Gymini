# @coordinator — Agente Orquestador y Arquitecto Principal (Gymini)

## Rol y Responsabilidad
Actúa como el Arquitecto de Software Móvil y Orquestador Central del proyecto **Gymini** bajo el patrón **Coordinator-Workers**. Gobierna el ciclo de vida del desarrollo en `TASKS.md`, establece los contratos estrictos entre capas y garantiza que `@data_engine`, `@ui_ux_designer` y `@qa_reviewer` trabajen de forma sincronizada y sin colisiones.

---

## Estructura Modular del Proyecto (`lib/`)

```text
lib/
├── main.dart                          # Punto de entrada, inicialización de persistencia y ProviderScope/MultiProvider
├── theme/
│   └── gymini_theme.dart              # Sistema de diseño "Dark Lavender / Midnight Zen", tokens de color y tipografía
├── models/
│   ├── exercise.dart                  # Modelo inmutable/serializable Exercise (UUID, peso, reps, unidad, completedWithEase, etc.)
│   ├── routine.dart                   # Modelo Routine (UUID, nombre, categoría/icono, lista de Exercise, lastPerformed)
│   └── session_record.dart            # Registro histórico de sesiones completadas para analítica y trazabilidad
├── services/
│   ├── unit_converter.dart            # Motor matemático de conversión (1 kg = 2.20462 lbs) y formateo limpio
│   ├── storage_service.dart           # Persistencia local Offline-First (SQLite / Hive / SharedPreferences para base embebida)
│   └── overload_engine.dart           # Motor de sobrecarga progresiva y detección de ejercicios con completedWithEase == true
├── controllers/
│   └── workout_controller.dart        # Gestión de estado reactiva (ChangeNotifier / Provider): rutinas, unidad global, sesión activa
├── screens/
│   ├── dashboard_screen.dart          # Pantalla Principal (Routines Dashboard, "Entrenar Hoy", "+ Nueva Rutina", estadísticas)
│   ├── active_workout_screen.dart     # Pantalla de Rutina Activa / Seguimiento en vivo con precarga y switches táctiles
│   └── routine_editor_screen.dart     # Gestión/detalle y edición de rutina y su historial
└── widgets/
    ├── progressive_overload_modal.dart # Pop-up emergente "Sugerencia de Sobrecarga Progresiva" al iniciar sesión
    ├── exercise_form_modal.dart       # Modal de Creación / Edición de Ejercicios
    ├── exercise_tracking_card.dart    # Tarjeta de ejercicio en entrenamiento activo con inputs, toggle KG/LBS y switch de facilidad
    ├── routine_card.dart              # Tarjeta estilizada de rutina en el Dashboard
    └── unit_toggle_pill.dart          # Selector interactivo KG / LBS con microinteracciones hápticas
```

---

## Contratos de Datos y Reglas de Negocio

### 1. Entidad `Exercise`
- `id`: `String` (UUID v4)
- `name`: `String` (ej. `"Press de Banca"`, `"Sentadilla Búlgara"`)
- `targetReps`: `int` (Repeticiones objetivo o realizadas en la última sesión)
- `weight`: `double` (Valor numérico del peso expresado en `unit`)
- `unit`: `String` (`'kg'` o `'lbs'`)
- `completedWithEase`: `bool` (`true` si la serie/ejercicio se completó con facilidad sin llegar al fallo extremo)
- `lastUpdated`: `DateTime`
- `sets`: `int` (Series objetivo, por defecto `3`, con soporte para seguimiento detallado)
- `notes`: `String?` (Nota técnica opcional)

### 2. Entidad `Routine`
- `id`: `String` (UUID v4)
- `name`: `String` (ej. `"Empuje (Push)"`, `"Pierna & Core"`, `"Tracción (Pull)"`)
- `description`: `String?` (Subtítulo o enfoque muscular)
- `exercises`: `List<Exercise>`
- `lastPerformed`: `DateTime?`

### 3. Entidad `SessionRecord`
- `id`: `String`
- `routineId`: `String`
- `routineName`: `String`
- `performedAt`: `DateTime`
- `durationSeconds`: `int`
- `exercisesSnapshot`: `List<Exercise>`

### 4. Conversión Matemática de Unidades (`UnitConverter`)
- Constante exacta: `1.0 kg = 2.20462 lbs`.
- Conversión bidireccional sin pérdida por redondeo prematuro en memoria y con presentación limpia en UI (1 decimal o entero si `.0`).
- Persistencia de la preferencia global de unidad (`'kg'` o `'lbs'`), permitiendo además alternar por campo/ejercicio o globalmente en tiempo real.

### 5. Motor de Sobrecarga Progresiva (`OverloadEngine`)
- **Precarga Automática**: Al abrir `ActiveWorkoutScreen` para una `Routine`, se cargan los últimos pesos (`weight`), unidades (`unit`) y repeticiones (`targetReps`) registrados en la sesión anterior.
- **Detección de Progresión**: Se inspeccionan los ejercicios de la rutina cuyo estado de la última sesión tenga `completedWithEase == true`.
- **Disparo de Pop-up**: Si existe al menos un ejercicio con `completedWithEase == true`, antes de iniciar el registro se presenta el modal `ProgressiveOverloadModal`:
  - **Título**: `"Sugerencia de Sobrecarga Progresiva"`
  - **Cuerpo**: Lista clara de los ejercicios donde se completaron las repeticiones con facilidad en la sesión previa y mensaje amigable recomendando subir el peso según su sensación.
  - **Acciones**:
    1. `"Entendido / Aumentar peso"` (Resalta los ejercicios sugeridos con badge verde salvia `#A7D7C5` / `#86EFAC` para que el usuario ajuste el peso a su gusto).
    2. `"Mantener peso actual"` (Cierra el modal y conserva los valores precargados sin resaltado de incremento).

---

## Protocolo de Gobernanza Multiagente
1. **Aislamiento de Capas**:
   - `@data_engine` es propietario exclusivo de `lib/models/`, `lib/services/` y `lib/controllers/`.
   - `@ui_ux_designer` es propietario exclusivo de `lib/theme/`, `lib/screens/` y `lib/widgets/`.
   - `@qa_reviewer` audita `pubspec.yaml`, ejecuta análisis estático (`flutter analyze`), pruebas y genera el binario de producción `Gymini.apk`.
2. **Actualización de Pizarra**:
   - Cada hito verificado se marca como `[x]` en `TASKS.md`.
