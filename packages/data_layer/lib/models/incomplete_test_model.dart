import 'test_model.dart';
import 'question_model.dart';

/// Represents a test that a user started and left incomplete / in-progress.
/// Used specifically for the "Continue Learning" section on the Dashboard.
class IncompleteTestModel {
  final String testId;
  final TestModel test;
  final List<QuestionModel> questions;
  final Map<String, int> userAnswers;
  final int secondsRemaining;
  final int currentIndex;
  final int answeredCount;
  final int totalQuestions;
  final double progress; // 0.0 to 1.0
  final DateTime lastUpdated;

  const IncompleteTestModel({
    required this.testId,
    required this.test,
    required this.questions,
    required this.userAnswers,
    required this.secondsRemaining,
    required this.currentIndex,
    required this.answeredCount,
    required this.totalQuestions,
    required this.progress,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'test_id': testId,
      'test': test.toMap(),
      'questions': questions.map((q) => q.toMap()).toList(),
      'user_answers': userAnswers,
      'seconds_remaining': secondsRemaining,
      'current_index': currentIndex,
      'answered_count': answeredCount,
      'total_questions': totalQuestions,
      'progress': progress,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory IncompleteTestModel.fromMap(Map<String, dynamic> map) {
    return IncompleteTestModel(
      testId: map['test_id']?.toString() ?? '',
      test: TestModel.fromMap(
        Map<String, dynamic>.from(map['test'] as Map? ?? {}),
      ),
      questions: (map['questions'] as List? ?? [])
          .map((q) => QuestionModel.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList(),
      userAnswers: Map<String, int>.from(
        (map['user_answers'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      secondsRemaining: (map['seconds_remaining'] as num?)?.toInt() ?? 0,
      currentIndex: (map['current_index'] as num?)?.toInt() ?? 0,
      answeredCount: (map['answered_count'] as num?)?.toInt() ?? 0,
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: map['last_updated'] != null
          ? DateTime.tryParse(map['last_updated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
