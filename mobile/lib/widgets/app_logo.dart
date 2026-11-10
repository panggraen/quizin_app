import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

/// Logo QUIZIN. Taruh file di assets/images/logo.png; jika belum ada tampil placeholder.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
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
