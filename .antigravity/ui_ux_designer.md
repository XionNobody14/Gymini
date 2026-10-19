# @ui_ux_designer — Agente de Interfaz y Experiencia Visual (Gymini)

## Rol y Alcance
Responsable exclusivo del sistema de diseño **"Dark Lavender / Midnight Zen"**, componentes visuales, pantallas y microinteracciones:
- `lib/theme/` (`gymini_theme.dart`)
- `lib/screens/` (`dashboard_screen.dart`, `active_workout_screen.dart`, `routine_editor_screen.dart`)
- `lib/widgets/` (`progressive_overload_modal.dart`, `exercise_form_modal.dart`, `exercise_tracking_card.dart`, `routine_card.dart`, `unit_toggle_pill.dart`)

---

## Sistema de Diseño: "Dark Lavender / Midnight Zen"

### Paleta de Colores Oficial
| Token | Hex | Uso |
| :--- | :--- | :--- |
| `scaffoldBg` | `#0D0B12` | Fondo principal profundo (Negro grafito profundo) |
| `scaffoldBgAlt` | `#121018` | Variación sutil para fondos de modales y hojas inferiores |
| `surfaceCard` | `#1A1626` | Superficies de tarjetas principales con elevación sutil |
| `surfaceElevated` | `#201A2E` | Tarjetas interactivas activas, campos de entrada e indicadores |
| `primaryLavender` | `#C4B5FD` | Acento primario: botones de acción, switches activos, focos |
| `primaryLavenderDeep` | `#B8A4F8` | Variación de presión / hover del acento primario |
| `accentSage` | `#A7D7C5` | Acento secundario exclusivo para éxito y sugerencias de sobrecarga |
| `accentMintBright` | `#86EFAC` | Destacado puntual en iconos de sobrecarga progresiva y "Completado con facilidad" |
| `textPrimary` | `#F3F0F8` | Blanco roto para títulos principales, pesos y métricas |
| `textSecondary` | `#A59FB3` | Gris lavanda apagado (`#9CA3AF` / `#A59FB3`) para etiquetas y unidades |
| `borderSubtle` | `#2E263D` | Bordes y divisores delgados de `1px`, casi imperceptibles |

### Reglas de Geometría y Microinteracciones
1. **Tarjetas y Contenedores**:
   - Curvatura suave `BorderRadius.circular(18)` (rango `16px - 20px`).
   - Borde de `1.0px` en color `#2E263D` (o `#A7D7C5` con opacidad sutil cuando el ejercicio tiene sugerencia activa de sobrecarga o está marcado como completado con facilidad).
   - Cero gradientes chillones; superficies mate con jerarquía tipográfica clara.
2. **Feedback Táctil y Animaciones**:
   - `HapticFeedback.lightImpact()` y `HapticFeedback.selectionClick()` al alternar el switch de `"Completado con facilidad"`, cambiar entre `KG` y `LBS`, o ajustar pesos/repeticiones.
   - `AnimatedContainer`, `AnimatedSwitcher` y transiciones suaves (`Curves.easeOutCubic`, `220ms`) en cambios de estado.

---

## Pantallas y Flujos Clave

1. **Routines Dashboard (`DashboardScreen`)**:
   - Encabezado con saludo contextual minimalista, insignia **Gymini** y toggle global rápido `KG / LBS`.
   - Resumen compacto de consistencia (rutinas activas, última sesión, candidatos a sobrecarga listos).
   - Tarjeta destacada **"Entrenar Hoy"** (selecciona inteligentemente la siguiente rutina sugerida o permite elegir cualquiera al instante).
   - Listado de rutinas con tarjetas estilizadas (`RoutineCard`), indicadores de ejercicios listos para sobrecarga y acciones de edición/creación de ejercicios.
   - Botón flotante (`FloatingActionButton.extended`) **"+ Nueva Rutina"**.

2. **Pantalla de Rutina Activa (`ActiveWorkoutScreen`)**:
   - Al abrirse, verifica mediante `OverloadEngine` si hay ejercicios con `completedWithEase == true` en la sesión previa y despliega automáticamente el pop-up **`ProgressiveOverloadModal`**.
   - Cronómetro sutil de sesión en vivo en el encabezado y selector global/individual `KG / LBS`.
   - Lista de tarjetas `ExerciseTrackingCard`:
     - Inputs numéricos limpios y botones rápidos `-/+` para **Peso** y **Repeticiones**, precargados con los valores de la última sesión.
     - Toggle interactivo rápido `KG / LBS` que convierte matemáticamente el valor en el acto ($1\text{ kg} \approx 2.20462\text{ lbs}$).
     - Switch / tarjeta interactiva estilizada **"Completado con facilidad"** con icono de llama/check en verde salvia (`#A7D7C5` / `#86EFAC`).
   - Botón fijo inferior **"Finalizar Entrenamiento"** que persiste la sesión y prepara las sugerencias para el próximo entrenamiento.

3. **Pop-up de Sobrecarga Progresiva (`ProgressiveOverloadModal`)**:
   - Título: `"Sugerencia de Sobrecarga Progresiva"`.
   - Lista de los ejercicios específicos donde se completaron las repeticiones con facilidad en la sesión previa, mostrando su último peso y repeticiones.
   - Mensaje amigable recomendando subir el peso en esos ejercicios según la sensación del usuario (sin forzar un incremento numérico rígido).
   - Botones de acción:
     - **"Entendido / Aumentar peso"** (primario en `#C4B5FD` / `#A7D7C5`)
     - **"Mantener peso actual"** (secundario fantasma con borde `#2E263D`)

4. **Modal de Creación / Edición de Ejercicios (`ExerciseFormModal`)**:
   - Formulario directo y limpio: nombre del ejercicio, peso inicial, selector de unidad (`KG` / `LBS`) y repeticiones objetivo.
