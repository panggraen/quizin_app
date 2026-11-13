import 'package:flutter/widgets.dart';

/// Satu sumber untuk semua titik patah layout. Jangan menulis angka lebar
/// langsung di layar; pakai konstanta di sini supaya web dan HP selalu
/// berpindah layout di titik yang sama.
class Breakpoints {
  /// Di atas ini: navigasi di bagian ATAS (web / desktop / tablet landscape).
  /// Di bawah ini: navigasi bawah (HP).
  static const double desktop = 900;

  /// Di atas ini kartu login/daftar tampil dua panel.
  static const double authSplit = 840;

  /// Lebar maksimal konten utama dan bilah navigasi atas.
  static const double contentMax = 1100;

  /// Lebar maksimal halaman berisi daftar / bacaan (materi, kuis, profil).
  static const double readingMax = 720;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// true = layar lebar: pakai navigasi atas dan konten ber-lebar-maksimal.
  bool get isDesktop => screenWidth >= Breakpoints.desktop;
}
