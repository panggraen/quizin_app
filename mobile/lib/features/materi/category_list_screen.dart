import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/materi/subject_list_screen.dart';
import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/category_icon.dart';
import 'package:quizin_app/widgets/character_avatar.dart';
import 'package:quizin_app/widgets/nav_card.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

/// Langkah 1 alur: Kategori. Dipakai tab Materi dan tab Kuis.
class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key, required this.mode, this.isTab = false});

  final FlowMode mode;
  final bool isTab;

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late Future<List<CategoryModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<MaterialProvider>().categories();

  @override
  Widget build(BuildContext context) {
    final isMateri = widget.mode == FlowMode.materi;
    return ScreenScaffold(
      title: isMateri ? 'Materi' : 'Kuis',
      showBack: !widget.isTab,
      child: AsyncView<List<CategoryModel>>(
        future: _future,
        onRetry: () => setState(_load),
        isEmpty: (d) => d.isEmpty,
        emptyMessage: 'Belum ada kategori yang dipublikasikan.',
        builder: (context, cats) {
          final done = cats.fold<int>(0, (a, c) => a + c.materialsDone);
          final total = cats.fold<int>(0, (a, c) => a + c.materialsTotal);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isMateri ? 'Baca materi dulu yuk, nanti lanjut kuis' : 'Yuk uji pemahamanmu dengan kuis',
                        style: TextStyle(fontSize: 13, color: AppColors.text(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const NimbiWidget(size: 110),
                ],
              ),
              if (isMateri) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Progres belajar', style: TextStyle(fontSize: 12, color: AppColors.text(context))),
                    const Spacer(),
                    Text('$done/$total', style: TextStyle(fontSize: 12, color: AppColors.text(context))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 6,
                    backgroundColor: Colors.black12,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 2),
                const Text('Menyelesaikan satu materi memberi +15 XP (sekali per materi).',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
              const SizedBox(height: 16),
              Text('Topik',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text(context))),
              const SizedBox(height: 8),
              for (var i = 0; i < cats.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NavCard(
                    title: cats[i].name,
                    subtitle: '${cats[i].materialsDone}/${cats[i].materialsTotal} materi',
                    leading: CategoryIcon(name: cats[i].name, size: 40),
                    accent: categoryColor(i),
                    onTap: () => pushScreen(context, SubjectListScreen(category: cats[i], mode: widget.mode)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
