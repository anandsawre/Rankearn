import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/incomplete_test_model.dart';

/// Repository managing in-progress / incomplete practice tests saved locally on the device.
/// Only regular practice tests (mock, sectional, chapter, daily, previous-year) can be saved.
/// Live contests, live quizzes, and tournaments are strictly excluded.
class IncompleteTestsRepository {
  static const String _storageKey = 'rankearn_incomplete_tests_v1';

  /// Save or update an incomplete practice test session.
  Future<void> saveProgress(IncompleteTestModel incomplete) async {
    final t = incomplete.test;
    // Strict Guard: Never save upcoming/active live tests or tournaments
    if (t.isTournament ||
        t.testMode == 'live' ||
        t.testMode == 'tournament' ||
        t.isLive ||
        t.isUpcoming) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getAllIncompleteTests();
      all.removeWhere((item) => item.testId == incomplete.testId);
      all.insert(0, incomplete);

      // Keep only top 10 most recent incomplete tests
      final capped = all.take(10).toList();
      final jsonList = capped.map((e) => jsonEncode(e.toMap())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (_) {}
  }

  /// Remove an in-progress test when submitted, finished, or dismissed.
  Future<void> clearProgress(String testId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getAllIncompleteTests();
      all.removeWhere((item) => item.testId == testId);
      final jsonList = all.map((e) => jsonEncode(e.toMap())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (_) {}
  }

  /// Retrieve the most recent incomplete practice test.
  /// Returns null if user has not left any test in progress.
  Future<IncompleteTestModel?> getLatestIncompleteTest() async {
    final all = await getAllIncompleteTests();
    if (all.isEmpty) return null;
    return all.first;
  }

  /// Retrieve all incomplete practice tests sorted by latest updated.
  Future<List<IncompleteTestModel>> getAllIncompleteTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey);
      if (list == null || list.isEmpty) return [];

      final results = <IncompleteTestModel>[];
      for (final str in list) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          final item = IncompleteTestModel.fromMap(map);
          final t = item.test;
          // Filter out any live/tournament tests
          if (t.isTournament ||
              t.testMode == 'live' ||
              t.testMode == 'tournament' ||
              t.isLive ||
              t.isUpcoming) {
            continue;
          }
          results.add(item);
        } catch (_) {}
      }
      return results;
    } catch (_) {
      return [];
    }
  }
}
