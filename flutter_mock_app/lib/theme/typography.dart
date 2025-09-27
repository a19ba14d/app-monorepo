import 'package:flutter/material.dart';

TextTheme buildTypography(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  return TextTheme(
    displaySmall: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : Colors.black,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : Colors.black,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white70 : Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: isDark ? Colors.white70 : Colors.black87,
    ),
  );
}
