import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color navy = Color(0xFF1B2E5C);
  static const Color navyLight = Color(0xFF2A4178);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFDBEAFE);
  static const Color bg = Color(0xFFF0F4F8);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: navy,
        secondary: blue,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: navy),
        titleTextStyle: TextStyle(
          color: navy,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
