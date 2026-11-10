import 'package:quizin_app/models/json_utils.dart';

class CategoryModel {
  final int id;
  final String name;
  final int materialsDone;
  final int materialsTotal;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.materialsDone,
    required this.materialsTotal,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: toInt(j['id']),
        name: j['name'] as String? ?? '',
        materialsDone: toInt(j['materials_done']),
        materialsTotal: toInt(j['materials_total']),
      );
}
