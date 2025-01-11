import 'package:flutter/material.dart';

class ThemeConfig {
  static const lightPrimary = Color(0xFF1A73E8);      
  static const lightSurface = Color(0xFFE8F1FB);     
  static const lightBackground = Color(0xFFF5F9FF);   
  static const lightAccent = Color(0xFF0D47A1);       
  static const lightText = Color(0xFF2C3E50);        
  static const lightCard = Colors.white;
  static const lightDivider = Color(0xFFCFE3FF);      
  
  // Ocean Gradient Light Theme Colors
  static const lightGradientStart = Color(0xFFF0F5FA);  
  static const lightGradientMiddle = Color(0xFFE5EEF9); 
  static const lightGradientEnd = Color(0xFFDAE7F8);    
  static const lightDeepBlue = Color(0xFF0A4FA8);       
  static const lightSurfaceBlue = Color(0xFF4A90E2);    
  static const lightBlueAccent = Color(0xFF64B5F6);     
  static const lightAccentBlue = Color(0xFF0288D1);    
  static const lightWhiteWater = Color(0xFFECF3FF);     

  static const darkPrimary = Color(0xFF1976D2);         
  static const darkSurface = Color(0xFF1A2634);       
  static const darkBackground = Color(0xFF0F1924);      
  static const darkAccent = Color(0xFF4FC3F7);          
  static const darkText = Color(0xFFE3F2FD);           
  static const darkCard = Color(0xFF1E2A3A);           
  static const darkDivider = Color(0xFF2A3C50);      
  static const darkBlueAccent = Color(0xFF64B5F6);    
  static const darkDeepBlue = Color(0xFF0A4FA8);      
  static const darkAccentBlue = Color(0xFF0288D1);      
  static const Color textDark = Color(0xFF2D3142);  

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