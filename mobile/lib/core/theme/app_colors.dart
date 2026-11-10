import 'package:flutter/material.dart';

/// Warna diambil dari gambar referensi. Ubah di sini saja jika token Figma final berbeda.
class AppColors {
  static const navy = Color(0xFF0B1F5B);
  static const primary = Color(0xFF1F5FD6);
  static const skyTop = Color(0xFF6F93D6);
  static const yellow = Color(0xFFFFC531);
  static const green = Color(0xFF2EBD6B);
  static const red = Color(0xFFE5231C);
  static const muted = Color(0xFF6B7490);
  static const darkBg = Color(0xFF0E1630);
  static const darkSurface = Color(0xFF1A2447);

  static bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
  static Color surface(BuildContext c) => isDark(c) ? darkSurface : Colors.white;
  static Color text(BuildContext c) => isDark(c) ? Colors.white : const Color(0xFF1B2440);
  static Color accent(BuildContext c) => isDark(c) ? Colors.white : navy;
}

class AppSizes {
  static const double radius = 14;
  static const double screenPadding = 20;
}
