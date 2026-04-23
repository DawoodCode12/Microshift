import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const bg      = Color(0xFFF7F8FA);   // very light grey-white page
  static const surface = Color(0xFFFFFFFF);   // pure white cards/inputs
  static const card    = Color(0xFFFFFFFF);   // white cards
  static const border  = Color(0xFFE2E8F0);   // soft grey border

  // Brand / interactive
  static const accent     = Color(0xFF2563EB); // clear blue — buttons, links
  static const accentGlow = Color(0x1A2563EB); // very faint blue tint

  // Semantic
  static const success = Color(0xFF16A34A); // green
  static const warning = Color(0xFFD97706); // amber
  static const danger  = Color(0xFFDC2626); // red

  // Text
  static const textPrimary   = Color(0xFF0F172A); // near-black
  static const textSecondary = Color(0xFF475569); // slate-grey
  static const textMuted     = Color(0xFF94A3B8); // light slate
}

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      background: AppColors.bg,
      surface: AppColors.surface,
      primary: AppColors.accent,
      secondary: AppColors.success,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      shadowColor: Color(0x0A000000),
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      headlineLarge:  GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
      headlineMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge:     GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge:      GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      bodyMedium:     GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
      labelSmall:     GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
      hintStyle:  GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textMuted,
      elevation: 0,
    ),
  );
}
