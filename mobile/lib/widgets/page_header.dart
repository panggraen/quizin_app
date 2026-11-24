import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

/// Header putih seragam untuk SEMUA halaman: tombol kembali di kiri, judul di
/// tengah, garis tipis di bawah.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.showBack = true});

  final String title;
  final bool showBack;

  static const Color _line = Color(0xFFB8C8EE);

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 10),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkBg : Colors.white,
        border: const Border(bottom: BorderSide(color: _line, width: 1.5)),
      ),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showBack) Align(alignment: Alignment.centerLeft, child: _backButton(context, dark)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
              child: _titleText(dark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context, bool dark) => Material(
        color: dark ? AppColors.darkSurface : Colors.white,
        elevation: 2,
        shadowColor: const Color(0x331F5FD6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(Icons.chevron_left_rounded,
                size: 28, color: dark ? Colors.white : AppColors.navy),
          ),
        ),
      );

  Widget _titleText(bool dark) => Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: dark ? Colors.white : AppColors.navy,
        ),
      );
}