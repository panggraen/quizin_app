import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/core/navigation/shell_nav.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/leaderboard/leaderboard_screen.dart';
import 'package:quizin_app/features/materi/subject_list_screen.dart';
import 'package:quizin_app/features/settings/settings_screen.dart';
import 'package:quizin_app/features/shop/shop_screen.dart';
import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/models/progress_model.dart';
import 'package:quizin_app/models/user_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/app_logo.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/category_icon.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/state_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onPlay});
  final VoidCallback onPlay;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _maxWidth = 760;

  static const double _tileHeight = 112;
  static const double _tileMaxWidth = 150;
  static const double _tileMinWidth = 76;
  static const double _categoryIconSize = 52;

  static const Color _pageTop = AppColors.pageTop;
  static const Color _headerTop = AppColors.headerTop;
  static const Color _softBlue = Color(0xFFDCE8FF);
  static const Color _softPurple = Color(0xFFEADFFF);
  static const Color _softCream = Color(0xFFFFF0CF);
  static const Color _softMint = Color(0xFFDDF7EE);
  static const Color _softPeach = Color(0xFFFFEBD6);

  static const List<Color> _tileColors = [
    _softMint,
    _softPeach,
    _softBlue,
    _softPurple,
  ];

  static const List<String> _dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  late Future<List<CategoryModel>> _categories;
  late Future<ProgressModel> _progress;

  @override
  void initState() {
    super.initState();
    _categories = context.read<MaterialProvider>().categories();
    _progress = context.read<ProfileProvider>().progress();
  }

  bool get _dark => AppColors.isDark(context);

  Color _tint(Color c) => _dark ? c.withValues(alpha: 0.2) : c;

  void _goTab(int i) {
    context.read<ShellNav>().select(i);
    context.read<ProfileProvider>().load();
  }

  Widget _img(String asset, double size, IconData fallback, Color color) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: size, height: size, child: Icon(fallback, size: size * 0.7, color: color)),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _dark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x141F5FD6),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.accent(context),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onSeeAll,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _dark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_pageTop, Colors.white],
              ),
        color: _dark ? AppColors.darkBg : null,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _header(u),
              FutureBuilder<ProgressModel>(
                future: _progress,
                builder: (context, snap) {
                  final items = snap.data?.items ?? const <ProgressItemModel>[];
                  final loading =
                      snap.connectionState != ConnectionState.done;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _streakCard(items),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _playBanner(),
                        ),
                        const SizedBox(height: 14),
                        _shortcuts(),
                        const SizedBox(height: 16),
                        _materiCard(textScale),
                        const SizedBox(height: 14),
                        _recentCard(items, loading),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.10),
        ),
      );

  Widget _header(UserModel u) {
    final topInset = MediaQuery.paddingOf(context).top;
    final xp = u.xpInLevel;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerTop, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: -60, bottom: 40, child: _blob(130)),
          Positioned(right: -50, top: 30, child: _blob(150)),
          Positioned(right: 70, bottom: -50, child: _blob(110)),
          LayoutBuilder(
            builder: (context, c) {
              final avatar = (c.maxWidth * 0.3).clamp(84.0, 128.0).toDouble();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(u),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE9A8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Level ${u.level}',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Hai, ${u.name}!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Siap main kuis hari ini?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CloudMascot(
                        size: avatar * 0.8,
                        characterId: u.activeCharacterId,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _xpPanel(u, xp),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _topBar(UserModel u) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const AppLogo(size: 26),
        ),
        const SizedBox(width: 8),
        const Text(
          'Quizin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D6),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _img('assets/coin.png', 24, Icons.monetization_on,
                  AppColors.yellow),
              const SizedBox(width: 6),
              Text(
                '${u.coins}',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _xpPanel(UserModel u, int xp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4FBF).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$xp / 100 XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (xp / 100).clamp(0.0, 1.0).toDouble(),
                    minHeight: 12,
                    backgroundColor: const Color(0x55BFE6FF),
                    color: const Color(0xFFBFE6FF),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Level ${u.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${100 - xp} XP lagi menuju Level ${u.level + 1}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Set<int> _activeWeekdays(List<ProgressItemModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));

    final days = <int>{};
    for (final it in items) {
      final t = it.createdAt;
      if (t == null) continue;
      final d = DateTime(t.year, t.month, t.day);
      if (!d.isBefore(monday) && d.isBefore(nextMonday)) days.add(d.weekday);
    }
    return days;
  }

  Widget _streakCard(List<ProgressItemModel> items) {
    final active = _activeWeekdays(items);
    final todayWeekday = DateTime.now().weekday;

    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _img('assets/fire.png', 44, Icons.local_fire_department_rounded,
              Colors.deepOrange),
          const SizedBox(width: 8),
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Streak',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.accent(context),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Belajar 7 hari berturut-turut!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 44, color: Colors.black12),
          const SizedBox(width: 8),
          Expanded(
            flex: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  _dayDot(
                    _dayLabels[i],
                    checked: active.contains(i + 1),
                    isToday: todayWeekday == i + 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayDot(String label, {required bool checked, required bool isToday}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
            color: isToday ? AppColors.primary : AppColors.accent(context),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: checked
                ? AppColors.primary
                : (_dark ? Colors.white10 : const Color(0xFFF1F6FF)),
            border: Border.all(
              color: checked
                  ? AppColors.primary
                  : (isToday ? AppColors.primary : const Color(0xFFD5E2F7)),
              width: isToday && !checked ? 2 : 1.5,
            ),
          ),
          child: checked
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
      ],
    );
  }

  Widget _playBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: widget.onPlay,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A66E8), Color(0xFF1B4FC4)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(right: -30, bottom: -50, child: _blob(150)),
              Positioned(
                right: 14,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _img('assets/target.png', 104,
                      Icons.fact_check_rounded, Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 130, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mainkan Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Uji pengetahuanmu\ndengan kuis seru!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Mulai Bermain',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shortcuts() {
    return Row(
      children: [
        _shortcut('assets/trophy.png', Icons.emoji_events, 'Peringkat',
            _softBlue, () => pushScreen(context, const LeaderboardScreen())),
        const SizedBox(width: 10),
        _shortcut('assets/store.png', Icons.storefront, 'Toko', _softPurple,
            () => pushScreen(context, const ShopScreen())),
        const SizedBox(width: 10),
        _shortcut('assets/setting.png', Icons.settings, 'Pengaturan',
            _softCream, () => pushScreen(context, const SettingsScreen())),
      ],
    );
  }

  Widget _shortcut(String asset, IconData fallback, String label, Color tint,
      VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 104,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 28,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _tint(tint),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.accent(context),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: _img(asset, 62, fallback, AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _materiCard(double textScale) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Materi Belajar', () => _goTab(1)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: _tileHeight * textScale),
            child: AsyncView<List<CategoryModel>>(
              future: _categories,
              onRetry: () => setState(() {
                _categories = context.read<MaterialProvider>().categories();
              }),
              builder: (context, cats) => _categoryRow(cats, textScale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(List<CategoryModel> cats, double textScale) {
    const gap = 8.0;

    return LayoutBuilder(
      builder: (context, c) {
        final n = cats.isEmpty ? 1 : cats.length;
        final fit = (c.maxWidth - gap * (n - 1)) / n;
        final tileW = fit.clamp(_tileMinWidth, _tileMaxWidth).toDouble();

        return SizedBox(
          height: _tileHeight * textScale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: gap),
            itemBuilder: (context, i) =>
                _categoryTile(context, cats[i], i, width: tileW),
          ),
        );
      },
    );
  }

  Widget _categoryTile(BuildContext context, CategoryModel c, int i,
      {required double width}) {
    final radius = BorderRadius.circular(18);

    return SizedBox(
      width: width,
      child: Material(
        color: _tint(_tileColors[i % _tileColors.length]),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => pushScreen(
            context,
            SubjectListScreen(category: c, mode: FlowMode.materi),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CategoryIcon(name: c.name, size: _categoryIconSize),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.accent(context),
                  ),
                ),
                Text(
                  '${c.materialsTotal} materi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentCard(List<ProgressItemModel> items, bool loading) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Aktivitas Terakhir', () => _goTab(3)),
          const SizedBox(height: 10),
          if (loading && items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Belum ada aktivitas. Yuk selesaikan materi atau kuis pertamamu!',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          else
            _activityTile(items.first),
        ],
      ),
    );
  }

  ({String title, String subtitle, String category}) _describe(
      ProgressItemModel it) {
    final parts = it.subtitle.split(' · ');
    final path = parts.first.split('-');
    final category = path.first.trim();

    String title;
    if (it.type == 'quiz') {
      final subject = path.length > 1 ? path[1].trim() : it.title;
      final modul = parts.length > 1 ? ' · ${parts[1]}' : '';
      title = 'Kuis $subject$modul';
    } else {
      title = path.length > 2 ? path.sublist(2).join('-').trim() : it.title;
    }

    final t = it.createdAt;
    final date = t == null ? '' : ' • ${_formatDate(t)}';
    final label = category.isEmpty ? it.title : category;

    return (title: title, subtitle: '$label$date', category: category);
  }

  String _formatDate(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.day} ${_months[t.month - 1]} ${t.year}, $hh.$mm';
  }

  Widget _activityTile(ProgressItemModel it) {
    final d = _describe(it);
    final radius = BorderRadius.circular(18);

    return Material(
      color: _dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF4F8FF),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _goTab(3),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CategoryIcon(name: d.category, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}