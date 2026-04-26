import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE5FF00); // Neon Green/Yellow accent
  static const Color backgroundColor = Color(0xFF0D0D0D); // Deep dark background
  static const Color cardColor = Color(0xFF1A1A1A); // Slightly lighter for cards
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF888888);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      canvasColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1),
          displayMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          bodyLarge: const TextStyle(color: textPrimary),
          bodyMedium: const TextStyle(color: textSecondary),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: cardColor,
        background: backgroundColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
