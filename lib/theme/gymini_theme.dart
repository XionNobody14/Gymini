import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de Diseño "Dark Lavender / Midnight Zen" para Gymini.
class GyminiTheme {
  GyminiTheme._();

  // ===========================================================================
  // PALETA DE COLORES: DARK LAVENDER / MIDNIGHT ZEN
  // ===========================================================================

  /// Fondo principal (Scaffold): Negro grafito profundo (#0D0B12 / #121018)
  static const Color scaffoldBg = Color(0xFF0D0B12);
  static const Color scaffoldSecondary = Color(0xFF121018);

  /// Superficies y tarjetas: Morado oscuro pizarra con elevación sutil (#1A1626 / #201A2E)
  static const Color surfaceCard = Color(0xFF1A1626);
  static const Color surfaceElevated = Color(0xFF201A2E);
  static const Color surfaceInput = Color(0xFF151120);

  /// Color de acento primario: Morado pastel suave / lila luminoso (#C4B5FD / #B8A4F8)
  static const Color primaryLavender = Color(0xFFC4B5FD);
  static const Color primaryLavenderDeep = Color(0xFFB8A4F8);
  static const Color onPrimaryDark = Color(0xFF130E21);

  /// Color de acento secundario: Verde salvia / menta tenue (#A7D7C5 / #86EFAC)
  /// Exclusivo para indicadores de éxito o sugerencias de sobrecarga progresiva.
  static const Color sageSuccess = Color(0xFFA7D7C5);
  static const Color mintOverload = Color(0xFF86EFAC);
  static const Color sageSurfaceTint = Color(0xFF172924);

  /// Tipografía y texto: Blanco roto (#F3F0F8) y gris lavanda apagado (#A59FB3 / #9CA3AF)
  static const Color textPrimary = Color(0xFFF3F0F8);
  static const Color textSecondary = Color(0xFFA59FB3);
  static const Color textMuted = Color(0xFF9CA3AF);

  /// Bordes y divisores: Delgados (1px), casi imperceptibles (#2E263D)
  static const Color borderSubtle = Color(0xFF2E263D);
  static const Color borderActiveLavender = Color(0xFF52437A);
  static const Color dangerCoral = Color(0xFFFCA5A5);

  // ===========================================================================
  // CONSTANTES GEOMÉTRICAS
  // ===========================================================================
  static const double cardRadius = 18.0; // Dentro del rango 16px - 20px
  static const double modalRadius = 20.0;
  static const double pillRadius = 12.0;

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      surface: surfaceCard,
      primary: primaryLavender,
      onPrimary: onPrimaryDark,
      secondary: sageSuccess,
      onSecondary: onPrimaryDark,
      onSurface: textPrimary,
      outline: borderSubtle,
      error: dangerCoral,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: borderSubtle,
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: scaffoldBg,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(modalRadius),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: scaffoldSecondary,
        modalBackgroundColor: scaffoldSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(modalRadius)),
          side: BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceInput,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLavender, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerCoral, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerCoral, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLavender,
          foregroundColor: onPrimaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderSubtle, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLavender,
        foregroundColor: onPrimaryDark,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
