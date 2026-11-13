import 'package:flutter/material.dart';

class MascotAccessory {
  const MascotAccessory(
    this.asset, {
    this.alignment = Alignment.center,
    this.scale = 1.0,
  });

  final String asset;
  final Alignment alignment;

  /// Lebar aksesori dibanding lebar maskot (1.0 = sama).
  final double scale;
}

class CloudMascot extends StatelessWidget {
  const CloudMascot({
    super.key,
    this.size = 100,
    this.accessoryId,
    this.showBase = true,
  });

  static const String baseAsset = 'assets/cloud_maskot.png';

  /// Semua PNG maskot sudah di-crop rapat dengan rasio sama (760x462),
  /// jadi aksesori tetap pas di kepala Nimbi.
  static const double aspect = 760 / 462;

  /// Lebar kotak = size * [widthFactor]. Naikkan angka ini kalau mau Nimbi
  /// tampil lebih besar di SEMUA tempat sekaligus.
  static const double widthFactor = 1.25;

  /// Ukuran & posisi aksesori. Kecilkan/besarkan lewat [scale] (1.0 = selebar
  /// maskot). [alignment] menggeser aksesori: y negatif = naik ke kepala.
  static const Map<int, MascotAccessory> accessories = {
    2: MascotAccessory('assets/headphones.png',
        alignment: Alignment(0, -0.5), scale: 0.72),
    3: MascotAccessory('assets/crown.png',
        alignment: Alignment(0, -1.08), scale: 0.48),
    4: MascotAccessory('assets/graduation_cap.png',
        alignment: Alignment(0, -1.16), scale: 0.5),
    6: MascotAccessory('assets/wizard_hat.png',
        alignment: Alignment(0, -1.16), scale: 0.5),
  };

  final double size;

  /// ID item toko yang sedang dipakai. null / tidak dikenal = tanpa aksesori.
  final int? accessoryId;

  /// false = hanya aksesori, tanpa awan (dipakai di kartu toko).
  /// Item tanpa aksesori (Nimbi) tetap menampilkan awan.
  final bool showBase;

  @override
  Widget build(BuildContext context) {
    final accessory = accessories[accessoryId];
    final showCloud = showBase || accessory == null;

    final w = size * widthFactor;
    final h = w / aspect;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (showCloud)
            Image.asset(
              baseAsset,
              width: w,
              height: h,
              fit: BoxFit.contain,
              semanticLabel: 'Maskot awan Quizin',
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.cloud,
                size: size,
                color: const Color(0xFF8DB7F5),
              ),
            ),
          if (accessory != null)
            Align(
              alignment: accessory.alignment,
              child: Image.asset(
                accessory.asset,
                width: w * accessory.scale,
                height: h * accessory.scale,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}