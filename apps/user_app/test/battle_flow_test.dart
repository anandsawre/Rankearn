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
    createdAt: DateTime.now(),
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
      roundResults: [true, false, true, null, null],
    ),
    opponent: const BattlePlayer(
      id: 'p_2',
      name: 'Amit Verma (Rank #4)',
      rank: 'Rank #4',
      score: 0,
      roundResults: [false, false, false, null, null],
    ),
    entryFee: 100,
    currentRound: 4,
    totalRounds: 5,
    questions: [testQuestion],
  );

  group('Rankearn 1v1 Quiz Battle — 3-Screen Reference Specification Tests', () {
    testWidgets('Screen One: Finding Opponent Screen renders all reference components', (tester) async {
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

      // Verify Header
      expect(find.textContaining('1v1'), findsWidgets);
      expect(find.textContaining('Live'), findsWidgets);
      expect(find.textContaining('Arena'), findsWidgets);
      expect(find.text('100'), findsOneWidget);

      // Verify Matchmaking Radar
      expect(find.byType(MatchmakingRadar), findsOneWidget);

      // Verify Search Status
      expect(find.text('Finding Opponent...'), findsOneWidget);
      expect(find.text('Looking for a player near your skill level'), findsOneWidget);

      // Verify 3 Fair Match Cards
      expect(find.text('1v1 Battle'), findsOneWidget);
      expect(find.text('Real Players'), findsOneWidget);
      expect(find.text('Fair Match'), findsOneWidget);
      expect(find.text('Similar Skill'), findsOneWidget);
      expect(find.text('No Bots'), findsOneWidget);
      expect(find.text('100% Real'), findsOneWidget);

      // Verify Did you know? Card
      expect(find.text('Did you know?'), findsOneWidget);
      expect(find.textContaining('Win battles to earn coins'), findsOneWidget);

      // Verify Cancel Button
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Screen Two: Live Arena Screen renders all Reference Image 1 elements', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LiveArenaScreen(
            initialSession: testSession,
            userCoins: 100,
            userProfile: testProfile,
          ),
        ),
      );

      // 1. Dual Player Scoreboard
      expect(find.text('Vikram Singh'), findsOneWidget);
      expect(find.text('10 pts'), findsOneWidget);
      expect(find.text('Amit Verma (Rank #4)'), findsOneWidget);
      expect(find.text('0 pts'), findsOneWidget);
      expect(find.textContaining('VS'), findsOneWidget);

      // 2. Round Info & Stake
      expect(find.text('Round 4 of 5'), findsOneWidget);
      expect(find.text('Stake: 100 Coins'), findsOneWidget);

      // 3. Question Card
      expect(find.text('General Science'), findsOneWidget);
      expect(find.text('Which is the largest organ in the human body?'), findsOneWidget);

      // 4. Four Options: A Liver, B Heart, C Skin, D Lungs
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Liver'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('Heart'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('Skin'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text('Lungs'), findsOneWidget);

      // 5. Submit Answer Button
      expect(find.text('Submit Answer'), findsOneWidget);

      // 6. Interactive Answer Selection
      final skinFinder = find.text('Skin');
      await tester.tap(skinFinder);
      await tester.pumpAndSettle();

      // Submit the selected answer
      final submitFinder = find.text('Submit Answer');
      await tester.tap(submitFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 950));
    });

    testWidgets('Screen Three: Victory Screen renders all Reference Image 3 elements', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
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
            userCoins: 200,
            profile: testProfile,
            entryFee: 100,
          ),
        ),
      );

      // 1. Victory Celebration Banner
      expect(find.text('VICTORY!'), findsOneWidget);

      // 2. Announcement Message Card
      expect(find.text('You defeated Amit Verma (Rank #4) in 1v1 Battle! 🏆'), findsOneWidget);

      // 3. Player Comparison Card
      expect(find.text('Vikram Singh'), findsOneWidget);
      expect(find.text('10 pts'), findsOneWidget);
      expect(find.text('Amit Verma (Rank #4)'), findsOneWidget);
      expect(find.text('0 pts'), findsOneWidget);
      expect(find.textContaining('VS'), findsOneWidget);

      // 4. Reward Summary Card
      expect(find.text('You won'), findsOneWidget);
      expect(find.text('+100 Coins'), findsOneWidget);
      expect(find.text('Great job! Keep playing to climb the ranks.'), findsOneWidget);

      // 5. Action Buttons
      expect(find.text('Return to Hub'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);
    });
  });
}
