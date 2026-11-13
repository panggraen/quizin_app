import 'package:flutter/material.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.characterId, this.size = 80});

  final int characterId;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CloudMascot(size: size, accessoryId: characterId);
}

class NimbiWidget extends StatelessWidget {
  const NimbiWidget({super.key, this.size = 100});
  final double size;

  @override
  Widget build(BuildContext context) => CloudMascot(size: size);
}
