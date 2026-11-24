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
import 'package:quizin_app/widgets/page_header.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

enum _MaterialFilter { semua, belum, selesai }

/// Daftar materi dalam satu bidang (mis. Materi Biologi -> Sel, Genetika, ...).
class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({super.key, required this.subject, required this.mode});

  final SubjectModel subject;
  final FlowMode mode;

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  static const Color _navy = Color(0xFF0B1F5B);
  static const Color _border = Color(0xFFC9D8F2);
  static const Color _badge = Color(0xFFD6E6FF);
  static const Color _muted = Color(0xFF5B6784);
  static const Color _blue = Color(0xFF1F7BEF);

  late Future<List<MaterialModel>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _MaterialFilter _filter = _MaterialFilter.semua;

  bool get _dark => AppColors.isDark(context);
  bool get _isMateri => widget.mode == FlowMode.materi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<MaterialProvider>().materials(widget.subject.id);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _open(MaterialModel m) {
    final screen = _isMateri
        ? MaterialDetailScreen(materialId: m.id, subject: widget.subject)
        : ModuleListScreen(subject: widget.subject);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (mounted) setState(_load);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      padding: EdgeInsets.zero,
      child: Container(
        color: _dark ? AppColors.darkBg : const Color(0xFFF8FAFF),
        child: Column(
          children: [
            PageHeader(title: '${_isMateri ? 'Materi' : 'Kuis'} ${widget.subject.name}'),
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
              child: AsyncView<List<MaterialModel>>(
                future: _future,
                onRetry: () => setState(_load),
                isEmpty: (d) => d.isEmpty,
                emptyMessage: 'Belum ada materi yang dipublikasikan.',
                builder: (context, items) {
                  // Sorotan: materi pertama yang belum selesai.
                  final currentIdx = items.indexWhere((m) => !m.isCompleted);
                  final shown = <int>[
                    for (var i = 0; i < items.length; i++)
                      if (items[i].title.toLowerCase().contains(_query.toLowerCase()) &&
                          switch (_filter) {
                            _MaterialFilter.semua => true,
                            _MaterialFilter.belum => !items[i].isCompleted,
                            _MaterialFilter.selesai => items[i].isCompleted,
                          })
                        i,
                  ];
                  if (shown.isEmpty) {
                    return const Center(child: Text('Materi tidak ditemukan.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                    itemCount: shown.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, i) =>
                        _tile(items[shown[i]], shown[i] + 1, _isMateri && shown[i] == currentIdx),
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
          hintText: 'Cari materi...',
          hintStyle: const TextStyle(fontSize: 14, color: _muted),
          prefixIcon: Icon(Icons.search_rounded, color: _dark ? Colors.white70 : _navy, size: 22),
          filled: true,
          fillColor: _dark ? AppColors.darkSurface : const Color(0xFFEEF3FF),
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

  Widget _filterButton() => PopupMenuButton<_MaterialFilter>(
        tooltip: 'Filter',
        initialValue: _filter,
        onSelected: (f) => setState(() => _filter = f),
        itemBuilder: (context) => const [
          PopupMenuItem(value: _MaterialFilter.semua, child: Text('Semua')),
          PopupMenuItem(value: _MaterialFilter.belum, child: Text('Belum dibaca')),
          PopupMenuItem(value: _MaterialFilter.selesai, child: Text('Selesai')),
        ],
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _filter == _MaterialFilter.semua ? const Color(0xFFBFDDFF) : _blue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF9CC8FF), width: 1.5),
          ),
          child: Icon(Icons.tune_rounded,
              color: _filter == _MaterialFilter.semua ? _navy : Colors.white, size: 22),
        ),
      );

  Widget _tile(MaterialModel m, int number, bool current) {
    return Material(
      color: current
          ? (_dark ? const Color(0xFF223463) : const Color(0xFFE3EFFF))
          : AppColors.surface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _open(m),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: current ? const Color(0xFF7DB4FF) : _border, width: 1.5),
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
                      m.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _dark ? Colors.white : _navy,
                      ),
                    ),
                    if (_isMateri) ...[
                      const SizedBox(height: 2),
                      Text(
                        m.isCompleted ? 'Selesai' : 'Belum dibaca',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: m.isCompleted ? AppColors.green : (_dark ? Colors.white70 : _muted),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                m.isCompleted && _isMateri ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                color: m.isCompleted && _isMateri ? AppColors.green : (_dark ? Colors.white70 : _navy),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}