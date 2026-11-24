import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/character_model.dart';
import 'package:quizin_app/providers/shop_provider.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';

/// Kartu "Toko Karakter" di Profil: judul + "Lihat Semua", lalu deretan
/// karakter (gambar, nama, dan status "Dimiliki" atau harga koin).
class ShopPreviewCard extends StatelessWidget {
  const ShopPreviewCard({super.key, required this.onSeeAll, this.maxItems = 4});

  final VoidCallback onSeeAll;
  final int maxItems;

  static const Color _line = Color(0xFFD6E2F7);
  static const Color _blue = Color(0xFF1F7BEF);

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final items = context.watch<ShopProvider>().characters.take(maxItems).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(color: Color(0x141F5FD6), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Toko Karakter',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent(context))),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onSeeAll,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lihat Semua',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800, color: _blue)),
                      Icon(Icons.chevron_right_rounded, size: 18, color: _blue),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const SizedBox(
              height: 96,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _item(context, items[i], dark)),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, CharacterModel c, bool dark) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onSeeAll,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF223463) : const Color(0xFFF3F7FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Column(
          children: [
            CloudMascot(size: 48, characterId: c.id),
            const SizedBox(height: 6),
            Text(
              c.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent(context)),
            ),
            const SizedBox(height: 6),
            _status(c, dark),
          ],
        ),
      ),
    );
  }

  Widget _status(CharacterModel c, bool dark) {
    if (c.isOwned) {
      return _pill(
        bg: dark ? const Color(0xFF2F4A8A) : const Color(0xFFDCE8FB),
        fg: dark ? Colors.white : const Color(0xFF1F5FD6),
        text: 'Dimiliki',
        trailing: Icons.check_rounded,
      );
    }
    return _pill(
      bg: const Color(0xFFFFF0C2),
      fg: const Color(0xFF8A5A00),
      text: '${c.priceCoins}',
      leading: const _Coin(),
    );
  }

  Widget _pill({
    required Color bg,
    required Color fg,
    required String text,
    Widget? leading,
    IconData? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 3)],
            Text(text,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
            if (trailing != null) ...[
              const SizedBox(width: 2),
              Icon(trailing, size: 12, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/coin.png',
      width: 14,
      height: 14,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.monetization_on, size: 14, color: AppColors.yellow),
    );
  }
}
