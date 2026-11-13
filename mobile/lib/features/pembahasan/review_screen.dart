import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/quiz_model.dart';
import 'package:quizin_app/providers/quiz_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';

/// Pembahasan: hanya bisa dibuka setelah kuis selesai (server menolak jika belum).
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.attemptId});

  final int attemptId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Future<List<ReviewItemModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<QuizProvider>().review(widget.attemptId);

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Pembahasan',
      child: AsyncView<List<ReviewItemModel>>(
        future: _future,
        onRetry: () => setState(_load),
        isEmpty: (d) => d.isEmpty,
        builder: (context, items) {
          final correct = items.where((e) => e.isCorrect).length;
          return ListView.separated(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: items.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              if (i == 0) return _Summary(correct: correct, total: items.length);
              return _ReviewCard(item: items[i - 1]);
            },
          );
        },
      ),
    );
  }
}

/// Ringkasan di atas daftar: berapa soal yang benar.
class _Summary extends StatelessWidget {
  const _Summary({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_outlined, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$correct dari $total soal benar',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item});

  final ReviewItemModel item;

  @override
  Widget build(BuildContext context) {
    final accent = item.isCorrect ? AppColors.green : AppColors.red;
    final text = AppColors.text(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.isCorrect ? Icons.check_circle : Icons.cancel, color: accent, size: 16),
                    const SizedBox(width: 4),
                    Text(item.isCorrect ? 'Benar' : 'Salah',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: accent)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('Soal ${item.number}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.question,
              style: TextStyle(fontSize: 15, height: 1.4, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 12),
          if (item.options.isEmpty)
            _plainAnswers(context)
          else
            for (final o in item.options) _OptionReview(option: o),
          if (item.explanation.isNotEmpty && item.options.isEmpty) ...[
            const SizedBox(height: 8),
            Text('Penjelasan: ${item.explanation}',
                style: TextStyle(fontSize: 13, height: 1.5, color: text)),
          ],
        ],
      ),
    );
  }

  /// Cadangan jika server belum mengirim daftar pilihan.
  Widget _plainAnswers(BuildContext context) {
    final accent = item.isCorrect ? AppColors.green : AppColors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jawabanmu: ${item.userAnswer}', style: TextStyle(fontSize: 13, color: accent)),
        if (!item.isCorrect)
          Text('Jawaban benar: ${item.correctAnswer}',
              style: const TextStyle(fontSize: 13, color: AppColors.green)),
      ],
    );
  }
}

/// Satu pilihan jawaban: diberi warna (hijau = benar, merah = pilihanmu yang
/// salah), lalu alasan kenapa pilihan itu benar atau salah.
class _OptionReview extends StatelessWidget {
  const _OptionReview({required this.option});

  final ReviewOptionModel option;

  @override
  Widget build(BuildContext context) {
    final wrongChosen = option.isChosen && !option.isCorrect;
    final highlight = option.isCorrect || wrongChosen;
    final color = option.isCorrect ? AppColors.green : (wrongChosen ? AppColors.red : AppColors.muted);
    final text = AppColors.text(context);

    String? tag;
    if (option.isCorrect && option.isChosen) {
      tag = 'Jawabanmu (benar)';
    } else if (option.isCorrect) {
      tag = 'Jawaban benar';
    } else if (wrongChosen) {
      tag = 'Jawabanmu (salah)';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: highlight ? color.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: highlight ? color : Colors.black12, width: highlight ? 1.4 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${option.label}.',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: highlight ? color : text)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(option.text,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                          color: text)),
                ),
                if (option.isCorrect) const Icon(Icons.check_circle, color: AppColors.green, size: 18),
                if (wrongChosen) const Icon(Icons.cancel, color: AppColors.red, size: 18),
              ],
            ),
            if (tag != null) ...[
              const SizedBox(height: 2),
              Text(tag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
            if (option.reason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(option.reason,
                  style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: highlight ? text : AppColors.muted)),
            ],
          ],
        ),
      ),
    );
  }
}