import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

/// Kartu hadiah: ikon aset besar di kiri, nilai dan label di kanan.
class RewardTile extends StatelessWidget {
  const RewardTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.tint,
  });

  final Widget icon;
  final String value;
  final String label;

  /// Warna latar kartu (mode terang). null = warna permukaan biasa.
  final Color? tint;

  static const Color xpTint = Color(0xFFEAF3FF);
  static const Color coinTint = Color(0xFFFFF6E3);

  /// Ikon XP (`assets/light.png`) dan koin (`assets/koin.png`).
  static final Widget xpIcon = Image.asset(
    'assets/light.png',
    height: 44,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.bolt_rounded, size: 40, color: AppColors.yellow),
  );
  static final Widget coinIcon = Image.asset(
    'assets/koin.png',
    height: 44,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.monetization_on, size: 40, color: AppColors.yellow),
  );

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? AppColors.surface(context) : (tint ?? AppColors.surface(context)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
