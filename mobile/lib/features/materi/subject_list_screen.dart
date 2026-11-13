import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/materi/material_list_screen.dart';
import 'package:quizin_app/features/quiz/module_list_screen.dart';
import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/nav_card.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

/// Langkah 2 alur: Bidang (subject) dalam satu kategori.
/// Mode materi -> daftar materi. Mode kuis -> langsung daftar modul 1..N.
class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key, required this.category, required this.mode});

  final CategoryModel category;
  final FlowMode mode;

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  late Future<List<SubjectModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<MaterialProvider>().subjects(widget.category.id);

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Kategori',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(widget.category.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text(context))),
          const SizedBox(height: 10),
          Expanded(
            child: AsyncView<List<SubjectModel>>(
              future: _future,
              onRetry: () => setState(_load),
              isEmpty: (d) => d.isEmpty,
              emptyMessage: 'Belum ada bidang di kategori ini.',
              builder: (context, subjects) => ListView.separated(
                itemCount: subjects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) => NavCard(
                  title: subjects[i].name,
                  subtitle: widget.mode == FlowMode.kuis
                      ? 'Lihat modul kuis'
                      : '${subjects[i].materialsDone}/${subjects[i].materialsTotal} materi',
                  icon: Icons.biotech,
                  onTap: () => pushScreen(
                    context,
                    widget.mode == FlowMode.kuis
                        ? ModuleListScreen(subject: subjects[i])
                        : MaterialListScreen(subject: subjects[i], mode: widget.mode),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}