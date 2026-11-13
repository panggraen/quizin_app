import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/character_model.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.busy,
    required this.onBuy,
    required this.onUse,
    this.onUnequip,
  });

  final CharacterModel character;
  final bool busy;
  final VoidCallback onBuy;
  final VoidCallback onUse;
  final VoidCallback? onUnequip;

  @override
  Widget build(BuildContext context) {
    final c = character;
    Widget action;
    if (c.isActive && !c.isDefault && onUnequip != null) {
      action = OutlinedButton(
        onPressed: busy ? null : onUnequip,
        child: const Text('Lepas'),
      );
    } else if (c.isActive) {
      action = const Chip(label: Text('Dipakai'), avatar: Icon(Icons.check, size: 16));
    } else if (c.isOwned) {
      action = FilledButton(
        onPressed: busy ? null : onUse,
        style: FilledButton.styleFrom(backgroundColor: AppColors.green),
        child: const Text('Gunakan'),
      );
    } else {
      action = FilledButton(
        onPressed: busy ? null : onBuy,
        style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
        child: const Text('Beli'),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Center(child: CloudMascot(size: 72, accessoryId: c.id)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.text(context))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.monetization_on, size: 14, color: AppColors.yellow),
                        const SizedBox(width: 4),
                        Text(c.priceCoins == 0 ? 'Free' : '${c.priceCoins}',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(c.description, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            ),
          ),
        ],
      ),
    );
  }
}