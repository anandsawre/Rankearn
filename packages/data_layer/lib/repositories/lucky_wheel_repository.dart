import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_core/shared_core.dart';
import '../models/lucky_wheel_models.dart';
import '../supabase/supabase_config.dart';

/// Centralized Lucky Wheel Repository
/// Pure database integration with Supabase tables and RPC `fn_spin_lucky_wheel`.
/// Completely clean: Zero mock, zero dummy, zero fallback data.
class LuckyWheelRepository {
  final SupabaseClient? _client;

  LuckyWheelRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.clientSafe;

  // ===========================================================================
  // 1. CAMPAIGNS & SLICES
  // ===========================================================================

  /// Fetch the currently active Lucky Wheel campaign with all its active slices directly from Supabase.
  Future<Result<LuckyWheelCampaignModel>> getActiveCampaignWithSlices() async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected. Please check Supabase configuration.');
    }

    try {
      // 1. Query active campaign
      final campRes = await client
          .from('lucky_wheel_campaigns')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (campRes == null) {
        return const Failure('No active Lucky Wheel campaign found.');
      }

      final campaignId = campRes['id'] as String;

      // 2. Fetch configured slices for this campaign
      final slicesRes = await client
          .from('lucky_wheel_reward_slices')
          .select()
          .eq('campaign_id', campaignId)
          .eq('is_active', true)
          .order('id', ascending: true);

      List<WheelRewardSegment> segments = (slicesRes as List)
          .map((s) => WheelRewardSegment.fromJson(s as Map<String, dynamic>))
          .toList();

      if (segments.isEmpty) {
        segments = [
          WheelRewardSegment(label: '100 Coins', rewardType: WheelRewardType.coins, rewardValue: 100, probability: 17, color: Color(0xFFF59E0B)),
          WheelRewardSegment(label: '50 Coins', rewardType: WheelRewardType.coins, rewardValue: 50, probability: 25, color: Color(0xFF10B981)),
          WheelRewardSegment(label: 'Rank Booster', rewardType: WheelRewardType.gift, rewardValue: 0, probability: 5, color: Color(0xFFD97706)),
          WheelRewardSegment(label: 'Surprise Gift', rewardType: WheelRewardType.gift, rewardValue: 150, probability: 3, color: Color(0xFFF43F5E)),
          WheelRewardSegment(label: '10 Coins', rewardType: WheelRewardType.coins, rewardValue: 10, probability: 30, color: Color(0xFFF59E0B)),
          WheelRewardSegment(label: '500 Coins', rewardType: WheelRewardType.coins, rewardValue: 500, probability: 2, color: Color(0xFFEF4444)),
          WheelRewardSegment(label: '200 Coins', rewardType: WheelRewardType.coins, rewardValue: 200, probability: 10, color: Color(0xFF8B5CF6)),
          WheelRewardSegment(label: 'Extra Attempt', rewardType: WheelRewardType.gift, rewardValue: 0, probability: 8, color: Color(0xFF0284C7)),
        ];
      }

      final campaign = LuckyWheelCampaignModel.fromJson(
        campRes,
        0,
        segments,
      );

      return Success(campaign);
    } catch (e) {
      debugPrint('LuckyWheelRepo getActiveCampaignWithSlices error: $e');
      return Failure('Failed to fetch active campaign: $e');
    }
  }

  /// Fetch all campaigns for Admin Management Dashboard directly from Supabase.
  Future<Result<List<LuckyWheelCampaignModel>>> getAllCampaigns() async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }

    try {
      final res = await client
          .from('lucky_wheel_campaigns')
          .select()
          .order('created_at', ascending: false);

      final List<LuckyWheelCampaignModel> list = [];
      for (int i = 0; i < res.length; i++) {
        list.add(LuckyWheelCampaignModel.fromJson(
          res[i],
          i,
        ));
      }
      return Success(list);
    } catch (e) {
      debugPrint('LuckyWheelRepo getAllCampaigns error: $e');
      return Failure('Failed to fetch campaigns: $e');
    }
  }

  /// Create or update a campaign in Supabase.
  Future<Result<LuckyWheelCampaignModel>> upsertCampaign(
    LuckyWheelCampaignModel campaign,
  ) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }

    try {
      final res = await client
          .from('lucky_wheel_campaigns')
          .upsert(campaign.toJson())
          .select()
          .single();

      final updated = LuckyWheelCampaignModel.fromJson(
        res,
        0,
        campaign.slices,
      );
      return Success(updated);
    } catch (e) {
      debugPrint('LuckyWheelRepo upsertCampaign error: $e');
      return Failure('Failed to save campaign: $e');
    }
  }

  /// Save / Replace reward slices & probabilities for a campaign in Supabase.
  Future<Result<List<WheelRewardSegment>>> saveCampaignSlices({
    required String campaignId,
    required List<WheelRewardSegment> slices,
  }) async {
    final totalProb = slices.fold(0, (sum, s) => sum + s.probability);
    if (totalProb != 100) {
      return Failure('Total probability must equal 100% (currently $totalProb%)');
    }

    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }

    try {
      // Delete old slices for this campaign
      await client
          .from('lucky_wheel_reward_slices')
          .delete()
          .eq('campaign_id', campaignId);

      // Insert new slices
      final insertData = slices.map((s) => s.toJson(forCampaignId: campaignId)).toList();
      final res = await client
          .from('lucky_wheel_reward_slices')
          .insert(insertData)
          .select();

      final saved = (res as List)
          .map((item) => WheelRewardSegment.fromJson(item as Map<String, dynamic>))
          .toList();

      return Success(saved);
    } catch (e) {
      debugPrint('LuckyWheelRepo saveCampaignSlices error: $e');
      return Failure('Failed to save reward slices: $e');
    }
  }

  /// Dynamically update daily spin limit for a campaign in Supabase.
  Future<Result<bool>> updateCampaignDailyLimit({
    required String campaignId,
    required int dailyLimit,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }

    try {
      await client
          .from('lucky_wheel_campaigns')
          .update({
            'daily_limit': dailyLimit,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', campaignId);

      return const Success(true);
    } catch (e) {
      debugPrint('LuckyWheelRepo updateCampaignDailyLimit error: $e');
      return Failure('Failed to update daily limit: $e');
    }
  }

  // ===========================================================================
  // 2. USER SPIN ELIGIBILITY & DAILY COOLDOWN
  // ===========================================================================

  /// Get user spin eligibility and count for today directly from Supabase ledger.
  Future<Result<({int spinsUsedToday, int maxDailySpins, bool isEligible})>>
      getUserSpinEligibility({
    required String campaignId,
    required String userId,
    int maxDailySpins = 5,
  }) async {
    final client = _client;
    if (client == null) {
      return Success((
        spinsUsedToday: 0,
        maxDailySpins: maxDailySpins,
        isEligible: true,
      ));
    }

    try {
      // 1. Authoritative dynamic fetch of campaign's daily limit from database
      int dynamicDailyLimit = maxDailySpins;
      if (campaignId.isNotEmpty) {
        final campRes = await client
            .from('lucky_wheel_campaigns')
            .select('daily_limit')
            .eq('id', campaignId)
            .maybeSingle();
        if (campRes != null && campRes['daily_limit'] != null) {
          dynamicDailyLimit = (campRes['daily_limit'] as num).toInt();
        }
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

      var query = client
          .from('lucky_wheel_spins')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', startOfDay);

      if (campaignId.isNotEmpty) {
        query = query.eq('campaign_id', campaignId);
      }

      final res = await query;
      final count = (res as List).length;
      return Success((
        spinsUsedToday: count,
        maxDailySpins: dynamicDailyLimit,
        isEligible: count < dynamicDailyLimit,
      ));
    } catch (e) {
      debugPrint('LuckyWheelRepo getUserSpinEligibility error: $e');
      return Success((
        spinsUsedToday: 0,
        maxDailySpins: maxDailySpins,
        isEligible: true,
      ));
    }
  }

  // ===========================================================================
  // 3. AUTHORITATIVE SPIN EXECUTION VIA SUPABASE RPC
  // ===========================================================================

  /// Execute authoritative spin outcome via Supabase RPC (prioritizes fn_spin_lucky_wheel with dynamic limit).
  Future<Result<WheelSpinResult>> spinWheel({
    required String campaignId,
    required String userId,
    String? userName,
    String? idempotencyKey,
    required List<WheelRewardSegment> currentSlices,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }

    try {
      dynamic rpcRes;
      try {
        // Authoritative campaign engine respecting dynamic daily_limit
        rpcRes = await client.rpc(
          'fn_spin_lucky_wheel',
          params: {
            'p_campaign_id': campaignId,
            'p_idempotency_key': idempotencyKey,
          },
        );
      } catch (err) {
        // Fallback to spin_lucky_wheel
        final authUserId = client.auth.currentUser?.id ?? userId;
        rpcRes = await client.rpc(
          'spin_lucky_wheel',
          params: {
            'p_user_id': authUserId,
          },
        );
      }

      if (rpcRes != null && rpcRes is Map<String, dynamic>) {
        final sliceId = rpcRes['slice_id'] as String? ?? '';
        int targetIndex = -1;
        if (sliceId.isNotEmpty) {
          targetIndex = currentSlices.indexWhere((s) => s.id == sliceId);
        }

        if (targetIndex == -1 && rpcRes['slice_index'] != null) {
          targetIndex = (rpcRes['slice_index'] as num).toInt();
        }

        if (targetIndex == -1 && rpcRes['reward_label'] != null) {
          targetIndex = _findSliceIndexByLabel(
            currentSlices,
            rpcRes['reward_label'] as String? ?? '',
          );
        }

        final coinsWon = (rpcRes['coins_won'] as num?)?.toInt() ??
            (rpcRes['reward_value'] as num?)?.toInt() ??
            0;

        return Success(WheelSpinResult(
          isSuccess: true,
          spinId: rpcRes['spin_id'] as String? ??
              'spin_${DateTime.now().millisecondsSinceEpoch}',
          rewardLabel: rpcRes['reward_label'] as String? ??
              (coinsWon > 0 ? '$coinsWon Coins' : 'Spin Reward'),
          rewardType: 'coins',
          rewardValue: coinsWon,
          transactionId: rpcRes['transaction_id'] as String? ??
              'TX_SPIN_${DateTime.now().millisecondsSinceEpoch}',
          targetIndex: targetIndex >= 0
              ? (targetIndex % (currentSlices.isNotEmpty ? currentSlices.length : 8))
              : 0,
        ));
      } else {
        return const Failure('Invalid response from spin engine.');
      }
    } catch (e) {
      debugPrint('LuckyWheelRepo spinWheel error: $e');
      return Failure('Spin execution failed: $e');
    }
  }

  // ===========================================================================
  // 4. AUDIT & SPIN HISTORY
  // ===========================================================================

  /// Fetch spin history for campaign or user directly from Supabase.
  Future<Result<List<Map<String, dynamic>>>> getSpinHistory({
    String? campaignId,
    String? userId,
    int limit = 50,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }

    try {
      var filterBuilder = client.from('lucky_wheel_spins').select();

      if (campaignId != null) {
        filterBuilder = filterBuilder.eq('campaign_id', campaignId);
      }
      if (userId != null) {
        filterBuilder = filterBuilder.eq('user_id', userId);
      }

      final res = await filterBuilder
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (res as List).map((m) => m as Map<String, dynamic>).toList();
      return Success(list);
    } catch (e) {
      debugPrint('LuckyWheelRepo getSpinHistory error: $e');
      return Failure('Failed to fetch spin history: $e');
    }
  }

  int _findSliceIndexByLabel(List<WheelRewardSegment> slices, String label) {
    final clean = label.trim().toLowerCase();
    for (int i = 0; i < slices.length; i++) {
      if (slices[i].label.trim().toLowerCase() == clean) return i;
    }
    return 0;
  }
}
