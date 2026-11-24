import 'package:flutter/material.dart';

/// Maskot Quizin. Tanpa [characterId] tampil awan Nimbi transparan (dipakai
/// layar login dan banner). Dengan [characterId] tampil gambar karakter
/// utuh (kotak berujung bulat) dari aset karakter.
class CloudMascot extends StatelessWidget {
  const CloudMascot({super.key, this.size = 100, this.characterId, this.borderRadius});

  static const String baseAsset = 'assets/cloud_maskot.png';

  /// Rasio gambar awan (sudah di-crop rapat).
  static const double aspect = 760 / 462;

  /// Lebar awan = size * [widthFactor].
  static const double widthFactor = 1.25;

  /// ID karakter (sama dengan data toko) -> file aset.
  static const Map<int, String> characterAssets = {
    1: 'assets/nimbi.png',
    2: 'assets/sunny.png',
    3: 'assets/minty.png',
    4: 'assets/bluby.png',
    5: 'assets/nova.png',
  };

  final double size;

  /// ID karakter. null / tidak dikenal = awan Nimbi transparan.
  final int? characterId;

  /// Radius sudut gambar karakter. Default 22% dari [size].
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final asset = characterAssets[characterId];
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? size * 0.22),
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              SizedBox(width: size, height: size, child: const Icon(Icons.cloud, color: Color(0xFF8DB7F5))),
        ),
      );
    }

    final w = size * widthFactor;
    return Image.asset(
      baseAsset,
      width: w,
      height: w / aspect,
      fit: BoxFit.contain,
      semanticLabel: 'Maskot awan Quizin',
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.cloud, size: size, color: const Color(0xFF8DB7F5)),
    );
  }
}
