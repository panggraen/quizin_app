import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/quiz/quiz_result_screen.dart';
import 'package:quizin_app/models/question_model.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/providers/quiz_provider.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/state_widgets.dart';

class QuizPlayScreen extends StatelessWidget {
  const QuizPlayScreen({super.key});

  Future<bool?> _confirmLeave(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari kuis?'),
        content: const Text('Kuis dianggap belum selesai, tanpa hadiah, dan akan dimulai dari awal.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Lanjut kuis')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Keluar')),
        ],
      ),
    );
  }

  Future<void> _answer(BuildContext context, int optionId) async {
    final quiz = context.read<QuizProvider>();
    final ok = await quiz.answer(optionId);
    if (!ok && context.mounted && quiz.error != null) showMessage(context, quiz.error!);
  }

  Future<void> _next(BuildContext context) async {
    final quiz = context.read<QuizProvider>();
    if (!quiz.isLast) {
      quiz.next();
      return;
    }
    final ok = await quiz.finish();
    if (!context.mounted) return;
    if (!ok) {
      showMessage(context, quiz.error ?? 'Gagal menyelesaikan kuis.');
      return;
    }
    context.read<ProfileProvider>().load();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const QuizResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final attempt = quiz.attempt;
    if (attempt == null) {
      return const ScreenScaffold(
        title: 'Kuis',
        showTopNav: false,
        child: LoadingWidget(),
      );
    }
    final question = quiz.currentQuestion;
    final total = attempt.questions.length;
    final answered = quiz.lastResult != null;
    final dark = AppColors.isDark(context);
    final topInset = MediaQuery.paddingOf(context).top;

    Future<void> leave() async {
      final ok = await _confirmLeave(context);
      if (ok == true && context.mounted) Navigator.of(context).pop();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Scaffold(
        backgroundColor: dark ? AppColors.darkBg : const Color(0xFFF3F7FF),
        body: Stack(
          children: [
            // Latar biru bagian atas (warna sama dengan header Home).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset + 230,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.headerTop, AppColors.primary],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _TopBar(number: quiz.index + 1, total: total, onBack: leave),
                      const SizedBox(height: 14),
                      _Segments(outcomes: quiz.outcomes, current: quiz.index),
                      const SizedBox(height: 18),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(color: Color(0x1A0B1F5B), blurRadius: 12, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(question.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    height: 1.35,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent(context))),
                            const SizedBox(height: 20),
                            for (final opt in question.options)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _OptionTile(
                                  option: opt,
                                  selectedId: quiz.selectedOptionId,
                                  correctId: quiz.lastResult?.correctOptionId,
                                  locked: answered || quiz.submitting,
                                  onTap: () => _answer(context, opt.id),
                                ),
                              ),
                            if (answered) ...[
                              const SizedBox(height: 2),
                              _FeedbackCard(
                                isCorrect: quiz.lastResult!.isCorrect,
                                explanation: quiz.lastResult!.explanation,
                                chosenExplanation: quiz.lastResult!.chosenExplanation,
                              ),
                            ],
                            const SizedBox(height: 14),
                            PrimaryButton(
                              label: quiz.isLast ? 'Selesai' : 'Selanjutnya',
                              loading: quiz.submitting && answered,
                              onPressed: answered ? () => _next(context) : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris atas: tombol kembali, "Pertanyaan N", dan penanda N/total.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.number, required this.total, required this.onBack});

  final int number;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onBack,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text('Pertanyaan $number',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white54, width: 1.5),
          ),
          child: Text('$number/$total',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    );
  }
}

/// Progress per soal: hijau = benar, merah = salah, putih = belum dijawab.
class _Segments extends StatelessWidget {
  const _Segments({required this.outcomes, required this.current});

  final List<bool?> outcomes;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < outcomes.length; i++)
          Expanded(
            child: Container(
              height: 7,
              margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: switch (outcomes[i]) {
                  true => const Color(0xFF2EBD6B),
                  false => const Color(0xFFEF3B34),
                  null => Colors.white.withValues(alpha: i == current ? 0.95 : 0.35),
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Pembahasan singkat setelah menjawab. Warna benar/salah sudah tampak pada
/// pilihan jawaban, jadi di sini hanya alasannya.
class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.isCorrect,
    required this.explanation,
    required this.chosenExplanation,
  });

  final bool isCorrect;
  final String explanation;
  final String chosenExplanation;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect ? AppColors.green : AppColors.red;
    final textColor = AppColors.text(context);

    Widget section(String title, String body, Color color) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(body, style: TextStyle(fontSize: 13, height: 1.45, color: textColor)),
            ],
          ),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.08), AppColors.surface(context)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isCorrect ? 'Jawabanmu benar!' : 'Jawabanmu kurang tepat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: accent)),
          const SizedBox(height: 8),
          if (!isCorrect && chosenExplanation.isNotEmpty)
            section('Kenapa jawabanmu salah', chosenExplanation, AppColors.red),
          section(
            isCorrect ? 'Kenapa jawabanmu benar' : 'Kenapa ini jawaban yang benar',
            explanation,
            AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selectedId,
    required this.correctId,
    required this.locked,
    required this.onTap,
  });

  final OptionModel option;
  final int? selectedId;
  final int? correctId;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final isSelected = selectedId == option.id;
    final revealed = correctId != null;
    final isCorrect = revealed && option.id == correctId;
    final isWrong = revealed && isSelected && !isCorrect;

    Color border = dark ? const Color(0xFF3A4A7A) : const Color(0xFFD5DCEB);
    Color fill = AppColors.surface(context);
    if (isCorrect) {
      border = AppColors.green;
      fill = const Color(0xFFE3F8E9);
    } else if (isWrong) {
      border = const Color(0xFFF08A86);
      fill = const Color(0xFFFFE6E5);
    } else if (isSelected) {
      border = AppColors.primary;
      fill = const Color(0xFFEAF2FF);
    }
    final textColor = (isCorrect || isWrong) ? AppColors.navy : AppColors.text(context);

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: locked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Expanded(child: Text(option.text, style: TextStyle(fontSize: 15, color: textColor))),
              if (isCorrect) _badge(Icons.check_rounded, AppColors.green),
              if (isWrong) _badge(Icons.close_rounded, AppColors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, Color color) => Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: Colors.white),
      );
}
