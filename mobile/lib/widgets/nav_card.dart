import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

/// Kartu baris dengan panah. Dipakai sebagai CategoryCard, SubjectCard, MaterialCard, dan menu.
class NavCard extends StatelessWidget {
  const NavCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent = AppColors.navy,
    this.filled = false,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accent;
  final bool filled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.text(context);
    return Material(
      color: filled ? AppColors.navy : AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: BorderSide(color: accent, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withValues(alpha: 0.18),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: fg)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: TextStyle(
                              fontSize: 12, color: filled ? Colors.white70 : AppColors.muted)),
                  ],
                ),
              ),
              trailing ?? Icon(Icons.arrow_circle_right_outlined, color: filled ? Colors.white : accent),
            ],
          ),
        ),
      ),
    );
  }
}
