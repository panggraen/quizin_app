import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/pembahasan/review_screen.dart';
import 'package:quizin_app/providers/quiz_provider.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/secondary_button.dart';
import 'package:quizin_app/widgets/reward_tile.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.read<QuizProvider>().result;
    if (r == null) {
      return const ScreenScaffold(title: 'Hasil Kuis', child: Center(child: Text('Hasil tidak tersedia.')));
    }
    final dark = AppColors.isDark(context);
    return ScreenScaffold(
      title: 'Hasil Kuis',
      showBack: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Image.asset('assets/completed.png', height: 190, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF223463) : const Color(0xFFE6EFFD),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                const Text('Skor Kamu',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.muted)),
                Text('${r.correctCount} / ${r.totalQuestions}',
                    style: TextStyle(
                        fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF2F4A8A) : const Color(0xFFD3E3FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('${r.scorePercent}% jawaban benar',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: dark ? Colors.white : AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: RewardTile(
                      icon: RewardTile.xpIcon, value: '+${r.xpAwarded}', label: 'Poin XP')),
              const SizedBox(width: 12),
              Expanded(
                  child: RewardTile(
                      icon: RewardTile.coinIcon, value: '+${r.coinsAwarded}', label: 'Koin')),
            ],
          ),
          if (!r.rewardGiven)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Modul ini sudah pernah diselesaikan, jadi hadiah tidak bertambah. Nilai terbaik tetap diperbarui jika lebih tinggi.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Lihat Pembahasan',
            onPressed: () => pushScreen(context, ReviewScreen(attemptId: r.attemptId)),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Kembali ke Beranda',
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false),
          ),
        ],
      ),
    );
  }
}
