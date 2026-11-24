import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/constants/flow_mode.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/features/materi/material_list_screen.dart';
import 'package:quizin_app/features/quiz/module_list_screen.dart';
import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/category_icon.dart';
import 'package:quizin_app/widgets/page_header.dart';

/// Tab Materi: kartu kategori (2 kolom) + tab kategori + daftar bidang
/// kategori terpilih. Ketuk bidang -> daftar materi bidang itu.
class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key, required this.mode, this.isTab = false});

  final FlowMode mode;
  final bool isTab;

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  static const double _maxWidth = 720;
  static const Color _navy = Color(0xFF0B1F5B);
  static const Color _blue = Color(0xFF1F7BEF);
  static const Color _border = Color(0xFFC9D8F2);
  static const Color _muted = Color(0xFF5B6784);
  static const Color _badge = Color(0xFFDCE8FB);

  late Future<List<CategoryModel>> _future;
  final Map<int, Future<List<SubjectModel>>> _subjectFutures = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _selected = 0;

  bool get _dark => AppColors.isDark(context);
  bool get _isMateri => widget.mode == FlowMode.materi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _subjectFutures.clear();
    _future = context.read<MaterialProvider>().categories();
  }

  Future<List<SubjectModel>> _subjectsOf(int categoryId) => _subjectFutures.putIfAbsent(
        categoryId,
        () => context.read<MaterialProvider>().subjects(categoryId),
      );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _dark ? AppColors.darkBg : const Color(0xFFF8FAFF),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              PageHeader(title: _isMateri ? 'Materi' : 'Kuis', showBack: !context.isDesktop),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchField(),
                    const SizedBox(height: 12),
                    AsyncView<List<CategoryModel>>(
                      future: _future,
                      onRetry: () => setState(_load),
                      isEmpty: (items) => items.isEmpty,
                      emptyMessage: 'Belum ada kategori yang dipublikasikan.',
                      builder: (context, categories) {
                        final sel = _selected.clamp(0, categories.length - 1).toInt();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _categoryGrid(categories, sel),
                            const SizedBox(height: 10),
                            _tabs(categories, sel),
                            const SizedBox(height: 10),
                            _subjectList(categories[sel]),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField() => TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        style: TextStyle(fontSize: 14, color: _dark ? Colors.white : _navy),
        decoration: InputDecoration(
          hintText: _isMateri ? 'Cari materi...' : 'Cari kuis...',
          hintStyle: const TextStyle(fontSize: 14, color: _muted),
          prefixIcon: Icon(Icons.search_rounded, color: _dark ? Colors.white70 : _navy, size: 22),
          filled: true,
          fillColor: _dark ? AppColors.darkSurface : const Color(0xFFEEF3FF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
      );

  Widget _categoryGrid(List<CategoryModel> categories, int sel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 88,
      ),
      itemBuilder: (context, i) {
        final c = categories[i];
        final selected = i == sel;
        return Material(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _selected = i),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected ? _blue : _border, width: selected ? 2 : 1.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CategoryIcon(name: c.name, size: 34),
                  const SizedBox(height: 4),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _dark ? Colors.white : _navy,
                    ),
                  ),
                  Text(
                    '${c.materialsTotal} materi',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: _dark ? Colors.white70 : _muted),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabs(List<CategoryModel> categories, int sel) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border, width: 1.5))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < categories.length; i++)
              InkWell(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: i == sel ? _blue : Colors.transparent, width: 2.5),
                    ),
                  ),
                  child: Text(
                    categories[i].name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: i == sel ? _blue : (_dark ? Colors.white60 : _muted),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _subjectList(CategoryModel category) {
    return AsyncView<List<SubjectModel>>(
      key: ValueKey(category.id),
      future: _subjectsOf(category.id),
      onRetry: () => setState(() => _subjectFutures.remove(category.id)),
      isEmpty: (d) => d.isEmpty,
      emptyMessage: 'Belum ada bidang di kategori ini.',
      builder: (context, subjects) {
        final shown = <int>[
          for (var i = 0; i < subjects.length; i++)
            if (subjects[i].name.toLowerCase().contains(_query.toLowerCase())) i,
        ];
        if (shown.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: Text('Bidang tidak ditemukan.')),
          );
        }
        return Column(
          children: [
            for (final i in shown) ...[
              _subjectTile(subjects[i], i + 1),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  Widget _subjectTile(SubjectModel s, int number) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => pushScreen(
          context,
          _isMateri
              ? MaterialListScreen(subject: s, mode: widget.mode)
              : ModuleListScreen(subject: s),
        ),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border, width: 1.2),
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
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _dark ? Colors.white70 : _navy, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}