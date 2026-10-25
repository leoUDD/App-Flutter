import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0B0B0E);
  static const surface = Color(0xFF16171D);
  static const surfaceAlt = Color(0xFF1E1F26);
  static const avatar = Color(0xFF23252D);
  static const border = Color(0xFF2A2C35);
  static const text = Color(0xFFF4F4F6);
  static const textMuted = Color(0xFFA3A5B1);
  static const accent = Color(0xFFEF3340);
  static const accentSoft = Color(0xFFFF5A66);
  static const textSecondary = Color(0xFFC9CBD3);
  static const gold = Color(0xFFF5C542);
  static const silver = Color(0xFFC0C5CE);
  static const bronze = Color(0xFFCD7F32);
  static const championSurface = Color(0xFF1B1710);
}

ThemeData buildAppTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

  final textTheme = GoogleFonts.sairaTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.text,
    ),
    textTheme: textTheme.copyWith(
      headlineLarge: GoogleFonts.saira(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      headlineMedium: GoogleFonts.saira(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.accentSoft
              : AppColors.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.accentSoft
              : AppColors.textMuted,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
  );
}

/// Color predominante de cada escudería (identidad visual del equipo).
Color teamColor(String teamId) {
  switch (teamId) {
    case 'ferrari': // Rojo Rosso Corsa
      return const Color(0xFFDC0000);
    case 'mercedes': // Negro
      return const Color(0xFF000000);
    case 'red_bull': // Azul oscuro
      return const Color(0xFF1E3A8A);
    case 'mclaren': // Naranja papaya
      return const Color(0xFFFF8000);
    case 'aston_martin': // Verde británico
      return const Color(0xFF006F62);
    case 'alpine': // Rosado
      return const Color(0xFFFF87BC);
    case 'williams': // Celeste
      return const Color(0xFF64C4FF);
    case 'rb': // Racing Bulls: blanco limpio (con un matiz azulado)
      return const Color(0xFFDDE6F5);
    case 'audi': // Verde lima
      return const Color(0xFFA3E635);
    case 'haas': // Rojo oscuro
      return const Color(0xFFA50F1E);
    case 'cadillac': // Gris
      return const Color(0xFF909090);
    case 'sauber': // Kick Sauber (equipo de 2024-2025, no está en la tabla)
      return const Color(0xFF52E252);
    default:
      return AppColors.textMuted;
  }
}
