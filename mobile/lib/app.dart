import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_theme.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/providers/quiz_provider.dart';
import 'package:quizin_app/providers/settings_provider.dart';
import 'package:quizin_app/providers/shop_provider.dart';
import 'package:quizin_app/services/mock/mock_backend.dart';

class QuizinApp extends StatelessWidget {
  const QuizinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // GANTI DI SINI saat backend Laravel siap: ganti MockBackend dengan
        // ApiAuthService, ApiContentService, dst. (satu per satu, layar tidak berubah).
        Provider<MockBackend>(create: (_) => MockBackend()),
        ChangeNotifierProvider(create: (c) => AuthProvider(c.read<MockBackend>())),
        ChangeNotifierProvider(create: (c) => ProfileProvider(c.read<MockBackend>())),
        ChangeNotifierProvider(create: (c) => MaterialProvider(c.read<MockBackend>())),
        ChangeNotifierProvider(create: (c) => QuizProvider(c.read<MockBackend>())),
        ChangeNotifierProvider(create: (c) => ShopProvider(c.read<MockBackend>())),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'QUIZIN',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}
