import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/leaderboard_model.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/character_avatar.dart';
import 'package:quizin_app/widgets/leaderboard_card.dart';
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
    return ScreenScaffold(
      title: 'Peringkat',
      child: AsyncView<List<LeaderboardEntryModel>>(
        future: _future,
        onRetry: () => setState(_load),
        isEmpty: (d) => d.isEmpty,
        emptyMessage: 'Belum ada peringkat.',
        builder: (context, entries) {
          final me = entries.firstWhere((e) => e.isMe, orElse: () => entries.first);
          final top = entries.take(3).toList();
          final rest = entries.skip(3).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Posisimu: peringkat ${me.rank} dengan ${me.totalXp} XP',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.text(context))),
              ),
              const SizedBox(height: 14),
              _Podium(top: top),
              const SizedBox(height: 14),
              for (final e in rest) LeaderboardCard(entry: e),
              // Jika pengguna ada di podium, barisnya tetap ditampilkan di bawah agar mudah ditemukan.
              if (me.rank <= 3) LeaderboardCard(entry: me),
            ],
          );
        },
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
        for (final i in order)
          Expanded(
            child: Column(
              children: [
                CharacterAvatar(characterId: top[i].characterId, size: i == 0 ? 56 : 44),
                Text(top[i].isMe ? '${top[i].name} (Kamu)' : top[i].name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
                Text('${top[i].totalXp} XP',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 4),
                Container(
                  height: i == 0 ? 90 : (i == 1 ? 66 : 50),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.yellow
                        : (i == 1 ? AppColors.primary : const Color(0xFFF08A3C)),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
