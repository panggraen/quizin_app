import 'package:flutter/widgets.dart';

/// Tab aktif di [MainShell]. Dipisah dari State agar layar yang dibuka lewat
/// Navigator.push (Toko, Peringkat, Pengaturan, dst.) juga bisa memindahkan
/// tab lewat navigasi atas di layar lebar.
class ShellNav extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void select(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }

  /// Dipanggil saat shell dibuat (mis. setelah login). Tidak memicu rebuild.
  void resetSilently() => _index = 0;
}

/// Penanda "layar ini berada di dalam MainShell". Di dalam shell, navigasi atas
/// sudah digambar oleh shell, jadi [ScreenScaffold] tidak menggambarnya lagi.
class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required super.child});

  static bool isInside(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ShellScope>() != null;

  @override
  bool updateShouldNotify(ShellScope oldWidget) => false;
}
