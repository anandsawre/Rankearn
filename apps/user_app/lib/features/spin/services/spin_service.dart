import 'dart:math' as math;
import 'package:shared_core/shared_core.dart';
import '../models/spin_reward_model.dart';

/// Secure reward calculation and daily eligibility management service for Spin & Win.
class SpinService {
  // Configured spin parameters
  static const int maxDailySpins = 3;
  static const Duration cooldownDuration = Duration(hours: 14, minutes: 25);

  // In-memory persistent state across session (in production backed by Supabase RPC)
  static int _spinsUsed = 1;
  static DateTime _nextReset = DateTime.now().add(cooldownDuration);

  /// Get current spin eligibility and cooldown metrics
  static SpinStateModel getSpinState() {
    // If cooldown has elapsed, reset daily counter
    if (DateTime.now().isAfter(_nextReset)) {
      _spinsUsed = 0;
      _nextReset = DateTime.now().add(const Duration(hours: 24));
    }

    return SpinStateModel(
      spinsUsedToday: _spinsUsed,
      maxSpinsPerDay: maxDailySpins,
      nextResetTime: _nextReset,
      isEligible: _spinsUsed < maxDailySpins,
    );
  }

  /// Request authoritative spin outcome
  /// Returns Result with target reward and landing index (0-7)
  static Future<Result<({SpinRewardItem reward, int targetIndex})>>
  requestSpin({
    required String userId,
    required String transactionRequestId,
  }) async {
    // 1. Verify eligibility
    final state = getSpinState();
    if (!state.hasSpinsLeft) {
      return Failure(
        'Daily spin limit reached. Next spin available in ${state.formattedCooldown}',
      );
    }

    // 2. Authoritative weighted probability outcome
    // (Weighted: 10/50 coins high probability, 100/200 medium, 500 jackpot/special low)
    final random = math.Random();
    final randVal = random.nextDouble() * 100; // 0..100

    int selectedIndex;
    if (randVal < 30) {
      selectedIndex = 4; // 10 Coins (30% weight)
    } else if (randVal < 55) {
      selectedIndex = 1; // 50 Coins (25% weight)
    } else if (randVal < 72) {
      selectedIndex = 0; // 100 Coins (17% weight)
    } else if (randVal < 84) {
      selectedIndex = 6; // 200 Coins (12% weight)
    } else if (randVal < 92) {
      selectedIndex = 7; // Extra Attempt (8% weight)
    } else if (randVal < 97) {
      selectedIndex = 2; // Rank Booster (5% weight)
    } else if (randVal < 99.2) {
      selectedIndex = 3; // Surprise Gift (2.2% weight)
    } else {
      selectedIndex = 5; // 500 Coins Mega Jackpot (0.8% weight)
    }

    // 3. Increment consumed spins
    _spinsUsed++;
    if (_spinsUsed >= maxDailySpins) {
      _nextReset = DateTime.now().add(const Duration(hours: 24));
    }

    final reward = SpinRewardItem.defaultRewards[selectedIndex];
    return Success((reward: reward, targetIndex: selectedIndex));
  }

  /// Reset for testing purposes
  static void resetForTesting() {
    _spinsUsed = 1;
    _nextReset = DateTime.now().add(cooldownDuration);
  }
}
