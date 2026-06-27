import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors ────────────────────────────────────────────────────────
  static const Color primaryBlue    = Color(0xFF2563EB);
  static const Color primaryIndigo  = Color(0xFF4F46E5);
  static const Color accentCyan     = Color(0xFF06B6D4);
  static const Color accentEmerald  = Color(0xFF10B981);
  static const Color surfaceDark    = Color(0xFF0F172A);
  static const Color surfaceCard    = Color(0xFF1E293B);
  static const Color surfaceSheet   = Color(0xFF1A2540);
  static const Color borderColor    = Color(0xFF334155);
  static const Color textPrimary    = Color(0xFFF1F5F9);
  static const Color textSecondary  = Color(0xFF94A3B8);
  static const Color errorRed       = Color(0xFFEF4444);
  static const Color successGreen   = Color(0xFF22C55E);
  static const Color warningAmber   = Color(0xFFF59E0B);

  // ─── Gradient ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scannerGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBg = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentCyan,
        tertiary: accentEmerald,
        surface: surfaceDark,
        onSurface: textPrimary,
        error: errorRed,
      ),
      scaffoldBackgroundColor: surfaceDark,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: textPrimary, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: textPrimary, letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceCard,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
      ),
    );
  }

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentCyan,
        surface: Color(0xFFF8FAFC),
        onSurface: Color(0xFF0F172A),
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
    );
  }
}
