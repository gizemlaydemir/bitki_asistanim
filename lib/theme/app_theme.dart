import 'package:flutter/material.dart';

class AppTheme {
  // 🌼 LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F8F3),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1B5E20),
      secondary: Color(0xFF43A047),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF4F8F3),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF1B5E20),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFF1B5E20)),
    ),

    // 🔧 BURASI GÜNCELLENDİ
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF1B5E20),
      unselectedItemColor: Color(0xFF8F9E8F),
      type: BottomNavigationBarType.fixed,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF43A047),
      foregroundColor: Colors.white,
    ),
  );

  // 🌙 DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF43A047),
      secondary: Color(0xFF66BB6A),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // 🔧 BURASI GÜNCELLENDİ
    cardTheme: const CardThemeData(
      color: Color(0xFF1A1A1A),
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: const Color(0xFF66BB6A),
      unselectedItemColor: Colors.grey.shade600,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF66BB6A),
      foregroundColor: Colors.black,
    ),
  );
}
