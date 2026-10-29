import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_core/shared_core.dart';
import '../models/exam_category_model.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../models/topic_model.dart';
import '../supabase/supabase_config.dart';

/// Centralized Categories Repository managing the 4-level hierarchy:
/// Level 1: Exam Categories (Target Exams)
/// Level 2: Categories (Main Subjects)
/// Level 3: Subcategories (Units / Sections)
/// Level 4: Topics (Chapters / Topics)
class CategoriesRepository {
  final SupabaseClient? _client;

  CategoriesRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.clientSafe;

  // ==========================================
  // LEVEL 1: TARGET EXAMS (exam_categories)
  // ==========================================

  Future<Result<List<ExamCategoryModel>>> getExamCategories() async {
    final client = _client;
    if (client == null) return const Success([]);
    try {
      final res = await client
          .from('exam_categories')
          .select()
          .order('display_order', ascending: true);

      final list = (res as List)
          .map((m) => ExamCategoryModel.fromMap(m as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure('Failed to fetch exam categories: $e', e);
    }
  }

  Future<Result<ExamCategoryModel>> upsertExamCategory(ExamCategoryModel model) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      final map = model.toMap();
      if ((map['normalized_name'] == null || (map['normalized_name'] as String).isEmpty) &&
          map['name'] != null) {
        map['normalized_name'] = (map['name'] as String).toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      }
      map['languages'] = map['languages'] ?? 'en,hi';

      await client.from('exam_categories').upsert(map);
      return Success(model);
    } catch (e) {
      return Failure('Failed to save exam category: $e', e);
    }
  }

  Future<Result<bool>> deleteExamCategory(String id) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      await client.from('exam_categories').delete().eq('id', id);
      return const Success(true);
    } catch (e) {
      return Failure('Failed to delete exam category: $e', e);
    }
  }

  // ==========================================
  // LEVEL 2: MAIN CATEGORIES / SUBJECTS (categories)
  // ==========================================

  Future<Result<List<CategoryModel>>> getCategories({String? examCategoryId}) async {
    final client = _client;
    if (client == null) return const Success([]);
    try {
      var query = client.from('categories').select();
      if (examCategoryId != null && examCategoryId.isNotEmpty) {
        query = query.eq('exam_category_id', examCategoryId);
      }
      final res = await query.order('display_order', ascending: true);

      final list = (res as List)
          .map((m) => CategoryModel.fromMap(m as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure('Failed to fetch categories: $e', e);
    }
  }

  Future<Result<CategoryModel>> upsertCategory(CategoryModel model) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      final map = model.toMap();
      await client.from('categories').upsert(map);
      return Success(model);
    } catch (e) {
      return Failure('Failed to save category: $e', e);
    }
  }

  Future<Result<bool>> deleteCategory(String id) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      await client.from('categories').delete().eq('id', id);
      return const Success(true);
    } catch (e) {
      return Failure('Failed to delete category: $e', e);
    }
  }

  // ==========================================
  // LEVEL 3: SUBCATEGORIES / UNITS (subcategories)
  // ==========================================

  Future<Result<List<SubcategoryModel>>> getSubcategories({String? categoryId}) async {
    final client = _client;
    if (client == null) return const Success([]);
    try {
      var query = client.from('subcategories').select();
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      final res = await query.order('display_order', ascending: true);

      final list = (res as List)
          .map((m) => SubcategoryModel.fromMap(m as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure('Failed to fetch subcategories: $e', e);
    }
  }

  Future<Result<SubcategoryModel>> upsertSubcategory(SubcategoryModel model) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      final map = model.toMap();
      await client.from('subcategories').upsert(map);
      return Success(model);
    } catch (e) {
      return Failure('Failed to save subcategory: $e', e);
    }
  }

  Future<Result<bool>> deleteSubcategory(String id) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      await client.from('subcategories').delete().eq('id', id);
      return const Success(true);
    } catch (e) {
      return Failure('Failed to delete subcategory: $e', e);
    }
  }

  // ==========================================
  // LEVEL 4: TOPICS / CHAPTERS (topics)
  // ==========================================

  Future<Result<List<TopicModel>>> getTopics({String? subcategoryId, String? categoryId}) async {
    final client = _client;
    if (client == null) return const Success([]);
    try {
      var query = client.from('topics').select();
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        query = query.eq('subcategory_id', subcategoryId);
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      final res = await query.order('display_order', ascending: true);

      final list = (res as List)
          .map((m) => TopicModel.fromMap(m as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure('Failed to fetch topics: $e', e);
    }
  }

  Future<Result<TopicModel>> upsertTopic(TopicModel model) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      final map = model.toMap();
      await client.from('topics').upsert(map);
      return Success(model);
    } catch (e) {
      return Failure('Failed to save topic: $e', e);
    }
  }

  Future<Result<bool>> deleteTopic(String id) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      await client.from('topics').delete().eq('id', id);
      return const Success(true);
    } catch (e) {
      return Failure('Failed to delete topic: $e', e);
    }
  }
}

