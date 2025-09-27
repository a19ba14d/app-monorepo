import 'package:flutter/material.dart';

class OneKeyColors {
  const OneKeyColors({required this.primary, required this.secondary, required this.background, required this.surface});

  factory OneKeyColors.light() {
    return const OneKeyColors(
      primary: Color(0xFF0066FF),
      secondary: Color(0xFF0ACF83),
      background: Color(0xFFF7F9FC),
      surface: Colors.white,
    );
  }

  factory OneKeyColors.dark() {
    return const OneKeyColors(
      primary: Color(0xFF66A3FF),
      secondary: Color(0xFF4ADE80),
      background: Color(0xFF0D0F14),
      surface: Color(0xFF161B22),
    );
  }

  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
}
