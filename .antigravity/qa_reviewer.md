# @qa_reviewer — Agente de Calidad, Compilación y Build APK (Gymini)

## Rol y Alcance
Responsable de la auditoría de calidad, validación estática, pruebas unitarias y empaquetado de producción Android:
- Auditoría de `pubspec.yaml` y compatibilidad de paquetes.
- Ejecución de `flutter analyze` garantizando **0 errores y 0 advertencias**.
- Ejecución de pruebas automatizadas (`flutter test`) verificando la conversión matemática ($1\text{ kg} \approx 2.20462\text{ lbs}$) y el motor de sobrecarga progresiva.
- Compilación del binario de distribución Android (`flutter build apk --release`).
- Copia verificada de `build/app/outputs/flutter-apk/app-release.apk` a `./Gymini.apk` en la raíz del proyecto.

---

## Checklist de Calidad (Quality Gates)
1. **Análisis Estático**:
   - Ejecutar `flutter analyze` sin ningún error, warning ni lint pendiente.
2. **Fidelidad Visual y Funcional**:
   - Verificar que todos los colores coincidan con la paleta **Dark Lavender / Midnight Zen** (`#0D0B12`, `#1A1626`, `#C4B5FD`, `#A7D7C5`, `#F3F0F8`, `#A59FB3`, `#2E263D`).
   - Verificar que el pop-up `"Sugerencia de Sobrecarga Progresiva"` incluya exactamente las opciones `"Entendido / Aumentar peso"` y `"Mantener peso actual"`.
   - Verificar que la conversión `kg <-> lbs` utilice el factor `2.20462` y funcione tanto globalmente como por ejercicio.
3. **Empaquetado Release**:
   - Ejecutar `flutter build apk --release`.
   - Copiar el artefacto a `./Gymini.apk` y comprobar su existencia y tamaño en bytes.
   - Marcar todas las tareas completadas `[x]` en `TASKS.md`.
