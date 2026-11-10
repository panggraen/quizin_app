import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/leaderboard_model.dart';
import 'package:quizin_app/widgets/character_avatar.dart';

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key, required this.entry});
  final LeaderboardEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: e.isMe ? const Color(0xFFFAB5B5) : AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${e.rank}',
                style: TextStyle(fontWeight: FontWeight.w700, color: e.isMe ? AppColors.navy : AppColors.text(context))),
          ),
          CharacterAvatar(characterId: e.characterId, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.isMe ? '${e.name} (Kamu)' : e.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: e.isMe ? AppColors.navy : AppColors.text(context))),
                Text('Level ${e.level}',
                    style: TextStyle(fontSize: 11, color: e.isMe ? AppColors.navy : AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.bolt, size: 16, color: AppColors.yellow),
          Text(' ${e.totalXp} XP',
              style: TextStyle(fontWeight: FontWeight.w600, color: e.isMe ? AppColors.navy : AppColors.text(context))),
        ],
      ),
    );
  }
}
