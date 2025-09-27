import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

ThemeData buildOneKeyTheme({required Brightness brightness}) {
  final OneKeyColors colors = brightness == Brightness.dark ? OneKeyColors.dark() : OneKeyColors.light();
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: colors.primary,
    brightness: brightness,
    primary: colors.primary,
    secondary: colors.secondary,
    background: colors.background,
    surface: colors.surface,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.black,
      elevation: 0,
    ),
    textTheme: buildTypography(brightness),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
  );
}
