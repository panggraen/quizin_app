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
      return const ScreenScaffold(title: 'Kuis', child: LoadingWidget());
    }
    final question = quiz.currentQuestion;
    final total = attempt.questions.length;
    final answered = quiz.lastResult != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await _confirmLeave(context);
        if (leave == true && context.mounted) Navigator.of(context).pop();
      },
      child: ScreenScaffold(
        title: 'Kuis',
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Text('Soal ${quiz.index + 1}/$total',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (quiz.index + (answered ? 1 : 0)) / total,
                minHeight: 6,
                backgroundColor: Colors.black12,
                color: AppColors.yellow,
              ),
            ),
            const SizedBox(height: 20),
            Text(question.text,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text(context))),
            const SizedBox(height: 16),
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
              Text(
                quiz.lastResult!.isCorrect
                    ? 'Benar! ${quiz.lastResult!.explanation}'
                    : 'Kurang tepat. ${quiz.lastResult!.explanation}',
                style: TextStyle(
                  fontSize: 13,
                  color: quiz.lastResult!.isCorrect ? AppColors.green : AppColors.red,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 180,
                  child: PrimaryButton(
                    label: quiz.isLast ? 'Selesai' : 'Berikutnya',
                    loading: quiz.submitting,
                    onPressed: () => _next(context),
                  ),
                ),
              ),
            ],
          ],
        ),
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
    final isSelected = selectedId == option.id;
    final revealed = correctId != null;
    Color border = AppColors.accent(context);
    Color fill = AppColors.surface(context);
    Color text = AppColors.text(context);

    if (revealed && option.id == correctId) {
      border = AppColors.green;
      fill = AppColors.green.withValues(alpha: 0.18);
    } else if (revealed && isSelected) {
      border = AppColors.red;
      fill = AppColors.red.withValues(alpha: 0.15);
    } else if (isSelected) {
      fill = AppColors.navy;
      text = Colors.white;
    }

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: locked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.transparent,
                child: Text(option.label, style: TextStyle(fontWeight: FontWeight.w700, color: text)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(option.text, style: TextStyle(color: text))),
            ],
          ),
        ),
      ),
    );
  }
}
