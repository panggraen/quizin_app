import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/leaderboard_model.dart';
import 'package:quizin_app/widgets/character_avatar.dart';

/// 4970 -> "4.970" (pemisah ribuan gaya Indonesia).
String formatXp(int n) {
  final d = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i > 0 && (d.length - i) % 3 == 0) b.write('.');
    b.write(d[i]);
  }
  return n < 0 ? '-$b' : b.toString();
}

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key, required this.entry});
  final LeaderboardEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final dark = AppColors.isDark(context);
    final mainColor = e.isMe && !dark ? AppColors.navy : AppColors.text(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: e.isMe
            ? (dark ? const Color(0xFF243B7A) : const Color(0xFFE8F1FF))
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: e.isMe ? AppColors.primary : const Color(0xFFD6E2F7),
          width: e.isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${e.rank}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: mainColor)),
          ),
          SizedBox(width: 56, child: Center(child: CharacterAvatar(characterId: e.characterId, size: 36))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.isMe ? '${e.name} (Kamu)' : e.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: mainColor)),
                Text('Level ${e.level}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.bolt, size: 18, color: AppColors.yellow),
          const SizedBox(width: 2),
          Text('${formatXp(e.totalXp)} XP',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: mainColor)),
        ],
      ),
    );
  }
}
