import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.accent(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: AppColors.surface(context),
          side: BorderSide(color: onPressed == null ? Colors.grey : color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }
}
