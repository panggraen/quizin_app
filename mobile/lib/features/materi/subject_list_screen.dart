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
import 'package:quizin_app/widgets/page_header.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

enum _SubjectFilter { semua, belum, selesai }

/// Langkah 2 alur: Bidang (subject) dalam satu kategori.
/// Mode materi -> daftar materi. Mode kuis -> peta modul kuis.
class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key, required this.category, required this.mode});

  final CategoryModel category;
  final FlowMode mode;

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  static const Color _navy = Color(0xFF0B1F5B);
  static const Color _border = Color(0xFFC9D8F2);
  static const Color _badge = Color(0xFFD6E9FF);
  static const Color _muted = Color(0xFF4A5675);
  static const Color _blue = Color(0xFF1F7BEF);

  late Future<List<SubjectModel>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _SubjectFilter _filter = _SubjectFilter.semua;

  bool get _dark => AppColors.isDark(context);
  bool get _isKuis => widget.mode == FlowMode.kuis;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<MaterialProvider>().subjects(widget.category.id);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isDone(SubjectModel s) => s.materialsTotal > 0 && s.materialsDone >= s.materialsTotal;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      padding: EdgeInsets.zero,
      child: Container(
        color: _dark ? AppColors.darkBg : const Color(0xFFF8FAFF),
        child: Column(
          children: [
            PageHeader(title: '${_isKuis ? 'Kuis' : 'Materi'} ${widget.category.name}'),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Expanded(child: _searchField()),
                  const SizedBox(width: 12),
                  _filterButton(),
                ],
              ),
            ),
            Expanded(
              child: AsyncView<List<SubjectModel>>(
                future: _future,
                onRetry: () => setState(_load),
                isEmpty: (d) => d.isEmpty,
                emptyMessage: 'Belum ada bidang di kategori ini.',
                builder: (context, subjects) {
                  // Bidang "saat ini" = bidang pertama yang belum selesai.
                  final currentIdx = subjects.indexWhere((s) => !_isDone(s));
                  final shown = <int>[
                    for (var i = 0; i < subjects.length; i++)
                      if (subjects[i].name.toLowerCase().contains(_query.toLowerCase()) &&
                          switch (_filter) {
                            _SubjectFilter.semua => true,
                            _SubjectFilter.belum => !_isDone(subjects[i]),
                            _SubjectFilter.selesai => _isDone(subjects[i]),
                          })
                        i,
                  ];
                  if (shown.isEmpty) {
                    return const Center(child: Text('Bidang tidak ditemukan.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                    itemCount: shown.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, i) =>
                        _subjectTile(subjects[shown[i]], shown[i] + 1, shown[i] == currentIdx),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() => TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        style: TextStyle(fontSize: 14, color: _dark ? Colors.white : _navy),
        decoration: InputDecoration(
          hintText: _isKuis ? 'Cari kuis...' : 'Cari materi...',
          hintStyle: const TextStyle(fontSize: 14, color: _muted),
          prefixIcon: Icon(Icons.search_rounded, color: _dark ? Colors.white70 : _navy, size: 22),
          filled: true,
          fillColor: _dark ? AppColors.darkSurface : const Color(0xFFF1F5FF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
      );

  Widget _filterButton() => PopupMenuButton<_SubjectFilter>(
        tooltip: 'Filter',
        initialValue: _filter,
        onSelected: (f) => setState(() => _filter = f),
        itemBuilder: (context) => const [
          PopupMenuItem(value: _SubjectFilter.semua, child: Text('Semua')),
          PopupMenuItem(value: _SubjectFilter.belum, child: Text('Belum selesai')),
          PopupMenuItem(value: _SubjectFilter.selesai, child: Text('Selesai')),
        ],
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _filter == _SubjectFilter.semua ? const Color(0xFFBFDDFF) : _blue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF9CC8FF), width: 1.5),
          ),
          child: Icon(Icons.tune_rounded,
              color: _filter == _SubjectFilter.semua ? _navy : Colors.white, size: 22),
        ),
      );

  Widget _subjectTile(SubjectModel s, int number, bool current) {
    final done = _isDone(s);
    return Material(
      color: current
          ? (_dark ? const Color(0xFF223463) : const Color(0xFFEAF3FF))
          : AppColors.surface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => pushScreen(
          context,
          _isKuis
              ? ModuleListScreen(subject: s)
              : MaterialListScreen(subject: s, mode: widget.mode),
        ),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: current ? const Color(0xFF8FC0FF) : _border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _badge, borderRadius: BorderRadius.circular(10)),
                child: Text('$number',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _navy)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _dark ? Colors.white : _navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isKuis ? 'Lihat modul kuis' : '${s.materialsTotal} materi',
                      style: TextStyle(fontSize: 12, color: _dark ? Colors.white70 : _muted),
                    ),
                  ],
                ),
              ),
              Icon(
                done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                color: done ? AppColors.green : (_dark ? Colors.white70 : _navy),
                size: done ? 22 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}