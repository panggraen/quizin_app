import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/features/quiz/quiz_play_screen.dart';
import 'package:quizin_app/models/quiz_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/providers/quiz_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/module_map.dart';
import 'package:quizin_app/widgets/page_header.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

/// Langkah 3 alur kuis: jalur 10 modul kuis sebuah bidang.
/// Ketuk node: terkunci -> pesan; selain itu -> langsung mulai kuis modul itu.
class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key, required this.subject, this.isTab = false});

  final SubjectModel subject;

  /// true = dipakai sebagai tab Kuis (tanpa tombol kembali di layar lebar).
  final bool isTab;

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  late Future<List<QuizModuleModel>> _future;
  final ScrollController _scroll = ScrollController();
  bool _starting = false;
  bool _positioned = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _load() => _future = context.read<QuizProvider>().modules(widget.subject.id);

  /// Gulir sekali ke modul yang sedang aktif (modul 1 ada di paling bawah).
  void _scrollToCurrent(int idx, int n) {
    if (_positioned) return;
    _positioned = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final target = ModuleMap.centerY(idx, n) - _scroll.position.viewportDimension / 2;
      _scroll.jumpTo(target.clamp(0.0, _scroll.position.maxScrollExtent));
    });
  }

  Future<void> _start(QuizModuleModel module) async {
    if (_starting) return;
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

  void _onSelect(QuizModuleModel m) {
    if (m.isLocked) {
      showMessage(context, 'Modul ${m.moduleNumber} terkunci. Selesaikan modul sebelumnya dulu.');
      return;
    }
    _confirmStart(m);
  }

  Future<void> _confirmStart(QuizModuleModel m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _StartQuizDialog(subjectName: widget.subject.name, module: m),
    );
    if (ok == true && mounted) await _start(m);
  }

  Widget _banner() {
    return Container(
      height: 88,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A7BFF), Color(0xFF2B93FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -46,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 96, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Selesaikan setiap kuis\ndan kumpulkan bintang!',
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.3, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 12,
            bottom: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.assignment_rounded, size: 60, color: Colors.white),
                Positioned(
                  right: -10,
                  bottom: -2,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: const Icon(Icons.edit_rounded, size: 28, color: Color(0xFFFFC531)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return ScreenScaffold(
      padding: EdgeInsets.zero,
      child: Container(
        color: dark ? AppColors.darkBg : const Color(0xFFF8FBFF),
        child: Column(
          children: [
            PageHeader(
              title: 'Kuis ${widget.subject.name}',
              showBack: !(widget.isTab && context.isDesktop),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
              child: _banner(),
            ),
            Expanded(
              child: AsyncView<List<QuizModuleModel>>(
                future: _future,
                onRetry: () => setState(_load),
                isEmpty: (d) => d.isEmpty,
                emptyMessage: 'Belum ada modul kuis untuk bidang ini.',
                builder: (context, data) {
                  final modules = [...data]..sort((a, b) => a.moduleNumber.compareTo(b.moduleNumber));
                  var current = modules.indexWhere((m) => !m.isLocked && !m.isCompleted);
                  if (current < 0) current = modules.length - 1;
                  _scrollToCurrent(current, modules.length);
                  return SingleChildScrollView(
                    controller: _scroll,
                    child: ModuleMap(modules: modules, onSelect: _onSelect),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// Konfirmasi sebelum kuis dimulai.
class _StartQuizDialog extends StatelessWidget {
  const _StartQuizDialog({required this.subjectName, required this.module});

  final String subjectName;
  final QuizModuleModel module;

  static const Color _blue = Color(0xFF0A7BFF);

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final repeat = module.isCompleted;
    return Dialog(
      backgroundColor: dark ? AppColors.darkSurface : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 120,
                    height: 104,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE3EEFF),
                          ),
                          child: const Icon(Icons.sports_esports_rounded, size: 52, color: _blue),
                        ),
                        Positioned(right: 2, top: 0, child: _spark(-0.9)),
                        Positioned(right: -6, top: 14, child: _spark(-0.35)),
                        Positioned(right: -8, top: 32, child: _spark(0.1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(repeat ? 'Ulangi Kuis?' : 'Mulai Kuis?',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF243B7A) : const Color(0xFFE3EEFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Kuis $subjectName \u2014 Level ${module.moduleNumber}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent(context))),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    repeat
                        ? 'Nilai terbaikmu ${module.bestScore ?? 0}%. Siap mencoba lagi?'
                        : 'Sudah siap menguji pengetahuanmu?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Mulai Sekarang',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue, width: 1.5),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Nanti Saja',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: 'Tutup',
                onPressed: () => Navigator.of(context).pop(false),
                icon: Icon(Icons.close_rounded, color: AppColors.accent(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spark(double angle) => Transform.rotate(
        angle: angle,
        child: Container(
          width: 5,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
}
