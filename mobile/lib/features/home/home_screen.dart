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
import 'package:quizin_app/widgets/category_icon.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';
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
  /// Satu kolom di semua ukuran layar, lebar maksimal [_maxWidth].
  /// HP: kategori satu baris geser. Layar lebar (>= [_gridBreakpoint]):
  /// kategori jadi grid.
  static const double _maxWidth = 760;
  static const double _gridBreakpoint = 560;

  // Ukuran kartu kategori
  static const double _tileHeight = 128; // tinggi kartu
  static const double _tileMaxWidth = 150; // lebar maksimal kartu (web)
  static const double _tilePhoneWidth = 108; // lebar kartu (HP)
  static const double _categoryIconSize = 60; // ukuran gambar kategori

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
        child: p.error != null
            ? ErrorStateWidget(message: p.error!, onRetry: p.load)
            : const LoadingWidget(),
      );
    }

    final textScale =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.6).toDouble();

    return ScreenScaffold(
      showBack: false,
      maxWidth: _maxWidth,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= _gridBreakpoint;

          // Sapaan, tombol main, pintasan.
          final top = <Widget>[
            _hero(u),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'MAIN SEKARANG',
              color: AppColors.primary,
              onPressed: widget.onPlay,
            ),
            const SizedBox(height: 12),
            _shortcuts(),
          ];

          // Ringkasan dan kategori.
          final rest = <Widget>[
            _sectionTitle('Ringkasan belajar'),
            Row(
              children: [
                Expanded(
                  child: StatBox(
                    value: '${u.materialsCompleted}',
                    label: 'Materi selesai',
                    icon: Icons.menu_book,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatBox(
                    value: '${u.modulesCompleted}',
                    label: 'Modul selesai',
                    icon: Icons.check_circle,
                    iconColor: AppColors.green,
                  ),
                ),
              ],
            ),
            _sectionTitle('Belajar dulu yuk'),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: _tileHeight * textScale),
              child: AsyncView<List<CategoryModel>>(
                future: _categories,
                onRetry: () => setState(() {
                  _categories = context.read<MaterialProvider>().categories();
                }),
                builder: (context, cats) => wide
                    ? _categoryGrid(cats, textScale)
                    : _categoryRow(cats, textScale),
              ),
            ),
          ];

          const padding = EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            16,
            AppSizes.screenPadding,
            24,
          );

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: ListView(
                padding: padding,
                children: [...top, ...rest],
              ),
            ),
          );
        },
      ),
    );
  }

  /// HP: satu baris yang bisa digeser ke samping.
  Widget _categoryRow(List<CategoryModel> cats, double textScale) {
    return SizedBox(
      height: _tileHeight * textScale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) =>
            _categoryTile(context, cats[i], i, width: _tilePhoneWidth),
      ),
    );
  }

  /// Web: grid rata kiri, kartu otomatis menyesuaikan lebar.
  Widget _categoryGrid(List<CategoryModel> cats, double textScale) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _tileMaxWidth,
        mainAxisExtent: _tileHeight * textScale,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, i) => _categoryTile(context, cats[i], i),
    );
  }

  Widget _shortcuts() {
    return Row(
      children: [
        _shortcut(Icons.emoji_events, 'Peringkat',
            () => pushScreen(context, const LeaderboardScreen())),
        const SizedBox(width: 10),
        _shortcut(Icons.storefront, 'Toko',
            () => pushScreen(context, const ShopScreen())),
        const SizedBox(width: 10),
        _shortcut(Icons.settings, 'Pengaturan',
            () => pushScreen(context, const SettingsScreen())),
      ],
    );
  }

  Widget _sectionTitle(String text, {double top = 22}) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.text(context),
        ),
      ),
    );
  }

  ShapeBorder _cardShape() => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: const BorderSide(color: Colors.black12),
      );

  Widget _hero(UserModel u) {
    final xp = u.xpInLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final avatar = (c.maxWidth * 0.3).clamp(84.0, 128.0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hai, ${u.name}!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Siap belajar hari ini?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on,
                                size: 18, color: AppColors.yellow),
                            const SizedBox(width: 6),
                            Text(
                              '${u.coins} koin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CloudMascot(
                    size: avatar,
                    accessoryId: u.activeCharacterId,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'LEVEL ${u.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$xp / 100 XP',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (xp / 100).clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: AppColors.yellow,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${100 - xp} XP lagi menuju Level ${u.level + 1}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _shortcut(IconData icon, String label, VoidCallback onTap) {
    final radius = BorderRadius.circular(AppSizes.radius);

    return Expanded(
      child: Material(
        color: AppColors.surface(context),
        shape: _cardShape(),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// [width] null = tile mengisi sel grid; diisi = lebar tetap (baris HP).
  Widget _categoryTile(BuildContext context, CategoryModel c, int i,
      {double? width}) {
    final radius = BorderRadius.circular(AppSizes.radius);

    return Material(
      color: AppColors.surface(context),
      shape: _cardShape(),
      child: InkWell(
        borderRadius: radius,
        onTap: () => pushScreen(
          context,
          SubjectListScreen(category: c, mode: FlowMode.materi),
        ),
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CategoryIcon(name: c.name, size: _categoryIconSize),
                const SizedBox(height: 4),
                Text(
                  c.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.text(context),
                  ),
                ),
                Text(
                  '${c.materialsTotal} materi',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}