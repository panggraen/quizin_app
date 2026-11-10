import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/providers/settings_provider.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu perlu masuk lagi untuk melanjutkan belajar.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Keluar Akun')),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    final profile = context.read<ProfileProvider>();
    final navigator = Navigator.of(context);
    try {
      await context.read<AuthProvider>().logout();
      profile.clear();
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (_) {
      if (context.mounted) showMessage(context, 'Gagal keluar. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    Widget tile(IconData icon, Color color, String title, String sub, Widget trailing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            CircleAvatar(
                radius: 18, backgroundColor: color.withValues(alpha: 0.18), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      );
    }

    return ScreenScaffold(
      title: 'Pengaturan',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          tile(Icons.volume_up, AppColors.green, 'Suara', 'Ding saat benar dan boop saat salah',
              Switch(value: s.soundOn, onChanged: s.setSound)),
          tile(Icons.dark_mode, AppColors.yellow, 'Tema gelap', 'Biru-putih atau biru malam',
              Switch(value: s.darkMode, onChanged: s.setDark)),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tentang Quizin',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
                const SizedBox(height: 6),
                Text(
                  'QUIZIN adalah aplikasi belajar berbasis kuis yang membuat belajar lebih seru lewat materi interaktif, tantangan, dan gamifikasi bersama Nimbi. Raih XP, kumpulkan koin, buka karakter, dan pantau progres belajarmu!',
                  style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.text(context)),
                ),
                const SizedBox(height: 8),
                const Text('Versi 1.0.0 (MVP)', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Keluar Akun', color: AppColors.red, onPressed: () => _logout(context)),
        ],
      ),
    );
  }
}
