import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/providers/shop_provider.dart';
import 'package:quizin_app/widgets/character_avatar.dart';
import 'package:quizin_app/widgets/character_card.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/state_widgets.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
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

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final coins = context.watch<ProfileProvider>().user?.coins;
    return ScreenScaffold(
      title: 'Toko',
      child: shop.loading && shop.characters.isEmpty
          ? const LoadingWidget()
          : shop.error != null && shop.characters.isEmpty
              ? ErrorStateWidget(message: shop.error!, onRetry: shop.load)
              : ListView(
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
                                const Text('Dapatkan koin dari jawaban benar untuk membeli karakter.',
                                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                          const NimbiWidget(size: 80),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final c in shop.characters)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CharacterCard(
                          character: c,
                          busy: shop.busyId != null,
                          onBuy: () => _run(() => shop.buy(c.id), '${c.name} berhasil dibeli.'),
                          onUse: () => _run(() => shop.use(c.id), '${c.name} sekarang dipakai.'),
                        ),
                      ),
                  ],
                ),
    );
  }
}
