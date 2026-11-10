import 'package:quizin_app/models/leaderboard_model.dart';
import 'package:quizin_app/models/progress_model.dart';
import 'package:quizin_app/models/user_model.dart';

/// Kontrak: GET /api/profile, PATCH /api/profile/name, GET /api/leaderboard, GET /api/progress
abstract class ProfileService {
  Future<UserModel> profile();
  Future<UserModel> updateName(String name);
  Future<List<LeaderboardEntryModel>> leaderboard();
  Future<ProgressModel> progress();
}
