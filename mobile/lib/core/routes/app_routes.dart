import 'package:flutter/material.dart';
import 'package:quizin_app/features/auth/login_screen.dart';
import 'package:quizin_app/features/auth/register_screen.dart';
import 'package:quizin_app/features/auth/splash_screen.dart';
import 'package:quizin_app/features/home/main_shell.dart';

/// Rute tanpa argumen. Layar yang butuh data dibuka dengan Navigator.push (lihat helpers.dart).
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        main: (_) => const MainShell(),
      };
}
