import 'package:quizin_app/models/json_utils.dart';

class MaterialModel {
  final int id;
  final int subjectId;
  final String title;
  final String content;
  final bool isCompleted;

  const MaterialModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.isCompleted,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> j) => MaterialModel(
        id: toInt(j['id']),
        subjectId: toInt(j['subject_id']),
        title: j['title'] as String? ?? '',
        content: j['content'] as String? ?? '',
        isCompleted: toBool(j['is_completed']),
      );
}

class MaterialCompletionModel {
  final int xpAwarded;
  final bool alreadyCompleted;

  const MaterialCompletionModel({required this.xpAwarded, required this.alreadyCompleted});

  factory MaterialCompletionModel.fromJson(Map<String, dynamic> j) =>
      MaterialCompletionModel(
        xpAwarded: toInt(j['xp_awarded']),
        alreadyCompleted: toBool(j['already_completed']),
      );
}
