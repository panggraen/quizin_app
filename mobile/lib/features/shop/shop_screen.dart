import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/providers/shop_provider.dart';
import 'package:quizin_app/widgets/character_card.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';
import 'package:quizin_app/models/character_model.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/state_widgets.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  /// Lebar maksimal halaman toko (satu kolom).
  static const double _maxWidth = 760;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ShopProvider>().load();
      context.read<ProfileProvider>().load();
    });
  }

  Future<void> _run(Future<String?> Function() action, String successMessage) async {
    final error = await action();
    if (!mounted) return;
    if (error == null) {
      context.read<ProfileProvider>().load(); // saldo koin dari server
      showMessage(context, successMessage);
    } else {
      showMessage(context, error);
    }
  }

  /// Lepas aksesori = pakai kembali item bawaan (maskot tanpa aksesori).
  Future<void> _unequip(ShopProvider shop, CharacterModel c) {
    final defaults = shop.characters.where((x) => x.isDefault);
    if (defaults.isEmpty) return Future.value();
    return _run(() => shop.use(defaults.first.id), '${c.name} dilepas.');
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final user = context.watch<ProfileProvider>().user;
    final coins = user?.coins;
    return ScreenScaffold(
      title: 'Toko',
      maxWidth: _maxWidth,
      child: shop.loading && shop.characters.isEmpty
          ? const LoadingWidget()
          : shop.error != null && shop.characters.isEmpty
              ? ErrorStateWidget(message: shop.error!, onRetry: shop.load)
              : LayoutBuilder(
                  builder: (context, _) {
                    Widget card(CharacterModel ch) => CharacterCard(
                          character: ch,
                          busy: shop.busyId != null,
                          onBuy: () => _run(
                              () => shop.buy(ch.id), '${ch.name} berhasil dibeli.'),
                          onUse: () => _run(() => shop.use(ch.id),
                              '${ch.name} sekarang dipakai.'),
                          onUnequip: () => _unequip(shop, ch),
                        );

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF3B82F6)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Saldo Koinmu', style: TextStyle(color: Colors.white)),
                                    Row(children: [
                                      const Icon(Icons.monetization_on, color: AppColors.yellow, size: 28),
                                      const SizedBox(width: 6),
                                      Text('${coins ?? '-'}',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                                    ]),
                                    const SizedBox(height: 4),
                                    const Text('Dapatkan koin dari jawaban benar untuk membeli aksesori.',
                                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                ),
                              ),
                              CloudMascot(size: 80, accessoryId: user?.activeCharacterId),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (final ch in shop.characters)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: card(ch),
                          ),
                      ],
                    );
                  },
                ),
    );
  }
}
