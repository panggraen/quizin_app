import 'package:flutter/foundation.dart';
import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/models/material_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/services/material_service.dart';

/// Penelusuran konten tidak butuh state bersama; provider ini meneruskan ke service.
class MaterialProvider extends ChangeNotifier {
  MaterialProvider(this._service);
  final ContentService _service;

  Future<List<CategoryModel>> categories() => _service.categories();
  Future<List<SubjectModel>> subjects(int categoryId) => _service.subjects(categoryId);
  Future<List<MaterialModel>> materials(int subjectId) => _service.materials(subjectId);
  Future<MaterialModel> material(int id) => _service.material(id);
  Future<MaterialCompletionModel> complete(int id) => _service.completeMaterial(id);
}
