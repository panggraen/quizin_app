import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: b),
      scaffoldBackgroundColor: dark ? AppColors.darkBg : Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.darkSurface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dark ? Colors.white54 : AppColors.navy),
        ),
      ),
    );
  }
}
