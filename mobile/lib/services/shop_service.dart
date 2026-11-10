import 'package:quizin_app/models/character_model.dart';

/// Kontrak: GET /api/characters, POST /api/characters/{id}/purchase, PUT /api/profile/character
abstract class ShopService {
  Future<List<CharacterModel>> characters();
  Future<CharacterModel> purchase(int characterId);
  Future<void> setActiveCharacter(int characterId);
}
