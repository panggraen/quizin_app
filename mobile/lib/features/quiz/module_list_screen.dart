import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/materi/material_detail_screen.dart';
import 'package:quizin_app/features/quiz/quiz_play_screen.dart';
import 'package:quizin_app/models/material_model.dart';
import 'package:quizin_app/models/quiz_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/providers/quiz_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/quiz_module_card.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/secondary_button.dart';

/// Langkah 4 alur: daftar modul kuis sebuah materi (Tersedia, Terkunci, Selesai).
class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key, required this.material});

  final MaterialModel material;

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  late Future<List<QuizModuleModel>> _future;
  int? _selectedId;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<QuizProvider>().modules(widget.material.id);

  Future<void> _start(QuizModuleModel module) async {
    setState(() => _starting = true);
    try {
      await context.read<QuizProvider>().start(module.id);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizPlayScreen()));
      if (mounted) setState(_load);
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: widget.material.title,
      child: AsyncView<List<QuizModuleModel>>(
        future: _future,
        onRetry: () => setState(_load),
        isEmpty: (d) => d.isEmpty,
        emptyMessage: 'Belum ada modul kuis untuk materi ini.',
        builder: (context, modules) {
          // Modul terpilih: yang dipilih pengguna, atau modul tersedia pertama.
          final selected = modules.firstWhere(
            (m) => m.id == _selectedId,
            orElse: () => modules.firstWhere((m) => !m.isLocked && !m.isCompleted, orElse: () => modules.first),
          );
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 8),
              Text('Pilih modul',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text(context))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  for (final m in modules)
                    QuizModuleCard(
                      module: m,
                      selected: m.id == selected.id,
                      onTap: () => setState(() => _selectedId = m.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                selected.isLocked
                    ? 'Modul ${selected.moduleNumber} terkunci. Selesaikan modul sebelumnya dulu.'
                    : selected.isCompleted
                        ? 'Modul ${selected.moduleNumber} selesai. Nilai terbaik: ${selected.bestScore}%'
                        : 'Modul ${selected.moduleNumber} siap dikerjakan.',
                style: TextStyle(color: AppColors.text(context)),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: selected.isCompleted ? 'Ulangi Kuis' : 'Mulai Kuis',
                loading: _starting,
                onPressed: selected.isLocked ? null : () => _start(selected),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Baca Materi',
                onPressed: () => pushScreen(
                  context,
                  MaterialDetailScreen(
                    materialId: widget.material.id,
                    subject: SubjectModel(
                      id: widget.material.subjectId,
                      categoryId: 0,
                      name: widget.material.title,
                      materialsDone: 0,
                      materialsTotal: 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
