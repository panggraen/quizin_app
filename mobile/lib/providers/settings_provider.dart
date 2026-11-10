import 'package:flutter/material.dart';

/// Pengaturan tampilan. Sementara hanya di memori.
/// TODO: simpan ke server lewat PUT /api/preferences saat backend siap.
class SettingsProvider extends ChangeNotifier {
  bool soundOn = true;
  bool darkMode = false;

  ThemeMode get themeMode => darkMode ? ThemeMode.dark : ThemeMode.light;

  void setSound(bool value) {
    soundOn = value;
    notifyListeners();
  }

  void setDark(bool value) {
    darkMode = value;
    notifyListeners();
  }
}
