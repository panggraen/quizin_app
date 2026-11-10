import 'package:quizin_app/models/json_utils.dart';

class SubjectModel {
  final int id;
  final int categoryId;
  final String name;
  final int materialsDone;
  final int materialsTotal;

  const SubjectModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.materialsDone,
    required this.materialsTotal,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> j) => SubjectModel(
        id: toInt(j['id']),
        categoryId: toInt(j['category_id']),
        name: j['name'] as String? ?? '',
        materialsDone: toInt(j['materials_done']),
        materialsTotal: toInt(j['materials_total']),
      );
}
