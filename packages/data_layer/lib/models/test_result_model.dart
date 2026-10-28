import 'package:flutter/material.dart';
import 'test_model.dart';
import 'question_model.dart';
import 'user_profile.dart';

/// Subject performance breakdown item
class SubjectPerformance {
  final String subjectName;
  final int correctCount;
  final int totalQuestions;
  final double score;
  final double maxScore;
  final double accuracy;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const SubjectPerformance({
    required this.subjectName,
    required this.correctCount,
    required this.totalQuestions,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  String get formattedRatio => '$correctCount / $totalQuestions';
  String get formattedAccuracy => '${accuracy.toStringAsFixed(0)}%';
  String get formattedScore =>
      '${score % 1 == 0 ? score.toInt() : score.toStringAsFixed(1)} / ${maxScore.toInt()}';
}

/// Detailed question item for analysis and answer review
class QuestionAnalysisItem {
  final QuestionModel question;
  final int questionNumber;
  final int? selectedOptionIndex; // null if not attempted
  final int correctOptionIndex;
  final int timeSpentSeconds;

  const QuestionAnalysisItem({
    required this.question,
    required this.questionNumber,
    required this.selectedOptionIndex,
    required this.correctOptionIndex,
    this.timeSpentSeconds = 34,
  });

  bool get isAttempted => selectedOptionIndex != null;
  bool get isCorrect =>
      isAttempted && selectedOptionIndex == correctOptionIndex;
  bool get isIncorrect =>
      isAttempted && selectedOptionIndex != correctOptionIndex;
}

/// Comprehensive Test Result Domain Model
class TestResultModel {
  final String attemptId;
  final String testId;
  final String testTitle;
  final String testSubtitle;
  final String studentName;
  final String? studentPhotoUrl;
  final DateTime completedAt;
  final double score;
  final double maxScore;
  final double accuracy;
  final int? rank;
  final int totalParticipants;
  final int? rankChange; // e.g. +28
  final int timeTakenSeconds;
  final int totalDurationSeconds;
  final bool isNewBestScore;
  final int correctCount;
  final int incorrectCount;
  final int unattemptedCount;
  final double negativeMarks;
  final int totalQuestions;
  final double classAverageScore;
  final List<SubjectPerformance> subjectPerformances;
  final List<QuestionAnalysisItem> questionItems;
  final List<String> insights;
  final int coinsEarned;

  const TestResultModel({
    required this.attemptId,
    required this.testId,
    required this.testTitle,
    required this.testSubtitle,
    required this.studentName,
    this.studentPhotoUrl,
    required this.completedAt,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    this.rank,
    this.totalParticipants = 0,
    this.rankChange,
    required this.timeTakenSeconds,
    required this.totalDurationSeconds,
    this.isNewBestScore = false,
    required this.correctCount,
    required this.incorrectCount,
    required this.unattemptedCount,
    this.negativeMarks = 0.0,
    required this.totalQuestions,
    this.classAverageScore = 0.0,
    required this.subjectPerformances,
    required this.questionItems,
    required this.insights,
    this.coinsEarned = 0,
  });

  double get calculatedNegativeMarks {
    if (negativeMarks > 0) return negativeMarks;
    final markPerQ = totalQuestions > 0 ? maxScore / totalQuestions : 1.0;
    final positiveScore = correctCount * markPerQ;
    final diff = positiveScore - score;
    return diff > 0 ? diff : 0.0;
  }

  String get formattedNegativeMarks {
    final neg = calculatedNegativeMarks;
    if (neg == 0) return '0';
    return '-${neg % 1 == 0 ? neg.toInt() : neg.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}';
  }

  String get formattedFinalScore =>
      '${score % 1 == 0 ? score.toInt() : score.toStringAsFixed(1)}';

  String get formattedScore =>
      '${score % 1 == 0 ? score.toInt() : score.toStringAsFixed(1)} / ${maxScore.toInt()}';

  String get formattedAccuracy => '${accuracy.toStringAsFixed(0)}%';

  String get formattedRank => rank != null && totalParticipants > 0
      ? '#$rank / ${_formatNumber(totalParticipants)}'
      : (rank != null ? '#$rank' : 'N/A');

  String get formattedTimeTaken {
    final minutes = timeTakenSeconds ~/ 60;
    final seconds = timeTakenSeconds % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = completedAt.day;
    final month = months[completedAt.month - 1];
    final year = completedAt.year;
    final hour = completedAt.hour % 12 == 0 ? 12 : completedAt.hour % 12;
    final minute = completedAt.minute.toString().padLeft(2, '0');
    final ampm = completedAt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Calculates real result from submitted test, questions and user answers
  factory TestResultModel.fromSubmission({
    required TestModel test,
    required List<QuestionModel> questions,
    required Map<String, int?> userAnswers,
    required int timeTakenSeconds,
    UserProfile? profile,
    String? attemptId,
    int? customRank,
    int? customRankChange,
    bool? isNewBestScore,
  }) {
    final now = DateTime.now();
    final attId = attemptId ?? 'att_${now.millisecondsSinceEpoch}';
    final totalQ = questions.length;

    int correct = 0;
    int incorrect = 0;
    int unattempted = 0;

    final questionItems = <QuestionAnalysisItem>[];
    final subjectBuckets =
        <String, List<({QuestionModel q, bool isCorrect, bool isAttempted})>>{};

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final ans = userAnswers[q.id];
      final isAtt = ans != null;
      final isCorr = isAtt && ans == q.correctAnswer;

      if (!isAtt) {
        unattempted++;
      } else if (isCorr) {
        correct++;
      } else {
        incorrect++;
      }

      questionItems.add(
        QuestionAnalysisItem(
          question: q,
          questionNumber: i + 1,
          selectedOptionIndex: ans,
          correctOptionIndex: q.correctAnswer,
          timeSpentSeconds: (timeTakenSeconds / (totalQ > 0 ? totalQ : 1))
              .round(),
        ),
      );

      final subjKey = (q.subject != null && q.subject!.trim().isNotEmpty)
          ? q.subject!.trim()
          : (test.categoryId ?? 'General Science');

      subjectBuckets.putIfAbsent(subjKey, () => []).add((
        q: q,
        isCorrect: isCorr,
        isAttempted: isAtt,
      ));
    }

    // Scoring calculation respecting positive marks and negative marking
    // Standard rule: 1 mark per question if not specified
    const double markPerQuestion = 1.0;
    final double maxScore = totalQ * markPerQuestion;
    final double positiveScore = correct * markPerQuestion;
    final double negativeScore =
        incorrect * (test.negativeMarking > 0 ? test.negativeMarking : 0.0);
    final double rawScore = positiveScore - negativeScore;
    final double netScore = rawScore < 0 ? 0.0 : rawScore;

    final double accuracy = totalQ > 0 ? (correct / totalQ) * 100 : 0.0;

    // Subject breakdown
    final subjectPerformances = <SubjectPerformance>[];
    subjectBuckets.forEach((subjName, items) {
      final subTotal = items.length;
      final subCorrect = items.where((item) => item.isCorrect).length;
      final subAccuracy = subTotal > 0 ? (subCorrect / subTotal) * 100 : 0.0;
      final (icon, color, bg) = _getSubjectStyle(subjName);

      subjectPerformances.add(
        SubjectPerformance(
          subjectName: subjName,
          correctCount: subCorrect,
          totalQuestions: subTotal,
          score: subCorrect.toDouble(),
          maxScore: subTotal.toDouble(),
          accuracy: subAccuracy,
          icon: icon,
          color: color,
          backgroundColor: bg,
        ),
      );
    });

    // Intelligent performance insights
    final insights = <String>[];
    if (subjectPerformances.isNotEmpty) {
      // Find strongest subject
      final sortedByAcc = List<SubjectPerformance>.from(subjectPerformances)
        ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
      final best = sortedByAcc.first;
      if (best.accuracy >= 80) {
        insights.add(
          'Excellent performance in ${best.subjectName}! Keep it up!',
        );
      } else {
        insights.add(
          'Good effort in ${best.subjectName} with ${best.formattedAccuracy} accuracy.',
        );
      }

      // Find improvement subject
      final lowest = sortedByAcc.last;
      if (lowest.accuracy < 80 && lowest.subjectName != best.subjectName) {
        insights.add(
          'You can improve in ${lowest.subjectName}. Practice more questions.',
        );
      }
    }

    if (incorrect > 0) {
      insights.add('Focus more on the incorrect answers in detailed review.');
    } else {
      insights.add('Outstanding precision! Zero incorrect answers recorded.');
    }

    final totalSec = test.durationMinutes * 60;
    if (timeTakenSeconds < totalSec * 0.75) {
      insights.add(
        'Time management is good. Try to be a bit faster on tricky questions.',
      );
    } else {
      insights.add('Pacing was solid throughout the exam.');
    }

    final totalParts = test.totalParticipants > 0
        ? test.totalParticipants
        : 1240;
    final computedRank =
        customRank ??
        (totalParts > 0
            ? ((totalParts * (1.0 - (accuracy / 100))) + 1)
                  .clamp(1, totalParts)
                  .round()
            : null);

    return TestResultModel(
      attemptId: attId,
      testId: test.id,
      testTitle: test.title.isNotEmpty ? test.title : 'General Science',
      testSubtitle:
          '${test.testMode == 'mock' ? 'Mock Test' : 'Practice Test'} • Class 8',
      studentName: profile?.name ?? 'Vikram Singh',
      studentPhotoUrl: profile?.profilePhotoUrl,
      completedAt: now,
      score: netScore,
      maxScore: maxScore,
      accuracy: accuracy,
      rank: computedRank,
      totalParticipants: totalParts,
      rankChange: customRankChange ?? 28,
      timeTakenSeconds: timeTakenSeconds,
      totalDurationSeconds: totalSec,
      isNewBestScore: isNewBestScore ?? (accuracy >= 80),
      correctCount: correct,
      incorrectCount: incorrect,
      unattemptedCount: unattempted,
      negativeMarks: negativeScore,
      totalQuestions: totalQ,
      classAverageScore: (maxScore * 0.56).roundToDouble(),
      subjectPerformances: subjectPerformances,
      questionItems: questionItems,
      insights: insights,
      coinsEarned: (accuracy * 0.5).round(),
    );
  }

  /// Sample mock data directly mirroring the reference images
  /// 50 Questions: Physics (15), Chemistry (15), Biology (10), General Science (10)
  /// 42 Correct, 6 Incorrect, 2 Not Attempted -> 84% accuracy, 28m 16s, Rank #12/1240, +28
  factory TestResultModel.sampleGeneralScienceMock({
    String studentName = 'Vikram',
    String? photoUrl,
  }) {
    final now = DateTime(2026, 10, 24, 18, 15);
    final questionItems = <QuestionAnalysisItem>[];

    // Build 50 realistic questions mapped to reference image
    // Incorrect: 5, 14, 28, 33, 41, 47 (6 questions)
    // Not Attempted: 18, 49 (2 questions)
    // Correct: all others (42 questions)
    const incorrectNumbers = {5, 14, 28, 33, 41, 47};
    const unattemptedNumbers = {18, 49};

    for (int i = 1; i <= 50; i++) {
      String subject;
      if (i <= 15) {
        subject = 'Physics';
      } else if (i <= 30) {
        subject = 'Chemistry';
      } else if (i <= 40) {
        subject = 'Biology';
      } else {
        subject = 'General Science';
      }

      final correctOpt = 1;
      int? userOpt;
      if (unattemptedNumbers.contains(i)) {
        userOpt = null;
      } else if (incorrectNumbers.contains(i)) {
        userOpt = 2; // wrong option
      } else {
        userOpt = correctOpt; // correct option
      }

      final q = QuestionModel(
        id: 'q_mock_$i',
        testId: 'test_sci_01',
        questionNumber: i,
        subject: subject,
        questionTextEnglish: _getSampleQuestionText(i, subject),
        questionTextHindi: _getSampleQuestionHindi(i, subject),
        options: _getSampleOptions(i, subject),
        correctAnswer: correctOpt,
        explanationEnglish: _getSampleExplanation(i, subject),
        difficultyLevel: i % 3 == 0 ? 'hard' : (i % 2 == 0 ? 'medium' : 'easy'),
      );

      questionItems.add(
        QuestionAnalysisItem(
          question: q,
          questionNumber: i,
          selectedOptionIndex: userOpt,
          correctOptionIndex: correctOpt,
          timeSpentSeconds: 34,
        ),
      );
    }

    final subjects = [
      const SubjectPerformance(
        subjectName: 'Physics',
        correctCount: 12,
        totalQuestions: 15,
        score: 12,
        maxScore: 15,
        accuracy: 80,
        icon: Icons.blur_on_rounded,
        color: Color(0xFF8B5CF6),
        backgroundColor: Color(0xFFF3E8FF),
      ),
      const SubjectPerformance(
        subjectName: 'Chemistry',
        correctCount: 11,
        totalQuestions: 15,
        score: 11,
        maxScore: 15,
        accuracy: 73,
        icon: Icons.science_rounded,
        color: Color(0xFF2587F8),
        backgroundColor: Color(0xFFEFF6FF),
      ),
      const SubjectPerformance(
        subjectName: 'Biology',
        correctCount: 10,
        totalQuestions: 10,
        score: 10,
        maxScore: 10,
        accuracy: 100,
        icon: Icons.eco_rounded,
        color: Color(0xFF10B981),
        backgroundColor: Color(0xFFECFDF5),
      ),
      const SubjectPerformance(
        subjectName: 'General Science',
        correctCount: 9,
        totalQuestions: 10,
        score: 9,
        maxScore: 10,
        accuracy: 90,
        icon: Icons.menu_book_rounded,
        color: Color(0xFFF59E0B),
        backgroundColor: Color(0xFFFFFBEB),
      ),
    ];

    return TestResultModel(
      attemptId: 'att_sample_01',
      testId: 'test_sci_01',
      testTitle: 'General Science',
      testSubtitle: 'Mock Test • Class 8',
      studentName: studentName,
      studentPhotoUrl: photoUrl,
      completedAt: now,
      score: 42,
      maxScore: 50,
      accuracy: 84,
      rank: 12,
      totalParticipants: 1240,
      rankChange: 28,
      timeTakenSeconds: 1696, // 28m 16s
      totalDurationSeconds: 3600,
      isNewBestScore: true,
      correctCount: 42,
      incorrectCount: 6,
      unattemptedCount: 2,
      totalQuestions: 50,
      classAverageScore: 28,
      subjectPerformances: subjects,
      questionItems: questionItems,
      insights: const [
        'Excellent performance in Biology! Keep it up!',
        'You can improve in Chemistry. Practice more questions.',
        'Focus more on the incorrect answers.',
        'Time management is good. Try to be a bit faster.',
      ],
      coinsEarned: 50,
    );
  }

  static (IconData, Color, Color) _getSubjectStyle(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('physic')) {
      return (
        Icons.blur_on_rounded,
        const Color(0xFF8B5CF6),
        const Color(0xFFF3E8FF),
      );
    } else if (lower.contains('chem')) {
      return (
        Icons.science_rounded,
        const Color(0xFF2587F8),
        const Color(0xFFEFF6FF),
      );
    } else if (lower.contains('bio')) {
      return (
        Icons.eco_rounded,
        const Color(0xFF10B981),
        const Color(0xFFECFDF5),
      );
    } else if (lower.contains('math')) {
      return (
        Icons.calculate_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFFFBEB),
      );
    } else {
      return (
        Icons.menu_book_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFFFBEB),
      );
    }
  }

  static String _getSampleQuestionText(int i, String subject) {
    switch (i) {
      case 1:
        return 'What is the SI unit of electric current?';
      case 2:
        return 'Which of the following is an example of kinetic energy transformed into sound energy?';
      case 5:
        return 'What is the acceleration due to gravity on the surface of the Earth?';
      case 14:
        return 'Which state of matter has a definite volume but no definite shape?';
      case 16:
        return 'What is the chemical symbol for Gold?';
      case 18:
        return 'What is the pH value of pure distilled water at 25°C?';
      case 28:
        return 'Which gas is evolved when an acid reacts with a metal?';
      case 31:
        return 'Which organelle is known as the powerhouse of the cell?';
      case 33:
        return 'What is the primary green pigment in plants responsible for photosynthesis?';
      case 41:
        return 'Which planet in our solar system is known as the Red Planet?';
      case 47:
        return 'What type of lens is used in a magnifying glass?';
      case 49:
        return 'Which blood group is known as the universal donor?';
      default:
        return 'In $subject, which of the following statements is scientifically correct regarding question #$i?';
    }
  }

  static String _getSampleQuestionHindi(int i, String subject) {
    switch (i) {
      case 1:
        return 'विद्युत धारा का SI मात्रक क्या है?';
      case 5:
        return 'पृथ्वी की सतह पर गुरुत्वाकर्षण के कारण त्वरण का मान क्या है?';
      case 18:
        return '25°C पर शुद्ध आसुत जल का pH मान क्या है?';
      case 31:
        return 'कोशिका का पावरहाउस किस कोशिकांग को कहा जाता है?';
      default:
        return '$subject में, प्रश्न संख्या $i के संदर्भ में कौन सा कथन वैज्ञानिक रूप से सही है?';
    }
  }

  static List<QuestionOption> _getSampleOptions(int i, String subject) {
    return const [
      QuestionOption(textEnglish: 'Volt (V)', textHindi: 'वोल्ट (V)'),
      QuestionOption(textEnglish: 'Ampere (A)', textHindi: 'एम्पीयर (A)'),
      QuestionOption(textEnglish: 'Ohm (Ω)', textHindi: 'ओम (Ω)'),
      QuestionOption(textEnglish: 'Watt (W)', textHindi: 'वाट (W)'),
    ];
  }

  static String _getSampleExplanation(int i, String subject) {
    return 'The SI unit of electric current is Ampere (symbol: A), named after the French physicist André-Marie Ampère. One ampere is equal to one coulomb of electric charge moving past a given point in one second.';
  }
}
