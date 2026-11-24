import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/providers/profile_provider.dart';

/// Dialog konfirmasi lalu keluar akun. Dipakai di Profil dan Pengaturan.
Future<void> confirmAndLogout(BuildContext context) async {
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
