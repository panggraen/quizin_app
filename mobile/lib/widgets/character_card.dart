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
  });

  final CharacterModel character;
  final bool busy;
  final VoidCallback onBuy;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final c = character;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CloudMascot(size: 80, characterId: c.id),
          Container(
            width: 1,
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.line,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.accent(context))),
                    ),
                    _pricePill(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(c.description,
                    style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.muted)),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: _action(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pricePill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(
            'assets/coin.png',
            width: 14,
            height: 14,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.monetization_on, size: 14, color: AppColors.yellow),
          ),
          const SizedBox(width: 4),
          Text(character.priceCoins == 0 ? 'Free' : '${character.priceCoins}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      );

  /// Beli (belum dimiliki) -> Pakai (dimiliki) -> Dipakai (sedang aktif).
  Widget _action(BuildContext context) {
    const shape = StadiumBorder();
    const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
    if (character.isActive) {
      return SizedBox(
        width: 112,
        height: 34,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_rounded, size: 16),
          label: const Text('Dipakai', style: label),
          style: OutlinedButton.styleFrom(
            shape: shape,
            padding: EdgeInsets.zero,
            disabledForegroundColor: AppColors.accent(context),
            side: const BorderSide(color: Color(0xFFB8C8EE)),
          ),
        ),
      );
    }
    final owned = character.isOwned;
    return SizedBox(
      width: 112,
      height: 34,
      child: FilledButton(
        onPressed: busy ? null : (owned ? onUse : onBuy),
        style: FilledButton.styleFrom(
          shape: shape,
          padding: EdgeInsets.zero,
          backgroundColor: owned ? AppColors.green : AppColors.navy,
          foregroundColor: Colors.white,
        ),
        child: Text(owned ? 'Pakai' : 'Beli', style: label),
      ),
    );
  }
}
