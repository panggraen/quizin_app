import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';


class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  static const String asset = 'assets/logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Logo Quizin',
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
