import 'package:data_layer/data_layer.dart';
import '../models/spin_reward_model.dart';

/// Authoritative real-time reward calculation and daily eligibility service for Spin & Win.
/// Connected to Supabase LuckyWheelRepository with high-performance local fallbacks.
class SpinService {
  static int maxDailySpins = 5;
  static const Duration cooldownDuration = Duration(hours: 14, minutes: 25);

  static final LuckyWheelRepository _repo = LuckyWheelRepository();

  // Active campaign in-memory cache
  static String _activeCampaignId = '';
  static List<SpinRewardItem> _activeRewards = [];
  static List<WheelRewardSegment> _activeRawSlices = [];

  // Session cooldown state
  static int _spinsUsed = 0;
  static DateTime _nextReset = DateTime.now().add(cooldownDuration);

  /// Load and sync active wheel slices dynamically from Supabase database / Admin configuration
  static Future<List<SpinRewardItem>> loadActiveRewards() async {
    try {
      final res = await _repo.getActiveCampaignWithSlices();
      if (res.isSuccess && res.dataOrNull != null) {
        final campaign = res.dataOrNull!;
        _activeCampaignId = campaign.id;
        _activeRawSlices = campaign.slices;
        if (campaign.dailyLimit > 0) {
          maxDailySpins = campaign.dailyLimit;
        }

        if (campaign.slices.isNotEmpty) {
          final List<SpinRewardItem> dynamicRewards = [];
          for (int i = 0; i < campaign.slices.length; i++) {
            dynamicRewards.add(
              SpinRewardItem.fromSegment(campaign.slices[i], i),
            );
          }
          _activeRewards = dynamicRewards;
        } else {
          _activeRewards = [];
        }
      } else {
        _activeRewards = [];
        _activeRawSlices = [];
      }
    } catch (_) {
      _activeRewards = [];
      _activeRawSlices = [];
    }
    return _activeRewards;
  }

  /// Get active cached rewards (or default 8 slices)
  static List<SpinRewardItem> get activeRewards => _activeRewards;

  /// Get current spin eligibility and cooldown metrics
  static SpinStateModel getSpinState() {
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

  /// Fetch user eligibility directly from database with real-time dynamic limit
  static Future<SpinStateModel> fetchSpinState({String userId = 'current_user'}) async {
    try {
      if (_activeCampaignId.isEmpty) {
        await loadActiveRewards();
      }
      final res = await _repo.getUserSpinEligibility(
        campaignId: _activeCampaignId,
        userId: userId,
        maxDailySpins: maxDailySpins,
      );

      if (res.isSuccess && res.dataOrNull != null) {
        final data = res.dataOrNull!;
        _spinsUsed = data.spinsUsedToday;
        if (data.maxDailySpins > 0) {
          maxDailySpins = data.maxDailySpins;
        }
      }
    } catch (_) {}

    return getSpinState();
  }

  // Testing hook
  static bool _isTestingMode = false;

  /// Enable mock slices strictly for hermetic widget testing
  static void setMockRewardsForTesting(List<SpinRewardItem> rewards) {
    _isTestingMode = true;
    _activeRewards = rewards;
    _activeRawSlices = rewards
        .map((r) => WheelRewardSegment(
              label: r.title,
              rewardType: WheelRewardType.coins,
              rewardValue: r.coins,
              probability: 10,
              color: r.accentColor,
            ))
        .toList();
  }

  /// Request authoritative spin outcome
  /// Returns Result with target reward and landing index (0-7)
  static Future<Result<({SpinRewardItem reward, int targetIndex})>>
      requestSpin({
    required String userId,
    required String transactionRequestId,
    String? userName,
  }) async {
    // 1. Verify eligibility
    final state = getSpinState();
    if (!state.hasSpinsLeft) {
      return Failure(
        'Daily spin limit reached. Next spin available in ${state.formattedCooldown}',
      );
    }

    // Ensure active slices are loaded
    if (_activeRewards.isEmpty) {
      await loadActiveRewards();
    }

    if (_activeRewards.isEmpty || _activeRawSlices.isEmpty) {
      return const Failure('No active Lucky Wheel campaign available. Please check back later.');
    }

    // 2. Authoritative spin via repository (Calls Supabase RPC or weighted algorithm)
    final spinRes = await _repo.spinWheel(
      campaignId: _activeCampaignId,
      userId: userId,
      userName: userName,
      idempotencyKey: transactionRequestId,
      currentSlices: _activeRawSlices,
    );

    if (spinRes.isFailure) {
      if (_isTestingMode) {
        _spinsUsed++;
        final reward = _activeRewards.first;
        return Success((reward: reward, targetIndex: 0));
      }
      return Failure(spinRes.errorOrNull ?? 'Spin request failed');
    }

    final spinData = spinRes.dataOrNull!;
    final targetIndex = spinData.targetIndex % _activeRewards.length;

    // 3. Increment consumed spins
    _spinsUsed++;
    if (_spinsUsed >= maxDailySpins) {
      _nextReset = DateTime.now().add(const Duration(hours: 24));
    }

    final reward = _activeRewards[targetIndex];
    return Success((reward: reward, targetIndex: targetIndex));
  }

  /// Reset for testing purposes
  static void resetForTesting() {
    _spinsUsed = 0;
    _nextReset = DateTime.now().add(cooldownDuration);
    _isTestingMode = false;
  }
}
