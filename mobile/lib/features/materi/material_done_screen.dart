import 'package:flutter/material.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/reward_tile.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/secondary_button.dart';

class MaterialDoneScreen extends StatelessWidget {
  const MaterialDoneScreen({
    super.key,
    required this.xpAwarded,
  });

  final int xpAwarded;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Materi Selesai',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Jarak gambar dari header
          const SizedBox(height: 60),

          // Ilustrasi materi selesai
          Image.asset(
            'assets/book.png',
            height: 260,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 16),

          // Card reward XP
          Center(
            child: SizedBox(
              width: 220,
              child: RewardTile(
                icon: RewardTile.xpIcon,
                tint: RewardTile.xpTint,
                value: '+$xpAwarded',
                label: 'Poin XP',
              ),
            ),
          ),

          if (xpAwarded == 0)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'XP materi hanya diberikan sekali.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Tombol lihat materi lain
          PrimaryButton(
            color: AppColors.primary,
            label: 'Lihat Materi Lain',
            onPressed: () => Navigator.of(context).pop(),
          ),

          const SizedBox(height: 10),

          // Tombol kembali ke beranda
          SecondaryButton(
            label: 'Kembali ke Beranda',
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(
              AppRoutes.main,
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}