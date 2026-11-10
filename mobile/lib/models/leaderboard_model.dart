import 'package:quizin_app/models/json_utils.dart';

class LeaderboardEntryModel {
  final int rank;
  final int userId;
  final String name;
  final int level;
  final int totalXp;
  final int characterId;
  final bool isMe;

  const LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.name,
    required this.level,
    required this.totalXp,
    required this.characterId,
    required this.isMe,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> j) =>
      LeaderboardEntryModel(
        rank: toInt(j['rank']),
        userId: toInt(j['user_id']),
        name: j['name'] as String? ?? '',
        level: toInt(j['level']),
        totalXp: toInt(j['total_xp']),
        characterId: toInt(j['character_id']),
        isMe: toBool(j['is_me']),
      );
}
