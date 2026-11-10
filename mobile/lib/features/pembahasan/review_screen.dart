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
        builder: (context, items) => ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final it = items[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: it.isCorrect ? AppColors.green : AppColors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${it.number}. ${it.question}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
                  const SizedBox(height: 6),
                  Text('Jawabanmu: ${it.userAnswer}',
                      style: TextStyle(
                          fontSize: 13, color: it.isCorrect ? AppColors.green : AppColors.red)),
                  if (!it.isCorrect)
                    Text('Jawaban benar: ${it.correctAnswer}',
                        style: const TextStyle(fontSize: 13, color: AppColors.green)),
                  const SizedBox(height: 4),
                  Text('Penjelasan: ${it.explanation}',
                      style: TextStyle(fontSize: 12, color: AppColors.text(context))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
