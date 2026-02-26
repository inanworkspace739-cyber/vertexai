import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Luxury Dark Mode Theme - "Fantastic" Aesthetic
class AppTheme {
  // ══════════════════════════════════════════════════════════════════════════
  // CORE COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Deep charcoal background
  static const Color backgroundDark = Color(0xFF121212);

  /// Midnight blue secondary background
  static const Color backgroundMidnight = Color(0xFF0A0E14);

  /// Surface color for cards/glass elements
  static const Color surfaceColor = Color(0xFF1A1A2E);

  /// Electric Violet - Primary accent
  static const Color accentViolet = Color(0xFF8B5CF6);

  /// Neon Magenta - Secondary accent
  static const Color accentMagenta = Color(0xFFEC4899);

  /// Neon Cyan - Tertiary accent
  static const Color accentCyan = Color(0xFF06B6D4);

  /// Premium Grey - Dark slate for a sophisticated base
  static const Color premiumGrey = Color(0xFF1F2937);

  /// Genius Grey - Sleek metallic grey for icons and accents
  static const Color geniusGrey = Color(0xFF94A3B8);

  /// Glass border color
  static const Color glassBorder = Color(0x33FFFFFF);

  /// Glass background (low opacity white)
  static const Color glassBackground = Color(0x12FFFFFF);

  /// Text primary
  static const Color textPrimary = Color(0xFFFAFAFA);

  /// Text secondary
  static const Color textSecondary = Color(0xB3FFFFFF);

  /// Text muted
  static const Color textMuted = Color(0x80FFFFFF);

  // ══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ══════════════════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentViolet, accentMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient canvasGlow = LinearGradient(
    colors: [Color(0x408B5CF6), Color(0x20EC4899), Color(0x0006B6D4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Cyan to Blue gradient for Prompt Academy card
  static const LinearGradient cyanBlueGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Violet to Magenta gradient for Image Generator card
  static const LinearGradient violetMagentaGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle mesh gradient for selection screen background
  static const LinearGradient meshGradient = LinearGradient(
    colors: [Color(0xFF0A0E14), Color(0xFF1E1E2E), Color(0xFF0A0E14)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Genius Grey Gradient
  static const LinearGradient geniusGradient = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // DECORATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Glassmorphic container decoration
  static BoxDecoration glassDecoration({
    double borderRadius = 24,
    Color? backgroundColor,
    double borderOpacity = 0.15,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1,
      ),
    );
  }

  /// Canvas glow shadow for main image
  static List<BoxShadow> canvasGlowShadow = [
    BoxShadow(
      color: accentViolet.withOpacity(0.3),
      blurRadius: 40,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: accentMagenta.withOpacity(0.2),
      blurRadius: 60,
      spreadRadius: -20,
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: accentViolet,
        secondary: accentMagenta,
        tertiary: accentCyan,
        surface: surfaceColor,
        onSurface: textPrimary,
        onPrimary: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lexend(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          headlineLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          titleLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textMuted),
          labelLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: TextStyle(color: textSecondary),
          labelSmall: TextStyle(color: textMuted),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        hintStyle: const TextStyle(color: textMuted, fontSize: 15),
        labelStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accentViolet, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentViolet,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentViolet,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: glassBorder),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundMidnight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),

      // Dropdown Menu Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: textPrimary),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: glassBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: glassBorder),
          ),
        ),
      ),
    );
  }
}
