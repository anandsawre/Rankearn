import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';

void main() {
  group('UserProfile Model', () {
    test('Correctly parses from map and evaluates isPro and isActive', () {
      final map = {
        'id': 'usr_123',
        'name': 'Rahul Verma',
        'email': 'rahul@test.com',
        'coins': 1200,
        'subscription_status': 'premium',
        'subscription_end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };

      final profile = UserProfile.fromMap(map);
      expect(profile.id, 'usr_123');
      expect(profile.name, 'Rahul Verma');
      expect(profile.coins, 1200);
      expect(profile.isPro, isTrue);
      expect(profile.isActive, isTrue);
    });

    test('Correctly handles free tier user', () {
      final map = {
        'id': 'usr_456',
        'name': 'Pooja',
        'email': 'pooja@test.com',
        'coins': 50,
        'subscription_status': 'free',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };

      final profile = UserProfile.fromMap(map);
      expect(profile.isPro, isFalse);
    });
  });

  group('TestModel', () {
    test('Evaluates live tournament status correctly', () {
      final liveMap = {
        'id': 't_live',
        'title': 'Live Championship',
        'duration_minutes': 60,
        'is_tournament': true,
        'scheduled_start_time': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        'scheduled_end_time': DateTime.now().add(const Duration(minutes: 50)).toIso8601String(),
      };

      final liveTest = TestModel.fromMap(liveMap);
      expect(liveTest.isLive, isTrue);
      expect(liveTest.isUpcoming, isFalse);
      expect(liveTest.isPast, isFalse);
    });

    test('Evaluates upcoming tournament status correctly', () {
      final upcomingMap = {
        'id': 't_upcoming',
        'title': 'Upcoming Mega Test',
        'duration_minutes': 90,
        'is_tournament': true,
        'scheduled_start_time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        'scheduled_end_time': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
      };

      final upcomingTest = TestModel.fromMap(upcomingMap);
      expect(upcomingTest.isLive, isFalse);
      expect(upcomingTest.isUpcoming, isTrue);
      expect(upcomingTest.isPast, isFalse);
    });
  });

  group('QuestionModel & QuestionOption', () {
    test('Bilingual getters return Hindi when available and English fallback', () {
      final option = QuestionOption(
        textEnglish: 'Option A English',
        textHindi: 'विकल्प ए हिन्दी',
      );

      expect(option.getDisplay(false), 'Option A English');
      expect(option.getDisplay(true), 'विकल्प ए हिन्दी');

      final optionNoHindi = QuestionOption(
        textEnglish: 'Option B English Only',
      );
      expect(optionNoHindi.getDisplay(true), 'Option B English Only');
    });
  });

  group('WalletTransactionModel', () {
    test('Identifies earn vs spend transactions correctly', () {
      final earnTx = WalletTransactionModel.fromMap({
        'id': 'tx_1',
        'user_id': 'u1',
        'amount': 500,
        'type': 'earn',
        'category': 'top_up',
        'title': 'UPI Top-up',
        'balance_after': 500,
      });
      expect(earnTx.isEarn, isTrue);

      final spendTx = WalletTransactionModel.fromMap({
        'id': 'tx_2',
        'user_id': 'u1',
        'amount': -50,
        'type': 'spend',
        'category': 'tournament_entry',
        'title': 'Tournament Entry Fee',
        'balance_after': 450,
      });
      expect(spendTx.isEarn, isFalse);
    });
  });
}
