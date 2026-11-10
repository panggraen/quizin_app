import 'package:quizin_app/models/json_utils.dart';

class ProgressItemModel {
  final String title;
  final String subtitle;

  /// 'material' | 'quiz'
  final String type;

  const ProgressItemModel({required this.title, required this.subtitle, required this.type});

  factory ProgressItemModel.fromJson(Map<String, dynamic> j) => ProgressItemModel(
        title: j['title'] as String? ?? '',
        subtitle: j['subtitle'] as String? ?? '',
        type: j['type'] as String? ?? 'material',
      );
}

class BadgeModel {
  final int id;
  final String name;
  final String description;
  final int requiredModules;
  final bool isEarned;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredModules,
    required this.isEarned,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> j) => BadgeModel(
        id: toInt(j['id']),
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        requiredModules: toInt(j['required_modules']),
        isEarned: toBool(j['is_earned']),
      );
}

class ProgressModel {
  final int totalXp;
  final int totalCoins;
  final List<ProgressItemModel> items;
  final List<BadgeModel> badges;

  const ProgressModel({
    required this.totalXp,
    required this.totalCoins,
    required this.items,
    required this.badges,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> j) => ProgressModel(
        totalXp: toInt(j['total_xp']),
        totalCoins: toInt(j['total_coins']),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => ProgressItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        badges: (j['badges'] as List<dynamic>? ?? [])
            .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
