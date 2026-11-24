import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/leaderboard_model.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/character_avatar.dart';
import 'package:quizin_app/widgets/leaderboard_card.dart';
import 'package:quizin_app/widgets/page_header.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntryModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<ProfileProvider>().leaderboard();

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return ScreenScaffold(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [Color(0xFF1E3A8A), AppColors.darkBg]
                : const [Color(0xFFD9E8FF), Color(0xFFF8FBFF)],
          ),
        ),
        child: Column(
          children: [
            const PageHeader(title: 'Peringkat'),
            Expanded(
              child: AsyncView<List<LeaderboardEntryModel>>(
                future: _future,
                onRetry: () => setState(_load),
                isEmpty: (d) => d.isEmpty,
                emptyMessage: 'Belum ada peringkat.',
                builder: (context, entries) {
                  final me = entries.firstWhere((e) => e.isMe, orElse: () => entries.first);
                  final top = entries.take(3).toList();
                  final rest = entries.skip(3).toList();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _Podium(top: top),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface(context),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x140B1F5B), blurRadius: 12, offset: Offset(0, -3)),
                            ],
                          ),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                            children: [
                              for (final e in rest) LeaderboardCard(entry: e),
                              // Jika pengguna ada di podium, barisnya tetap ditampilkan di bawah agar mudah ditemukan.
                              if (me.rank <= 3) LeaderboardCard(entry: me),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top});
  final List<LeaderboardEntryModel> top;

  @override
  Widget build(BuildContext context) {
    // Urutan tampil: peringkat 2, 1, 3.
    final order = [1, 0, 2].where((i) => i < top.length).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final i in order) Expanded(child: _PodiumColumn(entry: top[i], index: i)),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({required this.entry, required this.index});
  final LeaderboardEntryModel entry;
  final int index; // 0 = juara 1

  @override
  Widget build(BuildContext context) {
    final first = index == 0;
    final dia = first ? 84.0 : 68.0;
    final blockHeight = first ? 104.0 : (index == 1 ? 84.0 : 68.0);
    final blockColors = first
        ? const [Color(0xFFFFD04D), Color(0xFFFFB400)]
        : (index == 1
            ? const [Color(0xFF4A8BFF), Color(0xFF1F5FD6)]
            : const [Color(0xFFFFA24D), Color(0xFFF07A1E)]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first)
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Icon(Icons.workspace_premium, size: 30, color: AppColors.yellow),
          ),
        Container(
          width: dia,
          height: dia,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEAF3FF),
            border: Border.all(color: first ? const Color(0xFFFFD04D) : Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Color(0x330B1F5B), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: CharacterAvatar(characterId: entry.characterId, size: dia * 0.55),
        ),
        const SizedBox(height: 6),
        Text(entry.isMe ? '${entry.name} (Kamu)' : entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E2F7)),
          ),
          child: Text('${formatXp(entry.totalXp)} XP',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text(context))),
        ),
        const SizedBox(height: 8),
        Container(
          height: blockHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: blockColors),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Text('${index + 1}',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ],
    );
  }
}
