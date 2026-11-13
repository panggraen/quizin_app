import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/core/navigation/shell_nav.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/features/home/home_screen.dart';
import 'package:quizin_app/features/materi/category_list_screen.dart';
import 'package:quizin_app/features/profile/profile_screen.dart';
import 'package:quizin_app/features/progress/progress_screen.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/bottom_nav_bar.dart';
import 'package:quizin_app/widgets/top_nav_bar.dart';

/// Kerangka utama setelah login.
///
/// Layar lebar (web / desktop): navigasi horizontal di ATAS, konten di bawahnya
/// dengan lebar maksimal. HP: navigasi bawah.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    context.read<ShellNav>().resetSilently();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileProvider>().load();
    });
  }

  void _select(int i) {
    context.read<ShellNav>().select(i);
    context.read<ProfileProvider>().load();
  }

  Widget _page(int index) {
    switch (index) {
      case 1:
        return const CategoryListScreen(mode: FlowMode.materi, isTab: true);
      case 2:
        return const CategoryListScreen(mode: FlowMode.kuis, isTab: true);
      case 3:
        return const ProgressScreen();
      case 4:
        return const ProfileScreen();
      default:
        return HomeScreen(onPlay: () => _select(2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = context.watch<ShellNav>().index;
    final wide = context.isDesktop;

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: ShellScope(
        child: Scaffold(
          body: wide
              ? Column(
                  children: [
                    AppTopNav(index: index, onSelect: _select),
                    Expanded(child: _page(index)),
                  ],
                )
              : _page(index),
          bottomNavigationBar:
              wide ? null : AppBottomNav(index: index, onSelect: _select),
        ),
      ),
    );
  }
}
