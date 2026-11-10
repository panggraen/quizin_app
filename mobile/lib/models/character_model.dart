import 'package:quizin_app/models/json_utils.dart';

class CharacterModel {
  final int id;
  final String name;
  final String description;
  final int priceCoins;
  final bool isDefault;
  final bool isOwned;
  final bool isActive;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCoins,
    required this.isDefault,
    required this.isOwned,
    required this.isActive,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> j) => CharacterModel(
        id: toInt(j['id']),
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        priceCoins: toInt(j['price_coins']),
        isDefault: toBool(j['is_default']),
        isOwned: toBool(j['is_owned']),
        isActive: toBool(j['is_active']),
      );
}
