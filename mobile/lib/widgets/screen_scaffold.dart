import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/navigation/shell_nav.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/widgets/page_header.dart';
import 'package:quizin_app/widgets/top_nav_bar.dart';

/// Kerangka semua halaman: judul (opsional) + isi.
///
/// * Bila [title] diisi, header yang dipakai selalu [PageHeader] (putih, judul di
///   tengah) dan latar mengikuti halaman Materi/Kuis. Tanpa [title] (Home,
///   layar perayaan), latar gradasi biru tetap dipakai.
///
/// * Isi dipusatkan dan dibatasi [maxWidth], jadi tidak meregang di web.
/// * Di layar lebar, halaman yang dibuka lewat Navigator.push (Toko, Peringkat,
///   materi, dst.) tetap menampilkan navigasi atas. Set [showTopNav] = false
///   untuk mode fokus seperti kuis yang sedang berjalan.
/// * Di dalam MainShell, navigasi atas digambar oleh shell, bukan di sini.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    this.title,
    this.showBack = true,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
    this.maxWidth = Breakpoints.readingMax,
    this.showTopNav = true,
  });

  final String? title;
  final bool showBack;
  final Widget child;
  final EdgeInsets padding;

  /// Lebar maksimal konten. Halaman daftar/bacaan memakai
  /// [Breakpoints.readingMax]; beranda memakai [Breakpoints.contentMax].
  final double maxWidth;

  /// Tampilkan navigasi atas di layar lebar bila halaman ini bukan bagian
  /// dari MainShell.
  final bool showTopNav;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final standaloneNav =
        showTopNav && context.isDesktop && !ShellScope.isInside(context);

    return Scaffold(
      body: Column(
        children: [
          if (standaloneNav) const _StandaloneTopNav(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: title != null
                  ? BoxDecoration(
                      color: dark ? AppColors.darkBg : null,
                      gradient: dark
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [AppColors.pageTop, Color(0xFFF8FAFF)],
                            ),
                    )
                  : BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: dark
                            ? const [Color(0xFF1E3A8A), AppColors.darkBg]
                            : const [AppColors.skyTop, Colors.white],
                        stops: const [0, 0.55],
                      ),
                    ),
              child: Column(
                children: [
                  if (title != null) PageHeader(title: title!, showBack: showBack),
                  Expanded(
                    child: SafeArea(
                      top: title == null && !standaloneNav,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: EdgeInsets.only(top: title != null ? 16 : 0),
                            child: Padding(padding: padding, child: child),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigasi atas untuk halaman yang dibuka di atas MainShell: memilih tab
/// lalu kembali ke shell.
class _StandaloneTopNav extends StatelessWidget {
  const _StandaloneTopNav();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<ShellNav>();
    return AppTopNav(
      index: nav.index,
      onSelect: (i) {
        context.read<ShellNav>().select(i);
        Navigator.of(context).popUntil(
          (route) => route.isFirst || route.settings.name == AppRoutes.main,
        );
      },
    );
  }
}
