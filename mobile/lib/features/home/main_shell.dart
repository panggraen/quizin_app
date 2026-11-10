import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/features/home/home_screen.dart';
import 'package:quizin_app/features/materi/category_list_screen.dart';
import 'package:quizin_app/features/profile/profile_screen.dart';
import 'package:quizin_app/features/progress/progress_screen.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/bottom_nav_bar.dart';

/// Halaman utama dengan 5 tab. Tab dibangun ulang saat dipilih agar datanya segar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileProvider>().load();
    });
  }

  void _select(int i) {
    setState(() => _index = i);
    context.read<ProfileProvider>().load();
  }

  Widget _page() {
    switch (_index) {
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
    return Scaffold(
      body: _page(),
      bottomNavigationBar: AppBottomNav(index: _index, onSelect: _select),
    );
  }
}
