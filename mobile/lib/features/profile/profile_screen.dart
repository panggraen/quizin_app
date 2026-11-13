import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/leaderboard/leaderboard_screen.dart';
import 'package:quizin_app/features/settings/settings_screen.dart';
import 'package:quizin_app/features/shop/shop_screen.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/providers/shop_provider.dart';
import 'package:quizin_app/widgets/character_avatar.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';
import 'package:quizin_app/widgets/nav_card.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/state_widgets.dart';
import 'package:quizin_app/widgets/stat_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ShopProvider>().load();
    });
  }

  Future<void> _editName(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Profil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nama lengkap'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (newName == null || !context.mounted) return;
    final error = await context.read<ProfileProvider>().updateName(newName);
    if (context.mounted) showMessage(context, error ?? 'Nama berhasil diperbarui.');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final shop = context.watch<ShopProvider>();
    final u = p.user;
    if (u == null) {
      return ScreenScaffold(
        title: 'Profil',
        showBack: false,
        child: p.error != null ? ErrorStateWidget(message: p.error!, onRetry: p.load) : const LoadingWidget(),
      );
    }
    return ScreenScaffold(
      title: 'Profil',
      showBack: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navy),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CloudMascot(size: 84, accessoryId: u.activeCharacterId),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                          Text(u.email, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () => _editName(context, u.name),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
                            child: const Text('Ubah Profil'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: StatBox(value: '${u.coins}', label: 'Koin', icon: Icons.monetization_on)),
                    const SizedBox(width: 8),
                    Expanded(child: StatBox(value: '${u.level}', label: 'Level', icon: Icons.shield)),
                    const SizedBox(width: 8),
                    Expanded(child: StatBox(value: '${u.totalXp}', label: 'XP', icon: Icons.bolt)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('Toko Aksesori',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text(context))),
              const Spacer(),
              TextButton(
                onPressed: () => pushScreen(context, const ShopScreen()),
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          SizedBox(
            height: 132,
            child: shop.characters.isEmpty
                ? const LoadingWidget()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: shop.characters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final c = shop.characters[i];
                      return Container(
                        width: 116,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          children: [
                            CharacterAvatar(characterId: c.id, size: 64),
                            const SizedBox(height: 4),
                            Text(c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: AppColors.text(context))),
                            Text(c.isOwned ? 'Dimiliki' : '${c.priceCoins} koin',
                                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Text('Menu lain',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
          const SizedBox(height: 8),
          NavCard(
            title: 'Pengaturan',
            subtitle: 'Suara, tema, dan tentang aplikasi',
            icon: Icons.settings,
            onTap: () => pushScreen(context, const SettingsScreen()),
          ),
          const SizedBox(height: 10),
          NavCard(
            title: 'Peringkat',
            subtitle: 'Lihat posisimu di leaderboard',
            icon: Icons.emoji_events,
            onTap: () => pushScreen(context, const LeaderboardScreen()),
          ),
        ],
      ),
    );
  }
}
