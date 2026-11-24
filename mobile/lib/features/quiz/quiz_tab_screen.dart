import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/features/quiz/module_list_screen.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';

/// Tab Kuis: tidak ada pilihan kategori/bidang. Langsung menampilkan jalur
/// modul kuis (modul 1..10) dari bidang kuis yang tersedia.
class QuizTabScreen extends StatefulWidget {
  const QuizTabScreen({super.key});

  @override
  State<QuizTabScreen> createState() => _QuizTabScreenState();
}

class _QuizTabScreenState extends State<QuizTabScreen> {
  late Future<List<SubjectModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = _firstSubject();

  /// Bidang pertama dari kategori pertama yang punya bidang.
  Future<List<SubjectModel>> _firstSubject() async {
    final provider = context.read<MaterialProvider>();
    final categories = await provider.categories();
    for (final c in categories) {
      final subjects = await provider.subjects(c.id);
      if (subjects.isNotEmpty) return [subjects.first];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<SubjectModel>>(
      future: _future,
      onRetry: () => setState(_load),
      isEmpty: (d) => d.isEmpty,
      emptyMessage: 'Belum ada kuis yang tersedia.',
      builder: (context, subjects) => ModuleListScreen(subject: subjects.first, isTab: true),
    );
  }
}