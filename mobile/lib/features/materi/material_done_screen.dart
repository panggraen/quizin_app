import 'package:flutter/material.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/secondary_button.dart';
import 'package:quizin_app/widgets/stat_box.dart';

class MaterialDoneScreen extends StatelessWidget {
  const MaterialDoneScreen({super.key, required this.xpAwarded});

  final int xpAwarded;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.emoji_events, size: 120, color: AppColors.yellow),
          const SizedBox(height: 8),
          Text('Materi Selesai!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            child: StatBox(value: '+$xpAwarded', label: 'Poin XP', icon: Icons.bolt),
          ),
          if (xpAwarded == 0)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('XP materi hanya diberikan sekali.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
          const Spacer(),
          PrimaryButton(label: 'Lihat Materi Lain', onPressed: () => Navigator.of(context).pop()),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Kembali ke Beranda',
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
