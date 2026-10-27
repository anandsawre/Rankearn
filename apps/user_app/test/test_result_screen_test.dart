import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/features/tests/screens/test_result_screen.dart';
import 'package:user_app/features/tests/screens/answer_review_screen.dart';

void main() {
  group('TestResultModel Logic Tests', () {
    test('Calculates score, accuracy, and negative marking accurately', () {
      const test = TestModel(
        id: 'test_demo',
        title: 'Science Prelims',
        durationMinutes: 60,
        totalQuestions: 10,
        negativeMarking: 0.33,
      );

      final questions = List.generate(
        10,
        (i) => QuestionModel(
          id: 'q_$i',
          testId: 'test_demo',
          questionNumber: i + 1,
          subject: i < 5 ? 'Physics' : 'Chemistry',
          questionTextEnglish: 'Question $i text',
          options: const [
            QuestionOption(textEnglish: 'Opt A'),
            QuestionOption(textEnglish: 'Opt B'),
            QuestionOption(textEnglish: 'Opt C'),
            QuestionOption(textEnglish: 'Opt D'),
          ],
          correctAnswer: 0,
        ),
      );

      // 6 correct (0..5), 2 incorrect (6..7), 2 unattempted (8..9)
      final userAnswers = <String, int?>{
        'q_0': 0,
        'q_1': 0,
        'q_2': 0,
        'q_3': 0,
        'q_4': 0,
        'q_5': 0,
        'q_6': 1, // incorrect
        'q_7': 2, // incorrect
        'q_8': null, // unattempted
        'q_9': null, // unattempted
      };

      final result = TestResultModel.fromSubmission(
        test: test,
        questions: questions,
        userAnswers: userAnswers,
        timeTakenSeconds: 1200,
      );

      expect(result.totalQuestions, 10);
      expect(result.correctCount, 6);
      expect(result.incorrectCount, 2);
      expect(result.unattemptedCount, 2);
      expect(result.accuracy, 60.0);

      // Score: 6 * 1 - 2 * 0.33 = 5.34
      expect(result.score, closeTo(5.34, 0.01));
      expect(result.maxScore, 10.0);

      // Subject breakdown: Physics (5 Qs, all 5 correct -> 100%), Chemistry (5 Qs, 1 correct -> 20%)
      expect(result.subjectPerformances.length, 2);
      final phys = result.subjectPerformances.firstWhere(
        (s) => s.subjectName == 'Physics',
      );
      expect(phys.correctCount, 5);
      expect(phys.totalQuestions, 5);
      expect(phys.accuracy, 100.0);

      final chem = result.subjectPerformances.firstWhere(
        (s) => s.subjectName == 'Chemistry',
      );
      expect(chem.correctCount, 1);
      expect(chem.totalQuestions, 5);
      expect(chem.accuracy, 20.0);

      // Insights should flag Physics excellence and Chemistry improvement
      expect(result.insights.any((i) => i.contains('Physics')), isTrue);
      expect(result.insights.any((i) => i.contains('Chemistry')), isTrue);
    });

    test('Sample General Science mock data matches reference specs', () {
      final sample = TestResultModel.sampleGeneralScienceMock();

      expect(sample.score, 42);
      expect(sample.maxScore, 50);
      expect(sample.accuracy, 84);
      expect(sample.correctCount, 42);
      expect(sample.incorrectCount, 6);
      expect(sample.unattemptedCount, 2);
      expect(sample.totalQuestions, 50);
      expect(sample.rank, 12);
      expect(sample.totalParticipants, 1240);
      expect(sample.rankChange, 28);
      expect(sample.timeTakenSeconds, 1696);
      expect(sample.formattedTimeTaken, '28m 16s');
      expect(sample.isNewBestScore, isTrue);
    });
  });

  group('TestResultScreen Responsive & Interactive Widget Tests', () {
    final sampleResult = TestResultModel.sampleGeneralScienceMock();

    const requiredWidths = [
      ('Mobile 360px', 360.0, 780.0),
      ('Mobile 390px', 390.0, 844.0),
      ('Mobile 430px', 430.0, 932.0),
      ('Tablet 768px', 768.0, 1024.0),
      ('Desktop 1024px', 1024.0, 768.0),
      ('Desktop 1366px', 1366.0, 768.0),
      ('Desktop 1440px', 1440.0, 900.0),
      ('Desktop 1920px (Full HD)', 1920.0, 1080.0),
    ];

    for (final rw in requiredWidths) {
      testWidgets('Renders TestResultScreen on ${rw.$1} with zero overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = Size(rw.$2, rw.$3);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: TestResultScreen(result: sampleResult, userCoins: 1250),
          ),
        );

        await tester.pumpAndSettle();

        // Verify Hero Banner elements
        expect(find.text('General Science'), findsWidgets);
        expect(find.textContaining('Great Job'), findsOneWidget);
        expect(find.text('42 / 50'), findsWidgets);
        expect(find.text('84%'), findsWidgets);
        expect(find.text('28m 16s'), findsOneWidget);

        // Verify Analysis Navigation Tabs exist
        expect(find.text('Question Analysis'), findsOneWidget);
        expect(find.text('Subject Analysis'), findsOneWidget);
        expect(find.text('Time Analysis'), findsOneWidget);
        expect(find.text('Rank & Rewards'), findsOneWidget);

        // Verify Primary Action Button
        expect(find.text('Review Answers'), findsOneWidget);
      });
    }

    testWidgets('Tab switching dynamically changes analysis view', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: TestResultScreen(result: sampleResult, userCoins: 1250),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Time Analysis Tab
      await tester.tap(find.text('Time Analysis'));
      await tester.pumpAndSettle();
      expect(find.text('Time Management Analysis'), findsOneWidget);

      // Switch to Rank & Rewards Tab
      await tester.tap(find.text('Rank & Rewards'));
      await tester.pumpAndSettle();
      expect(find.text('Rank & Reward Standing'), findsOneWidget);

      // Switch back to Question Analysis
      await tester.tap(find.text('Question Analysis'));
      await tester.pumpAndSettle();
      expect(find.text('Question-wise Analysis'), findsOneWidget);
    });

    testWidgets('Review Answers button opens AnswerReviewScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: TestResultScreen(result: sampleResult, userCoins: 1250),
        ),
      );
      await tester.pumpAndSettle();

      final reviewBtn = find.text('Review Answers').first;
      await tester.ensureVisible(reviewBtn);
      await tester.tap(reviewBtn);
      await tester.pumpAndSettle();

      // Verify Answer Review Screen is active
      expect(find.byType(AnswerReviewScreen), findsOneWidget);
      expect(find.text('Explanation'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
