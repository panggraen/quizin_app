import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.name, this.size = 40});

  static const Map<String, String> _assets = {
    'matematika': 'assets/math.png',
    'mathematics': 'assets/math.png',
    'ipa': 'assets/science.png',
    'science': 'assets/science.png',
    'teknologi': 'assets/tech.png',
    'technology': 'assets/tech.png',
    'sejarah': 'assets/history.png',
    'history': 'assets/history.png',
  };

  final String name;
  final double size;

  static String? assetFor(String name) => _assets[name.trim().toLowerCase()];

  Widget _fallback() => SizedBox(
        width: size,
        height: size,
        child: Icon(categoryIcon(name), size: size * 0.7, color: AppColors.primary),
      );

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(name);
    if (asset == null) return _fallback();

    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }
}
