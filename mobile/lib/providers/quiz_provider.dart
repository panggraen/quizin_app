import 'package:flutter/foundation.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/models/question_model.dart';
import 'package:quizin_app/models/quiz_model.dart';
import 'package:quizin_app/services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider(this._service);
  final QuizService _service;

  AttemptModel? attempt;
  int index = 0;
  int? selectedOptionId;
  AnswerResultModel? lastResult;
  AttemptResultModel? result;
  bool submitting = false;
  String? error;

  QuestionModel get currentQuestion => attempt!.questions[index];
  bool get isLast => attempt != null && index == attempt!.questions.length - 1;

  Future<List<QuizModuleModel>> modules(int subjectId) => _service.modules(subjectId);
  Future<List<ReviewItemModel>> review(int attemptId) => _service.review(attemptId);

  Future<void> start(int moduleId) async {
    attempt = await _service.startAttempt(moduleId);
    index = 0;
    selectedOptionId = null;
    lastResult = null;
    result = null;
    error = null;
    notifyListeners();
  }

  /// Kirim jawaban ke server. Jawaban terkunci setelah dikirim.
  Future<bool> answer(int optionId) async {
    if (submitting || lastResult != null || attempt == null) return false;
    submitting = true;
    selectedOptionId = optionId;
    error = null;
    notifyListeners();
    try {
      lastResult = await _service.submitAnswer(attempt!.attemptId, currentQuestion.id, optionId);
      return true;
    } catch (e) {
      selectedOptionId = null;
      error = errorMessage(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void next() {
    if (attempt == null || isLast) return;
    index++;
    selectedOptionId = null;
    lastResult = null;
    notifyListeners();
  }

  Future<bool> finish() async {
    if (attempt == null || submitting) return false;
    submitting = true;
    error = null;
    notifyListeners();
    try {
      result = await _service.finish(attempt!.attemptId);
      return true;
    } catch (e) {
      error = errorMessage(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}