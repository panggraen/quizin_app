import 'package:quizin_app/models/json_utils.dart';

class OptionModel {
  final int id;
  final String label;
  final String text;

  const OptionModel({required this.id, required this.label, required this.text});

  factory OptionModel.fromJson(Map<String, dynamic> j) => OptionModel(
        id: toInt(j['id']),
        label: j['label'] as String? ?? '',
        text: j['text'] as String? ?? '',
      );
}

/// Soal dari server. Sengaja TIDAK ada field kunci jawaban.
class QuestionModel {
  final int id;
  final int number;
  final String text;
  final List<OptionModel> options;

  const QuestionModel({
    required this.id,
    required this.number,
    required this.text,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> j) => QuestionModel(
        id: toInt(j['id']),
        number: toInt(j['number']),
        text: j['text'] as String? ?? '',
        options: (j['options'] as List<dynamic>? ?? [])
            .map((o) => OptionModel.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}
