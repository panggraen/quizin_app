import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

/// Kartu hadiah: ikon di kotak biru muda, nilai besar, lalu label.
class RewardTile extends StatelessWidget {
  const RewardTile({super.key, required this.icon, required this.value, required this.label});

  final Widget icon;
  final String value;
  final String label;

  /// Ikon XP (petir) dan koin, dipakai bersama oleh halaman hasil.
  static const Widget xpIcon = Icon(Icons.bolt_rounded, size: 30, color: AppColors.yellow);
  static final Widget coinIcon = Image.asset(
    'assets/coin.png',
    width: 28,
    height: 28,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.monetization_on, size: 28, color: AppColors.yellow),
  );

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF223463) : const Color(0xFFE3EEFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
