/// Attempt Scoring Metrics
class AttemptMetrics {
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int skipped;
  final double score;
  final double accuracy;

  const AttemptMetrics({
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.score,
    required this.accuracy,
  });

  Map<String, dynamic> toMap() => {
        'totalQuestions': totalQuestions,
        'correct': correct,
        'wrong': wrong,
        'skipped': skipped,
        'score': score,
        'accuracy': accuracy,
      };
}

/// Rankearn Pure Scoring Engine
/// Direct parity with `attemptStats.ts` and `worker/cloudflare_worker.js:847-869`.
class ScoringEngine {
  ScoringEngine._();

  static AttemptMetrics compute({
    required Map<String, int?> userAnswers,
    required Map<String, int> correctAnswers,
    required double negativeMarking,
  }) {
    int correct = 0;
    int wrong = 0;
    int skipped = 0;

    for (final entry in correctAnswers.entries) {
      final qId = entry.key;
      final expected = entry.value;
      final selected = userAnswers[qId];

      if (selected == null) {
        skipped++;
      } else if (selected == expected) {
        correct++;
      } else {
        wrong++;
      }
    }

    final rawScore = (correct * 1.0) - (wrong * negativeMarking);
    final score = double.parse(rawScore.toStringAsFixed(2));

    final attempted = correct + wrong;
    final rawAccuracy = attempted > 0 ? (correct / attempted) * 100.0 : 0.0;
    final accuracy = double.parse(rawAccuracy.toStringAsFixed(2));

    return AttemptMetrics(
      totalQuestions: correctAnswers.length,
      correct: correct,
      wrong: wrong,
      skipped: skipped,
      score: score,
      accuracy: accuracy,
    );
  }
}
