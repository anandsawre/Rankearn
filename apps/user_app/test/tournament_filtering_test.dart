import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';

void main() {
  group('Tournament Filtering & Model Tests', () {
    test('Upcoming tournament is correctly identified and separated from live/past', () {
      final now = DateTime.now();
      final futureStart = now.add(const Duration(days: 2)); // e.g. 24 Nov
      final pastStart = now.subtract(const Duration(days: 3)); // e.g. 19 Nov

      final upcomingTournament = TestModel(
        id: 'test-upcoming',
        title: 'Unit And Measurements',
        durationMinutes: 20,
        totalQuestions: 50,
        isTournament: true,
        entryFeeCoins: 100,
        scheduledStartTime: futureStart,
        scheduledEndTime: futureStart.add(const Duration(minutes: 20)),
        status: 'published',
      );

      final pastTournament = TestModel(
        id: 'test-past',
        title: 'Mega Contest',
        durationMinutes: 60,
        totalQuestions: 20,
        isTournament: true,
        entryFeeCoins: 20,
        scheduledStartTime: pastStart,
        scheduledEndTime: pastStart.add(const Duration(minutes: 60)),
        status: 'published',
      );

      final liveTournament = TestModel(
        id: 'test-live',
        title: 'Live Battle Today',
        durationMinutes: 60,
        totalQuestions: 30,
        isTournament: true,
        entryFeeCoins: 10,
        scheduledStartTime: now.subtract(const Duration(minutes: 10)),
        scheduledEndTime: now.add(const Duration(minutes: 50)),
        status: 'published',
      );

      // Verify TestModel flags
      expect(upcomingTournament.isUpcoming, isTrue);
      expect(upcomingTournament.isLive, isFalse);
      expect(upcomingTournament.isPast, isFalse);

      expect(pastTournament.isUpcoming, isFalse);
      expect(pastTournament.isLive, isFalse);
      expect(pastTournament.isPast, isTrue);

      expect(liveTournament.isUpcoming, isFalse);
      expect(liveTournament.isLive, isTrue);
      expect(liveTournament.isPast, isFalse);

      // Verify separation logic
      final allTournaments = [upcomingTournament, pastTournament, liveTournament];

      final running = allTournaments
          .where((t) =>
              !t.isUpcoming &&
              !t.isPast &&
              (t.isLive ||
                  t.scheduledStartTime == null ||
                  DateTime.now().isAfter(t.scheduledStartTime!)))
          .toList();

      final upcoming = allTournaments.where((t) => t.isUpcoming).toList();
      final completed = allTournaments.where((t) => t.isPast || t.status == 'completed').toList();

      // Running must ONLY contain liveTournament
      expect(running.length, 1);
      expect(running.first.id, 'test-live');

      // Upcoming must ONLY contain upcomingTournament
      expect(upcoming.length, 1);
      expect(upcoming.first.id, 'test-upcoming');

      // Completed must ONLY contain pastTournament
      expect(completed.length, 1);
      expect(completed.first.id, 'test-past');

      // Ensure zero overlap between running and upcoming
      final intersection = running.where((r) => upcoming.any((u) => u.id == r.id)).toList();
      expect(intersection, isEmpty);
    });

    test('Live Test vs Contest Separation strictly routes tests to their intended tabs', () {
      final now = DateTime.now();
      final futureStart = now.add(const Duration(days: 2));

      // 1. A pure Live Test (ticked "Run as Scheduled Live Test")
      final scheduledLiveTest = TestModel(
        id: 'test-live-only',
        title: 'All India Live Science Mock',
        durationMinutes: 45,
        totalQuestions: 50,
        testMode: 'live',
        isTournament: false,
        entryFeeCoins: 0,
        scheduledStartTime: futureStart,
        status: 'published',
      );

      // 2. A pure Contest (ticked "Run as Live Paid Contest / Tournament")
      final paidTournament = TestModel(
        id: 'test-contest-only',
        title: 'Unit And Measurements Tournament',
        durationMinutes: 20,
        totalQuestions: 50,
        testMode: 'tournament',
        isTournament: true,
        entryFeeCoins: 100,
        scheduledStartTime: futureStart,
        status: 'published',
      );

      final combinedPool = [scheduledLiveTest, paidTournament];

      // Contests query: strictly isTournament == true or testMode == 'tournament'
      final tournamentTabList = combinedPool
          .where((t) => t.isTournament || t.testMode == 'tournament')
          .toList();

      // Live Tests query: strictly excludes pure tournaments
      final liveTestsTabList = combinedPool
          .where((t) =>
              (!t.isTournament || t.testMode == 'live' || t.testMode == 'live_quiz') &&
              t.testMode != 'tournament')
          .toList();

      // Contests tab must ONLY contain paidTournament
      expect(tournamentTabList.length, 1);
      expect(tournamentTabList.first.id, 'test-contest-only');

      // Live Tests tab must ONLY contain scheduledLiveTest
      expect(liveTestsTabList.length, 1);
      expect(liveTestsTabList.first.id, 'test-live-only');

      // Zero overlap between Live Test tab and Contests tab
      final overlap = tournamentTabList.where((t) => liveTestsTabList.any((l) => l.id == t.id)).toList();
      expect(overlap, isEmpty);
    });
  });
}
