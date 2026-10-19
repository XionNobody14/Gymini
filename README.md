# Gymini — Seguimiento Estructurado de Entrenamientos, Rachas y Sobrecarga Progresiva

**Gymini** es una aplicación móvil en **Flutter** diseñada bajo la estética minimalista **"Dark Lavender / Midnight Zen"** para el registro estructurado de entrenamientos en el gimnasio, selector rápido de series (`1 a 10`), conversión matemática instantánea entre `kg` y `lbs` ($1\text{ kg} \approx 2.20462\text{ lbs}$), calendario mensual con contador de rachas y un motor inteligente de **Sobrecarga Progresiva** con persistencia local **Offline-First**.

---

## ✨ Características Principales
1. **Interfaz Minimalista e Intuitiva (Dark Lavender / Midnight Zen)**:
   - Paleta oscura de alto contraste suave (`#0D0B12`, `#1A1626`, `#C4B5FD`, `#A7D7C5`, `#86EFAC`, bordes `#2E263D` de `1px`).
   - Selector tipo **Dropdown (`1 a 10 series`)** integrado tanto en la configuración de ejercicios como durante el entrenamiento en vivo.
   - Conversión matemática instantánea entre **KG** y **LBS** y switch táctil **«¿Completado con facilidad?»**.
2. **Menú Lateral (Navigation Drawer) y Calendario Mensual con Rachas**:
   - Navegación fluida entre **"Mis Rutinas / Entrenar"** y **"Calendario y Rachas"**.
   - Cuadrícula mensual con indicadores luminosos en los días entrenados y banner superior de racha activa (`🔥 Racha: X días consecutivos`).
   - **Modal Detalle al Centro (`showDialog`)**: Al tocar cualquier día con entrenamiento registrado, despliega la rutina realizada, fecha/hora y el listado de ejercicios con series, repeticiones y peso utilizado.
3. **Motor de Sobrecarga Progresiva & Precarga Automática**:
   - Precarga de pesos y repeticiones de la última sesión y detección automática de ejercicios superados con facilidad (`ProgressiveOverloadModal`).
4. **Compatibilidad Android Moderna**:
   - Configurado con `compileSdkVersion 35`, `targetSdkVersion 35` (Android 15) y `minSdkVersion 24`.

---

## 🖼️ Cómo Actualizar el Icono Personalizado de la App

El proyecto incluye `flutter_launcher_icons` preconfigurado apuntando a `assets/icon/app_icon.png`.  
Para reemplazar el icono con tu propia imagen:
1. Sustituye el archivo `assets/icon/app_icon.png` por tu imagen cuadrada (recomendado `1024x1024` px en formato PNG).
2. Ejecuta en la raíz del proyecto:
   ```bash
   dart run flutter_launcher_icons
   ```
3. Recompila el APK de producción:
   ```bash
   flutter build apk --release
   ```
