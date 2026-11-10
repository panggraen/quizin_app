import 'package:quizin_app/models/json_utils.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int totalXp;
  final int coins;
  final int level;
  final int activeCharacterId;
  final int materialsCompleted;
  final int modulesCompleted;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalXp,
    required this.coins,
    required this.level,
    required this.activeCharacterId,
    required this.materialsCompleted,
    required this.modulesCompleted,
  });

  /// XP di dalam level sekarang (level naik tiap 100 XP).
  int get xpInLevel => totalXp % 100;

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: toInt(j['id']),
        name: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        totalXp: toInt(j['total_xp']),
        coins: toInt(j['coins']),
        level: toInt(j['level']),
        activeCharacterId: toInt(j['active_character_id']),
        materialsCompleted: toInt(j['materials_completed']),
        modulesCompleted: toInt(j['modules_completed']),
      );
}
