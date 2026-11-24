import 'package:quizin_app/models/json_utils.dart';

class CategoryModel {
  final int id;
  final String name;
  final int materialsDone;
  final int materialsTotal;

  /// Jumlah subjek (subkategori) di kategori ini. Opsional: kalau backend
  /// belum mengirim `subjects_total`, nilainya null.
  final int? subjectsTotal;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.materialsDone,
    required this.materialsTotal,
    this.subjectsTotal,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: toInt(j['id']),
        name: j['name'] as String? ?? '',
        materialsDone: toInt(j['materials_done']),
        materialsTotal: toInt(j['materials_total']),
        subjectsTotal:
            j['subjects_total'] == null ? null : toInt(j['subjects_total']),
      );
}