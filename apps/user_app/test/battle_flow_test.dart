import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/features/battle/screens/finding_opponent_screen.dart';
import 'package:user_app/features/battle/screens/live_arena_screen.dart';
import 'package:user_app/features/battle/screens/battle_result_screen.dart';

void main() {
  final testProfile = UserProfile(
    id: 'user_test_1',
    name: 'Vikram Singh',
    email: 'vikram@rankearn.com',
    coins: 100,
    createdAt: DateTime(2026, 1, 1),
  );

  final testQuestion = const BattleQuestion(
    id: 'bq_4',
    subject: 'General Science',
    questionText: 'Which is the largest organ in the human body?',
    options: ['Liver', 'Heart', 'Skin', 'Lungs'],
    correctAnswer: 2,
    timeLimitSeconds: 12,
  );

  final testSession = BattleSession(
    id: 'test_session_1',
    player: const BattlePlayer(
      id: 'p_1',
      name: 'Vikram Singh',
      rank: '#1',
      score: 10,
      roundResults: [true, true, true, null, null],
    ),
    opponent: const BattlePlayer(
      id: 'p_2',
      name: 'Amit Verma (Rank #4)',
      rank: 'Rank #4',
      score: 0,
      roundResults: [false, null, null, null, null],
    ),
    entryFee: 100,
    currentRound: 4,
    totalRounds: 5,
    questions: [testQuestion],
  );

  group('Rankearn 1v1 Quiz Battle — Responsive Reference Specification Tests', () {
    testWidgets('Screen A: Finding Opponent Screen renders all Reference Image 3 elements on Mobile', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: FindingOpponentScreen(
            userCoins: 100,
            profile: testProfile,
            entryFee: 100,
          ),
        ),
      );
      await tester.pump();

      // 1. Header & Radar
      expect(find.byType(MatchmakingRadar), findsOneWidget);

      // 2. Search Status & Highlights
      expect(find.text('Finding Opponent...'), findsOneWidget);
      expect(find.text('Looking for a player near your skill level'), findsOneWidget);
      expect(find.text('Real Players Only'), findsOneWidget);
      expect(find.text('Fair & Balanced Match'), findsOneWidget);
      expect(find.text('Similar Skill Level'), findsOneWidget);

      // 3. Matchmaking Progress Stepper & Stats
      expect(find.text('Matchmaking in Progress'), findsOneWidget);
      expect(find.textContaining('Finding'), findsWidgets);
      expect(find.text('Estimated Wait Time'), findsOneWidget);
      expect(find.text('10 - 30 seconds'), findsOneWidget);
      expect(find.text('Your Skill Level'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Players Online'), findsWidgets);

      // 4. Three Benefit Feature Cards
      expect(find.text('1v1 Battle'), findsWidgets);
      expect(find.text('Real Players'), findsOneWidget);
      expect(find.text('Fair Match'), findsOneWidget);
      expect(find.text('Similar Skill'), findsOneWidget);
      expect(find.text('No Bots'), findsOneWidget);
      expect(find.text('100% Real'), findsOneWidget);

      // 5. Did you know? Banner
      expect(find.text('Did you know?'), findsOneWidget);
      expect(find.textContaining('Win battles to earn coins'), findsOneWidget);

      // 6. Cancel Button
      expect(find.text('Cancel Matchmaking'), findsOneWidget);
      await tester.tap(find.text('Cancel Matchmaking'), warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('Screen A: Finding Opponent Screen renders Desktop 3-section layout cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: FindingOpponentScreen(
            userCoins: 1250,
            profile: testProfile,
            entryFee: 100,
          ),
        ),
      );
      await tester.pump();

      // Desktop navigation header
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Tests'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('1v1 Battle'), findsWidgets);
      expect(find.text('Rewards'), findsOneWidget);

      // 3-section hero elements
      expect(find.byType(MatchmakingRadar), findsOneWidget);
      expect(find.text('Finding Opponent...'), findsOneWidget);
      expect(find.text('Matchmaking in Progress'), findsOneWidget);
      expect(find.text('Cancel Matchmaking'), findsOneWidget);
      await tester.tap(find.text('Cancel Matchmaking'), warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('Screen B: Live Arena Screen renders all Reference Image 2 elements on Mobile & Desktop', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LiveArenaScreen(
            initialSession: testSession,
            userCoins: 1250,
            userProfile: testProfile,
          ),
        ),
      );
      await tester.pump();

      // 1. Stadium Versus Banner
      expect(find.byType(StadiumVersusBanner), findsOneWidget);
      expect(find.descendant(of: find.byType(StadiumVersusBanner), matching: find.text('Vikram Singh')), findsOneWidget);
      expect(find.text('10 pts'), findsOneWidget);
      expect(find.text('Amit Verma (Rank #4)'), findsOneWidget);
      expect(find.text('0 pts'), findsOneWidget);

      // 2. Question Palette Card (Left column on Desktop)
      expect(find.byType(QuestionPaletteCard), findsOneWidget);
      expect(find.text('Question Palette'), findsOneWidget);
      expect(find.text('Surrender Battle'), findsOneWidget);

      // 3. Question Card & Options
      expect(find.text('General Science'), findsOneWidget);
      expect(find.text('Which is the largest organ in the human body?'), findsOneWidget);
      expect(find.text('Liver'), findsOneWidget);
      expect(find.text('Heart'), findsOneWidget);
      expect(find.text('Skin'), findsOneWidget);
      expect(find.text('Lungs'), findsOneWidget);
      expect(find.text('Submit Answer'), findsOneWidget);

      // 4. Right Sidebar Cards
      expect(find.text('Round 4 of 5'), findsOneWidget);
      expect(find.text('Time Left'), findsOneWidget);
      expect(find.text('Stake'), findsOneWidget);
      expect(find.text('Battle Info'), findsOneWidget);
      expect(find.text('Win this Battle'), findsOneWidget);
      expect(find.text('Players Online'), findsOneWidget);
      expect(find.text('Recent Battles'), findsOneWidget);

      // Interactive answer selection
      final skinFinder = find.text('Skin');
      await tester.tap(skinFinder);
      await tester.pumpAndSettle();

      // Submit answer
      final submitFinder = find.text('Submit Answer');
      await tester.tap(submitFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 950));
    });

    testWidgets('Screen C: Victory Screen renders all Reference Image 1 elements on Desktop & Mobile', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const victoryResult = BattleResult(
        isVictory: true,
        playerName: 'Vikram Singh',
        playerScore: 10,
        opponentName: 'Amit Verma (Rank #4)',
        opponentScore: 0,
        opponentRank: 'Rank #4',
        coinsWon: 100,
        message: 'You defeated Amit Verma (Rank #4) in 1v1 Battle! 🏆',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BattleResultScreen(
            result: victoryResult,
            userCoins: 1250,
            profile: testProfile,
            entryFee: 100,
          ),
        ),
      );
      await tester.pump();

      // 1. Victory Celebration Banner
      expect(find.text('VICTORY!'), findsOneWidget);
      expect(find.text('You defeated Amit Verma (Rank #4) in 1v1 Battle! 🏆'), findsOneWidget);

      // 2. Player Comparison Card
      expect(find.text('Vikram Singh'), findsAtLeastNWidgets(1));
      expect(find.text('10 pts'), findsOneWidget);
      expect(find.text('Amit Verma (Rank #4)'), findsOneWidget);
      expect(find.text('0 pts'), findsOneWidget);

      // 3. Reward Summary Card
      expect(find.text('You won'), findsOneWidget);
      expect(find.text('+100 Coins'), findsOneWidget);
      expect(find.text('Great job! Keep playing to climb the ranks.'), findsOneWidget);

      // 4. Action Buttons
      expect(find.text('Return to Hub'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);

      // 5. Right Sidebar Cards on Desktop (Image 1)
      expect(find.text('Battle Summary'), findsOneWidget);
      expect(find.text('Total Questions'), findsOneWidget);
      expect(find.text('Your Correct Answers'), findsOneWidget);
      expect(find.text('Time Taken'), findsOneWidget);

      expect(find.text('Rank Impact'), findsOneWidget);
      expect(find.text('Your Rank'), findsOneWidget);
      expect(find.text('+28'), findsOneWidget);
      expect(find.text('3 Wins'), findsOneWidget);

      expect(find.text('Keep Going!'), findsOneWidget);
    });
  });
}
