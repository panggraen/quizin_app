import 'package:flutter/foundation.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/models/character_model.dart';
import 'package:quizin_app/services/shop_service.dart';

class ShopProvider extends ChangeNotifier {
  ShopProvider(this._service);
  final ShopService _service;

  List<CharacterModel> characters = [];
  bool loading = false;
  String? error;
  int? busyId;

  Future<void> load() async {
    if (characters.isEmpty) {
      loading = true;
      notifyListeners();
    }
    try {
      characters = await _service.characters();
      error = null;
    } catch (e) {
      error = errorMessage(e);
    }
    loading = false;
    notifyListeners();
  }

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> buy(int id) => _act(id, () => _service.purchase(id));

  Future<String?> use(int id) => _act(id, () => _service.setActiveCharacter(id));

  Future<String?> _act(int id, Future<void> Function() action) async {
    if (busyId != null) return null; // cegah tekan berulang
    busyId = id;
    notifyListeners();
    try {
      await action();
      characters = await _service.characters();
      return null;
    } catch (e) {
      return errorMessage(e);
    } finally {
      busyId = null;
      notifyListeners();
    }
  }
}
