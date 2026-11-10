import 'package:flutter/material.dart';

/// Gambar karakter. Jika file gambar belum ada di assets, tampil awan sederhana (PLACEHOLDER).
/// Taruh gambar di assets/images/characters/character_<id>.png
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.characterId, this.size = 80});

  final int characterId;
  final double size;

  Color get _tint {
    switch (characterId) {
      case 2:
        return const Color(0xFF6B8AD1);
      case 3:
        return const Color(0xFF7E6BC9);
      default:
        return const Color(0xFF8DB7F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/characters/character_$characterId.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: size, height: size, child: Icon(Icons.cloud, size: size, color: _tint)),
    );
  }
}

class NimbiWidget extends StatelessWidget {
  const NimbiWidget({super.key, this.size = 100});
  final double size;

  @override
  Widget build(BuildContext context) => CharacterAvatar(characterId: 1, size: size);
}
