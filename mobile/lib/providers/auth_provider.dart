import 'package:flutter/foundation.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);
  final AuthService _service;

  bool loading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    return _run(() => _service.login(email, password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _run(() => _service.register(
        name: name, email: email, phone: phone, password: password));
  }

  Future<void> logout() => _service.logout();

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      error = errorMessage(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
