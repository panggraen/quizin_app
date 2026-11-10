import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/progress_model.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/stat_box.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<ProgressModel> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<ProfileProvider>().progress();

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Progress',
      showBack: false,
      child: AsyncView<ProgressModel>(
        future: _future,
        onRetry: () => setState(_load),
        builder: (context, p) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Row(
              children: [
                Expanded(child: StatBox(value: '${p.totalXp}', label: 'Total XP', icon: Icons.bolt)),
                const SizedBox(width: 10),
                Expanded(child: StatBox(value: '${p.totalCoins}', label: 'Saldo koin', icon: Icons.monetization_on)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Badge',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text(context))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in p.badges)
                  Chip(
                    avatar: Icon(b.isEarned ? Icons.verified : Icons.lock_outline,
                        size: 18, color: b.isEarned ? AppColors.green : Colors.grey),
                    label: Text('${b.name} (${b.requiredModules} modul)'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Riwayat',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text(context))),
            const SizedBox(height: 8),
            if (p.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada riwayat. Selesaikan materi atau kuis pertamamu.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
              ),
            for (final it in p.items)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.yellow, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(it.type == 'quiz' ? Icons.quiz : Icons.menu_book, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.title,
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
                          Text(it.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
