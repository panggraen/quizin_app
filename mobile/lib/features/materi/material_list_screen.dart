import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/features/materi/material_detail_screen.dart';
import 'package:quizin_app/features/quiz/module_list_screen.dart';
import 'package:quizin_app/models/material_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/nav_card.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

/// Langkah 3 alur: Materi (topik) dalam satu bidang.
/// Mode materi -> baca materi. Mode kuis -> daftar modul kuis materi itu.
class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({super.key, required this.subject, required this.mode});

  final SubjectModel subject;
  final FlowMode mode;

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  late Future<List<MaterialModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<MaterialProvider>().materials(widget.subject.id);

  void _open(MaterialModel m) {
    final screen = widget.mode == FlowMode.materi
        ? MaterialDetailScreen(materialId: m.id, subject: widget.subject)
        : ModuleListScreen(material: m);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (mounted) setState(_load);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMateri = widget.mode == FlowMode.materi;
    return ScreenScaffold(
      title: isMateri ? 'Materi' : 'Kuis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(widget.subject.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text(context))),
          const SizedBox(height: 10),
          Expanded(
            child: AsyncView<List<MaterialModel>>(
              future: _future,
              onRetry: () => setState(_load),
              isEmpty: (d) => d.isEmpty,
              emptyMessage: 'Belum ada materi yang dipublikasikan.',
              builder: (context, items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) => NavCard(
                  title: items[i].title,
                  subtitle: isMateri
                      ? (items[i].isCompleted ? 'Selesai' : 'Belum dibaca')
                      : 'Lihat modul kuis',
                  icon: Icons.science_outlined,
                  accent: items[i].isCompleted && isMateri ? AppColors.green : AppColors.navy,
                  trailing: items[i].isCompleted && isMateri
                      ? const Icon(Icons.check_circle, color: AppColors.green)
                      : null,
                  onTap: () => _open(items[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
