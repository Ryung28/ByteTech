import 'package:flutter/material.dart';

class ThemeConfig {
  // Ocean Theme Light Colors
  static const lightPrimary = Color(0xFF1A73E8);      // Ocean Blue
  static const lightSurface = Color(0xFFE8F1FB);      // Soft Sky Blue
  static const lightBackground = Color(0xFFF5F9FF);    // Pale Ocean Blue
  static const lightAccent = Color(0xFF0D47A1);       // Deep Ocean Blue
  static const lightText = Color(0xFF2C3E50);         // Dark Ocean Gray
  static const lightCard = Colors.white;
  static const lightDivider = Color(0xFFCFE3FF);      // Light Ocean Mist
  
  // Ocean Gradient Light Theme Colors
  static const lightGradientStart = Color(0xFFF0F5FA);  // Lightest Ocean Mist
  static const lightGradientMiddle = Color(0xFFE5EEF9); // Ocean Haze
  static const lightGradientEnd = Color(0xFFDAE7F8);    // Deeper Ocean Mist
  static const lightDeepBlue = Color(0xFF0A4FA8);       // Deep Ocean
  static const lightSurfaceBlue = Color(0xFF4A90E2);    // Clear Ocean Blue
  static const lightBlueAccent = Color(0xFF64B5F6);     // Shallow Water Blue
  static const lightAccentBlue = Color(0xFF0288D1);     // Marine Blue
  static const lightWhiteWater = Color(0xFFECF3FF);     

  // Ocean Theme Dark Colors
  static const darkPrimary = Color(0xFF1976D2);         // Night Ocean Blue
  static const darkSurface = Color(0xFF1A2634);         // Deep Sea
  static const darkBackground = Color(0xFF0F1924);      // Abyssal Blue
  static const darkAccent = Color(0xFF4FC3F7);          // Bioluminescent Blue
  static const darkText = Color(0xFFE3F2FD);            // Ocean Foam White
  static const darkCard = Color(0xFF1E2A3A);            // Deep Water
  static const darkDivider = Color(0xFF2A3C50);         // Ocean Trench
  static const darkBlueAccent = Color(0xFF64B5F6);      // Bright Ocean Blue
  static const darkDeepBlue = Color(0xFF0A4FA8);       // Deep Ocean
  static const darkAccentBlue = Color(0xFF0288D1);      // Marine Blue
  static const Color textDark = Color(0xFF2D3142);  // You can adjust this hex color

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightGradientStart,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightAccent,
      surface: lightSurface,
      background: lightGradientStart,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightText,
      onBackground: lightText,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightCard,
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightText.withOpacity(0.5),
    ),
    dividerTheme: DividerThemeData(
      color: lightDivider,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
      titleLarge: TextStyle(color: lightText),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkAccent,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      tertiary: darkBlueAccent,
      primaryContainer: darkDeepBlue,
      secondaryContainer: darkAccentBlue,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardTheme(
      color: darkCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: darkPrimary.withOpacity(0.2),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: darkPrimary,
      unselectedItemColor: Colors.white.withOpacity(0.5),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 22, 
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
      ),
    ),
  );
} 