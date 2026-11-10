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
import 'package:quizin_app/widgets/stat_box.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.read<QuizProvider>().result;
    if (r == null) {
      return const ScreenScaffold(title: 'Hasil Kuis', child: Center(child: Text('Hasil tidak tersedia.')));
    }
    return ScreenScaffold(
      child: ListView(
        padding: const EdgeInsets.only(top: 24, bottom: 24),
        children: [
          const Icon(Icons.emoji_events, size: 120, color: AppColors.yellow),
          const SizedBox(height: 8),
          Center(
            child: Text('Kuis Selesai!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text('Skor Kamu', style: TextStyle(color: AppColors.text(context))),
                Text('${r.correctCount} / ${r.totalQuestions}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.text(context))),
                Text('${r.scorePercent}% jawaban benar',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: StatBox(value: '+${r.xpAwarded}', label: 'Poin XP', icon: Icons.bolt)),
              const SizedBox(width: 12),
              Expanded(child: StatBox(value: '+${r.coinsAwarded}', label: 'Koin', icon: Icons.monetization_on)),
            ],
          ),
          if (!r.rewardGiven)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Modul ini sudah pernah diselesaikan, jadi hadiah tidak bertambah. Nilai terbaik tetap diperbarui jika lebih tinggi.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
          const SizedBox(height: 24),
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
