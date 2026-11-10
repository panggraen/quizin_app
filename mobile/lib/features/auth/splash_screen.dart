import 'package:flutter/material.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: saat token tersimpan (flutter_secure_storage), panggil GET /api/me lalu langsung ke main.
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, Colors.white],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(size: 110),
            SizedBox(height: 16),
            Text('QUIZIN',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.navy)),
            SizedBox(height: 4),
            Text('Belajar lewat kuis, tumbuh bersama Nimbi.',
                style: TextStyle(color: AppColors.navy)),
          ],
        ),
      ),
    );
  }
}
