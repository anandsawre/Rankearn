import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import '../models/category_model.dart';
import '../models/exam_category_model.dart';
import '../supabase/supabase_config.dart';

/// Test Series & Question Bank Repository
class TestsRepository {
  final SupabaseClient? _explicitClient;

  TestsRepository({SupabaseClient? client}) : _explicitClient = client;

  SupabaseClient? get _client => _explicitClient ?? SupabaseConfig.clientSafe;

  /// Fetch All Categories created by Admin (optionally filtered by examCategoryId)
  Future<Result<List<CategoryModel>>> getCategories({
    String? examCategoryId,
    bool onlyActive = true,
  }) async {
    final client = _client;
    if (client == null) {
      return const Success([]);
    }
    try {
      var query = client.from('categories').select();
      if (onlyActive) {
        query = query.neq('status', 'archived');
      }
      if (examCategoryId != null && examCategoryId.isNotEmpty && examCategoryId != 'all') {
        query = query.eq('exam_category_id', examCategoryId);
      }
      final data = await query.order('display_order', ascending: true);
      final categories = (data as List)
          .map((m) => CategoryModel.fromMap(m as Map<String, dynamic>))
          .toList();
      return Success(categories);
    } catch (e) {
      return Failure('Error fetching categories: $e', e);
    }
  }

  /// Realtime stream of categories for live updates when Admin creates or updates categories
  Stream<List<CategoryModel>> streamCategories({bool onlyActive = true}) {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('categories')
          .stream(primaryKey: ['id'])
          .order('display_order', ascending: true)
          .map((rows) {
            final list = rows.map((m) => CategoryModel.fromMap(m)).toList();
            if (onlyActive) {
              return list.where((c) => c.status != 'archived').toList();
            }
            return list;
          });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Fetch All Exam Categories as Typed Models with test counts
  Future<Result<List<ExamCategoryModel>>> getExamCategoryList() async {
    final client = _client;
    if (client == null) {
      return const Success([]);
    }
    try {
      final data = await client
          .from('exam_categories')
          .select()
          .eq('is_published', true)
          .order('display_order', ascending: true);

      // Fetch test counts grouped by exam_category_id and test_mode
      final testsData = await client
          .from('tests')
          .select('exam_category_id, test_mode')
          .eq('status', 'published');

      final mockCounts = <String, int>{};
      final sectionalCounts = <String, int>{};
      final totalCounts = <String, int>{};

      for (final t in (testsData as List)) {
        final examId = t['exam_category_id']?.toString() ?? '';
        final mode = t['test_mode']?.toString() ?? 'mock';
        if (examId.isNotEmpty) {
          totalCounts[examId] = (totalCounts[examId] ?? 0) + 1;
          if (mode == 'mock') {
            mockCounts[examId] = (mockCounts[examId] ?? 0) + 1;
          } else if (mode == 'sectional') {
            sectionalCounts[examId] = (sectionalCounts[examId] ?? 0) + 1;
          }
        }
      }

      final list = (data as List).map((m) {
        final id = m['id']?.toString() ?? '';
        return ExamCategoryModel.fromMap(m as Map<String, dynamic>).copyWith(
          totalTests: totalCounts[id] ?? 0,
          totalMocks: mockCounts[id] ?? 0,
          totalSectional: sectionalCounts[id] ?? 0,
        );
      }).toList();

      return Success(list);
    } catch (e) {
      return Failure('Error fetching exam categories: $e', e);
    }
  }

  /// Fetch All Exam Categories (SSC, BPSC, UPSC, etc.)
  Future<Result<List<Map<String, dynamic>>>> getExamCategories() async {
    final client = _client;
    if (client == null) {
      return const Success([]);
    }
    try {
      final data = await client
          .from('exam_categories')
          .select()
          .eq('is_published', true)
          .order('display_order', ascending: true);

      return Success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return Failure('Error fetching exam categories: $e', e);
    }
  }

  /// Fetch Tests with filtering
  Future<Result<List<TestModel>>> getTests({
    String? examCategoryId,
    String? categoryId,
    String? testMode,
    bool? isTournament,
    String? searchQuery,
  }) async {
    final client = _client;
    if (client == null) {
      return const Success([]);
    }
    try {
      var query = client.from('tests').select().eq('status', 'published');

      if (examCategoryId != null && examCategoryId.isNotEmpty && examCategoryId != 'all') {
        query = query.eq('exam_category_id', examCategoryId);
      }
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        query = query.eq('category_id', categoryId);
      }
      if (testMode != null && testMode.isNotEmpty) {
        query = query.eq('test_mode', testMode);
      }
      if (isTournament != null) {
        query = query.eq('is_tournament', isTournament);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('title', '%${searchQuery.trim()}%');
      }

      final data = await query.order('created_at', ascending: false);
      final tests = (data as List).map((m) => TestModel.fromMap(m)).toList();
      return Success(tests);
    } catch (e) {
      return Failure('Error fetching tests: $e', e);
    }
  }

  /// Fetch Questions for a Test
  Future<Result<List<QuestionModel>>> getQuestions(String testId) async {
    final client = _client;
    if (client == null) {
      return const Success([]);
    }
    try {
      final data = await client
          .from('questions')
          .select()
          .eq('test_id', testId)
          .order('question_number', ascending: true);

      final questions = (data as List).map((m) => QuestionModel.fromMap(m)).toList();
      return Success(questions);
    } catch (e) {
      return Failure('Error fetching questions: $e', e);
    }
  }

  /// Unlock Premium Test with Coins via atomic RPC
  Future<Result<int>> unlockTestWithCoins({
    required String testId,
    required String userId,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final res = await client.rpc('unlock_test_with_coins', params: {
        'p_test_id': testId,
        'p_user_id': userId,
      });

      final newBalance = (res['new_balance'] as num).toInt();
      return Success(newBalance);
    } catch (e) {
      return Failure('Failed to unlock test: $e', e);
    }
  }
}
