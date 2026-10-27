import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/features/quiz/quiz_screen.dart';
import 'package:user_app/features/tests/screens/test_result_screen.dart';

void main() {
  const testModel = TestModel(
    id: 'test_demo_exam',
    title: 'General Science Mock Test',
    durationMinutes: 60,
    totalQuestions: 4,
    negativeMarking: 0.25,
  );

  final sampleQuestions = [
    const QuestionModel(
      id: 'q_1',
      testId: 'test_demo_exam',
      questionNumber: 1,
      subject: 'Physics',
      questionTextEnglish: 'What is the SI unit of electric force?',
      questionTextHindi: 'विद्युत बल का SI मात्रक क्या है?',
      options: [
        QuestionOption(textEnglish: 'Newton', textHindi: 'न्यूटन'),
        QuestionOption(textEnglish: 'Joule', textHindi: 'जूल'),
        QuestionOption(textEnglish: 'Watt', textHindi: 'वाट'),
        QuestionOption(textEnglish: 'Pascal', textHindi: 'पास्कल'),
      ],
      correctAnswer: 0,
    ),
    const QuestionModel(
      id: 'q_2',
      testId: 'test_demo_exam',
      questionNumber: 2,
      subject: 'Chemistry',
      questionTextEnglish: 'What is the chemical formula of ozone?',
      questionTextHindi: 'ओजोन का रासायनिक सूत्र क्या है?',
      options: [
        QuestionOption(textEnglish: 'O2', textHindi: 'O2'),
        QuestionOption(textEnglish: 'O3', textHindi: 'O3'),
        QuestionOption(textEnglish: 'H2O', textHindi: 'H2O'),
        QuestionOption(textEnglish: 'CO2', textHindi: 'CO2'),
      ],
      correctAnswer: 1,
    ),
    const QuestionModel(
      id: 'q_3',
      testId: 'test_demo_exam',
      questionNumber: 3,
      subject: 'Biology',
      questionTextEnglish:
          'Which organelle is called the powerhouse of the cell?',
      questionTextHindi: 'कोशिका का पावरहाउस किसे कहा जाता है?',
      options: [
        QuestionOption(textEnglish: 'Nucleus', textHindi: 'नाभिक'),
        QuestionOption(textEnglish: 'Ribosome', textHindi: 'राइबोसोम'),
        QuestionOption(
          textEnglish: 'Mitochondria',
          textHindi: 'माइटोकॉन्ड्रिया',
        ),
        QuestionOption(textEnglish: 'Chloroplast', textHindi: 'क्लोरोप्लास्ट'),
      ],
      correctAnswer: 2,
    ),
    const QuestionModel(
      id: 'q_4',
      testId: 'test_demo_exam',
      questionNumber: 4,
      subject: 'Physics',
      questionTextEnglish: 'Light year is a unit of which quantity?',
      questionTextHindi: 'प्रकाश वर्ष किस राशि का मात्रक है?',
      options: [
        QuestionOption(textEnglish: 'Time', textHindi: 'समय'),
        QuestionOption(textEnglish: 'Distance', textHindi: 'दूरी'),
        QuestionOption(textEnglish: 'Speed', textHindi: 'गति'),
        QuestionOption(textEnglish: 'Intensity', textHindi: 'तीव्रता'),
      ],
      correctAnswer: 1,
    ),
  ];

  final sampleUserProfile = UserProfile(
    id: 'cand_987654',
    name: 'Vikram Singh',
    email: 'vikram@example.com',
    coins: 1250,
    createdAt: DateTime(2026, 1, 1),
  );

  group('QuizScreen TCS iON Exam Layout & Feature Tests', () {
    testWidgets(
      'Desktop view renders persistent palette sidebar, candidate header, and sections',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: QuizScreen(
              test: testModel,
              questions: sampleQuestions,
              onExit: () {},
              userProfile: sampleUserProfile,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Top Header elements
        expect(find.text('GENERAL SCIENCE MOCK TEST'), findsOneWidget);
        expect(find.text('PAUSE'), findsOneWidget);
        expect(find.text('EN'), findsOneWidget);
        expect(find.text('HI'), findsOneWidget);

        // Section Tabs
        expect(find.text('ALL'), findsOneWidget);
        expect(find.text('PHYSICS'), findsOneWidget);
        expect(find.text('CHEMISTRY'), findsOneWidget);
        expect(find.text('BIOLOGY'), findsOneWidget);

        // Question subheader & card
        expect(find.text('Q. 1'), findsOneWidget);
        expect(find.text('+1.0'), findsOneWidget);
        expect(find.text('-0.25'), findsOneWidget);
        expect(find.text('View Instructions'), findsOneWidget);
        expect(
          find.text('What is the SI unit of electric force?'),
          findsOneWidget,
        );

        // Options
        expect(find.text('Newton'), findsOneWidget);
        expect(find.text('Joule'), findsOneWidget);

        // Desktop Question Palette on Right
        expect(find.text('VIKRAM SINGH'), findsOneWidget);
        expect(find.text('ID: CAND_987'), findsOneWidget);
        expect(find.text('CHOOSE A QUESTION'), findsOneWidget);
        expect(find.text('Answered'), findsOneWidget);
        expect(find.text('Not Answered'), findsOneWidget);
        expect(find.text('Not Visited'), findsOneWidget);
        expect(find.text('Marked Review'), findsOneWidget);
        expect(find.text('SUBMIT TEST'), findsOneWidget);
      },
    );

    testWidgets(
      'Language switch toggle changes question and options text to Hindi',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: QuizScreen(
              test: testModel,
              questions: sampleQuestions,
              onExit: () {},
              userProfile: sampleUserProfile,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap 'HI' button
        await tester.tap(find.text('HI'));
        await tester.pumpAndSettle();

        // Expect Hindi text
        expect(find.text('विद्युत बल का SI मात्रक क्या है?'), findsOneWidget);
        expect(find.text('न्यूटन'), findsOneWidget);
        expect(find.text('जूल'), findsOneWidget);

        // Tap 'EN' button to switch back
        await tester.tap(find.text('EN'));
        await tester.pumpAndSettle();

        expect(
          find.text('What is the SI unit of electric force?'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Section tab switching jumps to first question in subject', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            test: testModel,
            questions: sampleQuestions,
            onExit: () {},
            userProfile: sampleUserProfile,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Currently on Question 1 (Physics)
      expect(find.text('Q. 1'), findsOneWidget);

      // Tap Chemistry tab
      await tester.tap(find.text('CHEMISTRY'));
      await tester.pumpAndSettle();

      // Should jump to Question 2 (Chemistry)
      expect(find.text('Q. 2'), findsOneWidget);
      expect(
        find.text('What is the chemical formula of ozone?'),
        findsOneWidget,
      );
    });

    testWidgets('Instructions dialog opens and closes properly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            test: testModel,
            questions: sampleQuestions,
            onExit: () {},
            userProfile: sampleUserProfile,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'View Instructions'
      await tester.tap(find.text('View Instructions'));
      await tester.pumpAndSettle();

      expect(find.text('Exam Instructions'), findsOneWidget);
      expect(find.text('General Instructions'), findsOneWidget);
      expect(find.text('Marking Scheme'), findsOneWidget);
      expect(find.text('60 Minutes'), findsOneWidget);

      // Dismiss
      await tester.tap(find.text('I Have Read All Instructions'));
      await tester.pumpAndSettle();

      expect(find.text('General Instructions'), findsNothing);
    });

    testWidgets('Pause modal opens and resumes exam', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            test: testModel,
            questions: sampleQuestions,
            onExit: () {},
            userProfile: sampleUserProfile,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'PAUSE'
      await tester.tap(find.text('PAUSE'));
      await tester.pumpAndSettle();

      expect(find.text('EXAM PAUSED'), findsOneWidget);
      expect(find.text('RESUME EXAM'), findsOneWidget);

      // Resume
      await tester.tap(find.text('RESUME EXAM'));
      await tester.pumpAndSettle();

      expect(find.text('EXAM PAUSED'), findsNothing);
    });

    testWidgets(
      'Option selection, Mark Review, and Submit Test opens confirmation dialog',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: QuizScreen(
              test: testModel,
              questions: sampleQuestions,
              onExit: () {},
              userProfile: sampleUserProfile,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select Option A (Newton)
        await tester.tap(find.text('Newton'));
        await tester.pumpAndSettle();

        // Tap Save & Next
        await tester.tap(find.text('Save & Next'));
        await tester.pumpAndSettle();

        // Now on Question 2
        expect(find.text('Q. 2'), findsOneWidget);

        // Tap Submit Test in Sidebar
        await tester.tap(find.text('SUBMIT TEST'));
        await tester.pumpAndSettle();

        // Submit Confirmation Dialog
        expect(find.text('Submit Test?'), findsOneWidget);
        expect(find.text('Yes, Submit'), findsOneWidget);

        // Tap Yes, Submit -> Should navigate to TestResultScreen
        await tester.tap(find.text('Yes, Submit'));
        await tester.pumpAndSettle();

        expect(find.byType(TestResultScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Mobile view renders palette drawer and controls touch-friendly',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: QuizScreen(
              test: testModel,
              questions: sampleQuestions,
              onExit: () {},
              userProfile: sampleUserProfile,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Palette trigger button exists on mobile with question mark icon
        expect(find.byKey(const Key('mobile_palette_button')), findsOneWidget);
        expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);

        // Tap Palette trigger to open drawer
        await tester.tap(find.byKey(const Key('mobile_palette_button')));
        await tester.pumpAndSettle();

        // Drawer has Question Palette header and content
        expect(find.text('QUESTION PALETTE'), findsOneWidget);
        expect(find.text('VIKRAM SINGH'), findsOneWidget);
      },
    );
  });
}
