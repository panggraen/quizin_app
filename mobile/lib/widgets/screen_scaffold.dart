import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/widgets/custom_app_bar.dart';

/// Kerangka semua halaman: latar gradasi biru + judul (opsional) + isi.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    this.title,
    this.showBack = true,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
  });

  final String? title;
  final bool showBack;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [Color(0xFF1E3A8A), AppColors.darkBg]
                : const [AppColors.skyTop, Colors.white],
            stops: const [0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (title != null) CustomAppBar(title: title!, showBack: showBack),
              Expanded(child: Padding(padding: padding, child: child)),
            ],
          ),
        ),
      ),
    );
  }
}
