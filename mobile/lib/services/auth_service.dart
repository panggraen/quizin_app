import 'package:quizin_app/models/user_model.dart';

/// Kontrak: POST /api/register, POST /api/login, POST /api/logout, GET /api/me
abstract class AuthService {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<UserModel> me();
}
