import 'package:flutter/foundation.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/models/leaderboard_model.dart';
import 'package:quizin_app/models/progress_model.dart';
import 'package:quizin_app/models/user_model.dart';
import 'package:quizin_app/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._service);
  final ProfileService _service;

  UserModel? user;
  bool loading = false;
  String? error;

  /// Ambil ulang XP, koin, level dari server (dipanggil setelah kuis, materi, beli).
  Future<void> load() async {
    if (user == null) {
      loading = true;
      notifyListeners();
    }
    try {
      user = await _service.profile();
      error = null;
    } catch (e) {
      error = errorMessage(e);
    }
    loading = false;
    notifyListeners();
  }

  Future<String?> updateName(String name) async {
    try {
      user = await _service.updateName(name);
      notifyListeners();
      return null;
    } catch (e) {
      return errorMessage(e);
    }
  }

  void clear() {
    user = null;
    error = null;
    notifyListeners();
  }

  Future<List<LeaderboardEntryModel>> leaderboard() => _service.leaderboard();
  Future<ProgressModel> progress() => _service.progress();
}
