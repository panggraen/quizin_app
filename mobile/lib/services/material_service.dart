import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/models/material_model.dart';
import 'package:quizin_app/models/subject_model.dart';

/// Kontrak: GET /api/categories, /api/categories/{id}/subjects,
/// /api/subjects/{id}/materials, /api/materials/{id}, POST /api/materials/{id}/complete
abstract class ContentService {
  Future<List<CategoryModel>> categories();
  Future<List<SubjectModel>> subjects(int categoryId);
  Future<List<MaterialModel>> materials(int subjectId);
  Future<MaterialModel> material(int materialId);
  Future<MaterialCompletionModel> completeMaterial(int materialId);
}
