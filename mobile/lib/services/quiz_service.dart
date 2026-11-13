import 'package:quizin_app/models/quiz_model.dart';

/// Kontrak: GET /api/subjects/{id}/modules, POST /api/modules/{id}/attempts,
/// POST /api/attempts/{id}/answers, POST /api/attempts/{id}/finish,
/// GET /api/attempts/{id}/review
abstract class QuizService {
  Future<List<QuizModuleModel>> modules(int subjectId);
  Future<AttemptModel> startAttempt(int moduleId);
  Future<AnswerResultModel> submitAnswer(int attemptId, int questionId, int optionId);
  Future<AttemptResultModel> finish(int attemptId);
  Future<List<ReviewItemModel>> review(int attemptId);
}