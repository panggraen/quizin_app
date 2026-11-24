import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/widgets/page_header.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

/// Kerangka halaman tab (Progress, Profil): header putih yang sama dengan
/// tab Materi dan Kuis, lalu isi halaman.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return ScreenScaffold(
      padding: EdgeInsets.zero,
      child: Container(
        color: dark ? AppColors.darkBg : const Color(0xFFF8FAFF),
        child: Column(
          children: [
            PageHeader(title: title, showBack: !context.isDesktop),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}