import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

/// Kotak angka kecil. Dipakai sebagai ProgressCard dan RewardCard (XP, koin, level).
class StatBox extends StatelessWidget {
  const StatBox({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor = AppColors.yellow,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: iconColor, size: 22),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}
