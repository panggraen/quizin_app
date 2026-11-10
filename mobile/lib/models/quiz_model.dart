import 'package:quizin_app/models/json_utils.dart';
import 'package:quizin_app/models/question_model.dart';

class QuizModuleModel {
  final int id;
  final int materialId;
  final int moduleNumber;
  final String title;

  /// 'available' | 'locked' | 'completed'
  final String status;
  final int? bestScore;

  const QuizModuleModel({
    required this.id,
    required this.materialId,
    required this.moduleNumber,
    required this.title,
    required this.status,
    this.bestScore,
  });

  bool get isLocked => status == 'locked';
  bool get isCompleted => status == 'completed';

  factory QuizModuleModel.fromJson(Map<String, dynamic> j) => QuizModuleModel(
        id: toInt(j['id']),
        materialId: toInt(j['material_id']),
        moduleNumber: toInt(j['module_number']),
        title: j['title'] as String? ?? '',
        status: j['status'] as String? ?? 'locked',
        bestScore: j['best_score'] == null ? null : toInt(j['best_score']),
      );
}

class AttemptModel {
  final int attemptId;
  final List<QuestionModel> questions;

  const AttemptModel({required this.attemptId, required this.questions});

  factory AttemptModel.fromJson(Map<String, dynamic> j) => AttemptModel(
        attemptId: toInt(j['attempt_id']),
        questions: (j['questions'] as List<dynamic>? ?? [])
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
}

class AnswerResultModel {
  final bool isCorrect;
  final int correctOptionId;
  final String explanation;

  const AnswerResultModel({
    required this.isCorrect,
    required this.correctOptionId,
    required this.explanation,
  });

  factory AnswerResultModel.fromJson(Map<String, dynamic> j) => AnswerResultModel(
        isCorrect: toBool(j['is_correct']),
        correctOptionId: toInt(j['correct_option_id']),
        explanation: j['explanation'] as String? ?? '',
      );
}

class AttemptResultModel {
  final int attemptId;
  final int correctCount;
  final int totalQuestions;
  final int scorePercent;
  final int xpAwarded;
  final int coinsAwarded;

  /// false jika modul ini sudah pernah diselesaikan (tidak ada hadiah lagi).
  final bool rewardGiven;

  const AttemptResultModel({
    required this.attemptId,
    required this.correctCount,
    required this.totalQuestions,
    required this.scorePercent,
    required this.xpAwarded,
    required this.coinsAwarded,
    required this.rewardGiven,
  });

  factory AttemptResultModel.fromJson(Map<String, dynamic> j) => AttemptResultModel(
        attemptId: toInt(j['attempt_id']),
        correctCount: toInt(j['correct_count']),
        totalQuestions: toInt(j['total_questions']),
        scorePercent: toInt(j['score_percent']),
        xpAwarded: toInt(j['xp_awarded']),
        coinsAwarded: toInt(j['coins_awarded']),
        rewardGiven: toBool(j['reward_given']),
      );
}

class ReviewItemModel {
  final int number;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  const ReviewItemModel({
    required this.number,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  factory ReviewItemModel.fromJson(Map<String, dynamic> j) => ReviewItemModel(
        number: toInt(j['number']),
        question: j['question'] as String? ?? '',
        userAnswer: j['user_answer'] as String? ?? '',
        correctAnswer: j['correct_answer'] as String? ?? '',
        isCorrect: toBool(j['is_correct']),
        explanation: j['explanation'] as String? ?? '',
      );
}
