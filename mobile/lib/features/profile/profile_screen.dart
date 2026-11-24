import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/features/leaderboard/leaderboard_screen.dart';
import 'package:quizin_app/features/settings/settings_screen.dart';
import 'package:quizin_app/features/shop/shop_screen.dart';
import 'package:quizin_app/models/progress_model.dart';
import 'package:quizin_app/models/user_model.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/providers/shop_provider.dart';
import 'package:quizin_app/providers/streak_provider.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';
import 'package:quizin_app/widgets/page_header.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/shop_preview_card.dart';
import 'package:quizin_app/widgets/state_widgets.dart';
import 'package:quizin_app/widgets/stat_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProgressModel> _progress;

  @override
  void initState() {
    super.initState();
    _progress = context.read<ProfileProvider>().progress();
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

  Future<void> _logout(BuildContext context) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu perlu masuk lagi untuk melanjutkan belajar.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Keluar Akun')),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    final profile = context.read<ProfileProvider>();
    final streak = context.read<StreakProvider>();
    final navigator = Navigator.of(context);
    try {
      await context.read<AuthProvider>().logout();
      profile.clear();
      streak.clear();
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (_) {
      if (context.mounted) showMessage(context, 'Gagal keluar. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final p = context.watch<ProfileProvider>();
    final u = p.user;

    Widget body;
    if (u == null) {
      body = p.error != null
          ? ErrorStateWidget(message: p.error!, onRetry: p.load)
          : const LoadingWidget();
    } else {
      body = _content(context, u);
    }

    return ScreenScaffold(
      padding: EdgeInsets.zero,
      child: Container(
        color: dark ? AppColors.darkBg : const Color(0xFFF8FAFF),
        child: Column(
          children: [
            PageHeader(title: 'Profil', showBack: !context.isDesktop),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _badgeSection(BuildContext context, List<BadgeModel> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badge',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - 16) / 3;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in badges)
                  SizedBox(
                    width: w,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          Icon(b.isEarned ? Icons.verified : Icons.lock_outline,
                              size: 20, color: b.isEarned ? AppColors.green : Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text(context))),
                                Text('(${b.requiredModules} modul)',
                                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _content(BuildContext context, UserModel u) {
    const headerHeight = 110.0;
    const avatarSize = 112.0;
    const avatarTop = 20.0;
    const cardTop = 66.0;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const SizedBox(
              height: headerHeight,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.headerTop, AppColors.primary],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: cardTop),
              padding: EdgeInsets.fromLTRB(20, avatarTop + avatarSize - cardTop + 10, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(u.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent(context))),
                      ),
                      IconButton(
                        tooltip: 'Ubah Profil',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _editName(context, u.name),
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.muted),
                      ),
                    ],
                  ),
                  Text(u.email, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBEAB8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Level ${u.level}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('${u.xpInLevel} / 100 XP',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      const Spacer(),
                      Text('Level ${u.level + 1}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (u.xpInLevel / 100).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: const Color(0xFFD3DFF5),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<ProgressModel>(
                    future: _progress,
                    builder: (context, snap) {
                      final badgeCount = snap.hasData
                          ? snap.data!.badges.where((b) => b.isEarned).length
                          : null;
                      return Row(
                        children: [
                          Expanded(
                              child: StatBox(
                                  value: '${u.coins}', label: 'Koin', icon: Icons.monetization_on)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: StatBox(
                                  value: '${u.level}',
                                  label: 'Level',
                                  icon: Icons.shield,
                                  iconColor: AppColors.primary)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: StatBox(
                                  value: badgeCount?.toString() ?? '-',
                                  label: 'Badge',
                                  icon: Icons.military_tech,
                                  iconColor: const Color(0xFFF08A3C))),
                        ],
                      );
                    },
                  ),
                  FutureBuilder<ProgressModel>(
                    future: _progress,
                    builder: (context, snap) {
                      final badges = snap.data?.badges ?? const <BadgeModel>[];
                      if (badges.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _badgeSection(context, badges),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ShopPreviewCard(
                    onSeeAll: () => pushScreen(context, const ShopScreen()),
                  ),
                  const SizedBox(height: 16),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.emoji_events_outlined,
                        title: 'Peringkat',
                        subtitle: 'Lihat posisi di leaderboard',
                        onTap: () => pushScreen(context, const LeaderboardScreen()),
                      ),
                      _MenuItem(
                        icon: Icons.settings,
                        title: 'Pengaturan',
                        subtitle: 'Kelola akun dan aplikasi',
                        onTap: () => pushScreen(context, const SettingsScreen()),
                      ),
                      _MenuItem(
                        icon: Icons.logout,
                        title: 'Keluar',
                        danger: true,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: avatarTop,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Color(0x290B1F5B), blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: CloudMascot(
                    size: avatarSize - 8,
                    borderRadius: 26,
                    characterId: u.activeCharacterId,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.danger = false,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool danger;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6E2F7)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE3EBF8)),
            _row(context, items[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, _MenuItem it) {
    final color = it.danger ? AppColors.red : AppColors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: it.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: it.danger ? const Color(0xFFFFE3E1) : const Color(0xFFE3EEFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(it.icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: it.danger ? AppColors.red : AppColors.accent(context))),
                  if (it.subtitle != null)
                    Text(it.subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            if (!it.danger) Icon(Icons.chevron_right, color: AppColors.accent(context)),
          ],
        ),
      ),
    );
  }
}
