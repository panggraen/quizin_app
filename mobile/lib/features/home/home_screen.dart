import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/leaderboard/leaderboard_screen.dart';
import 'package:quizin_app/features/materi/subject_list_screen.dart';
import 'package:quizin_app/features/settings/settings_screen.dart';
import 'package:quizin_app/features/shop/shop_screen.dart';
import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/models/user_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/character_avatar.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/state_widgets.dart';
import 'package:quizin_app/widgets/stat_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onPlay});
  final VoidCallback onPlay;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CategoryModel>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = context.read<MaterialProvider>().categories();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final u = p.user;
    if (u == null) {
      return ScreenScaffold(
        showBack: false,
        child: p.error != null ? ErrorStateWidget(message: p.error!, onRetry: p.load) : const LoadingWidget(),
      );
    }
    return ScreenScaffold(
      showBack: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          _hero(u),
          const SizedBox(height: 14),
          PrimaryButton(label: 'MAIN SEKARANG', color: AppColors.primary, onPressed: widget.onPlay),
          const SizedBox(height: 16),
          Row(
            children: [
              _shortcut(Icons.emoji_events, 'Peringkat', () => pushScreen(context, const LeaderboardScreen())),
              const SizedBox(width: 10),
              _shortcut(Icons.storefront, 'Toko', () => pushScreen(context, const ShopScreen())),
              const SizedBox(width: 10),
              _shortcut(Icons.settings, 'Pengaturan', () => pushScreen(context, const SettingsScreen())),
            ],
          ),
          const SizedBox(height: 20),
          Text('Ringkasan belajar',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text(context))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: StatBox(value: '${u.materialsCompleted}', label: 'Materi selesai', icon: Icons.menu_book, iconColor: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: StatBox(value: '${u.modulesCompleted}', label: 'Modul selesai', icon: Icons.check_circle, iconColor: AppColors.green)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Belajar dulu yuk',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text(context))),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: AsyncView<List<CategoryModel>>(
              future: _categories,
              onRetry: () => setState(() => _categories = context.read<MaterialProvider>().categories()),
              builder: (context, cats) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cats.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _categoryTile(context, cats[i], i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(UserModel u) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF3B82F6)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hai, ${u.name}!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const Text('Siap belajar hari ini?', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.monetization_on, size: 16, color: AppColors.yellow),
                  const SizedBox(width: 4),
                  Text('${u.coins}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CharacterAvatar(characterId: u.activeCharacterId, size: 130),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.shield, size: 16, color: AppColors.yellow),
              const SizedBox(width: 4),
              Text('LEVEL ${u.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${u.xpInLevel} / 100 XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: u.xpInLevel / 100,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('${100 - u.xpInLevel} XP lagi menuju Level ${u.level + 1}',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _shortcut(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              Icon(icon, color: AppColors.navy),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _categoryTile(BuildContext context, CategoryModel c, int i) {
    final color = categoryColor(i);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => pushScreen(context, SubjectListScreen(category: c, mode: FlowMode.materi)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categoryIcon(c.name), color: color, size: 30),
            const SizedBox(height: 6),
            Text(c.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.text(context))),
            Text('${c.materialsTotal} materi', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
