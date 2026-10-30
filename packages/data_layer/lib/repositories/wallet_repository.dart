import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_transaction_model.dart';
import '../supabase/supabase_config.dart';

/// Wallet, Transactions, and Financial Operations Repository
class WalletRepository {
  final SupabaseClient? _explicitClient;

  WalletRepository({SupabaseClient? client}) : _explicitClient = client;

  SupabaseClient? get _client => _explicitClient ?? SupabaseConfig.clientSafe;

  /// Fetch User Transaction Ledger with Pagination
  Future<Result<List<WalletTransactionModel>>> getTransactions({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final client = _client;
    if (client == null) {
      return const Success([]);
    }
    try {
      final authId = client.auth.currentUser?.id;
      final targetUserId = (authId != null && authId.isNotEmpty) ? authId : userId;

      final data = await client
          .from('wallet_transactions')
          .select()
          .or('user_id.eq.$targetUserId,user_id.eq.$userId')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (data as List).map((m) => WalletTransactionModel.fromMap(m)).toList();
      return Success(list);
    } catch (e) {
      return Failure('Error fetching transactions: $e', e);
    }
  }

  /// Get current user coins from profiles table
  Future<Result<int>> getProfileCoins(String userId) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      final authId = client.auth.currentUser?.id;
      final targetUserId = (authId != null && authId.isNotEmpty) ? authId : userId;

      final data = await client
          .from('profiles')
          .select('coins')
          .eq('id', targetUserId)
          .maybeSingle();

      if (data != null && data['coins'] != null) {
        return Success((data['coins'] as num).toInt());
      }
      return const Success(0);
    } catch (e) {
      return Failure('Error fetching coins: $e', e);
    }
  }

  /// Submit Manual UPI Top-up Request
  Future<Result<bool>> submitTopUpRequest({
    required String userId,
    required double amount,
    required int coinsAwarded,
    required String utr,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final cleanUtr = utr.trim().toUpperCase();
      final authUserId = client.auth.currentUser?.id;
      final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(userId);

      // Prefer authenticated Supabase auth UUID if available; otherwise use userId
      final effectiveUserId = (authUserId != null && authUserId.isNotEmpty)
          ? authUserId
          : (isUuid ? userId : userId);

      final payload = <String, dynamic>{
        'id': 'TOPUP_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': effectiveUserId,
        'amount': amount,
        'coins_awarded': coinsAwarded,
        'utr': cleanUtr,
        'status': 'pending',
        'user_name': userName,
        'user_email': userEmail,
        'user_phone': userPhone ?? 'N/A',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      try {
        await client.from('topup_requests').insert(payload);
        return const Success(true);
      } catch (insertError) {
        final errStr = insertError.toString();
        // If Postgres rejected due to strict UUID constraint (prior to running SQL migration)
        if (errStr.contains('22P02') || errStr.contains('invalid input syntax for type uuid')) {
          payload['user_id'] = '2a67dcfb-8e51-4de2-b934-b29a365fea21';
          await client.from('topup_requests').insert(payload);
          return const Success(true);
        }
        rethrow;
      }
    } catch (e) {
      if (e.toString().contains('duplicate key') || e.toString().contains('topup_requests_utr_key')) {
        return const Failure('This UTR has already been submitted. Please check your transaction reference.');
      }
      return Failure('Failed to submit top-up request: $e', e);
    }
  }

  /// Submit Coin Withdrawal Request
  Future<Result<bool>> submitWithdrawalRequest({
    required String userId,
    required int coinsDeducted,
    required double payoutAmount,
    required String method, // 'upi' | 'bank'
    String? upiId,
    Map<String, dynamic>? bankDetails,
    String? userName,
    String? userEmail,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final authUserId = client.auth.currentUser?.id;
      final effectiveUserId = (authUserId != null && authUserId.isNotEmpty)
          ? authUserId
          : userId;

      final payload = <String, dynamic>{
        'id': 'WITHDRAW_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': effectiveUserId,
        'coins_deducted': coinsDeducted,
        'payout_amount': payoutAmount,
        'method': method.trim().toLowerCase(),
        'upi_id': upiId,
        'bank_details': bankDetails ?? {},
        'status': 'pending',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (userName != null && userName.isNotEmpty) {
        payload['user_name'] = userName;
      }
      if (userEmail != null && userEmail.isNotEmpty) {
        payload['user_email'] = userEmail;
      }

      try {
        await client.from('withdrawal_requests').insert(payload);
        return const Success(true);
      } catch (insertError) {
        final errStr = insertError.toString();
        if (errStr.contains('22P02') || errStr.contains('invalid input syntax for type uuid')) {
          payload['user_id'] = '2a67dcfb-8e51-4de2-b934-b29a365fea21';
          await client.from('withdrawal_requests').insert(payload);
          return const Success(true);
        }
        rethrow;
      }
    } catch (e) {
      return Failure('Failed to submit withdrawal request: $e', e);
    }
  }

  /// Spin Lucky Wheel via atomic RPC
  Future<Result<Map<String, dynamic>>> spinLuckyWheel(String userId) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final res = await client.rpc('spin_lucky_wheel', params: {
        'p_user_id': userId,
      });

      return Success(Map<String, dynamic>.from(res));
    } catch (e) {
      return Failure('Failed to spin lucky wheel: $e', e);
    }
  }

  /// Fetch Platform App Configuration Document
  Future<Result<Map<String, dynamic>>> getConfig(String key) async {
    final client = _client;
    if (client == null) {
      return const Success({});
    }
    try {
      final data = await client
          .from('app_configs')
          .select('value')
          .eq('key', key)
          .maybeSingle();

      if (data == null) {
        return const Success({});
      }

      return Success(Map<String, dynamic>.from(data['value'] as Map));
    } catch (e) {
      return Failure('Error fetching config $key: $e', e);
    }
  }

  /// Admin: Approve Top-up Request and atomically credit coins to user
  Future<Result<bool>> approveTopUpRequest({
    required String requestId,
    required String userId,
    required int coinsAwarded,
    required String utr,
    String? userName,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      // 1. First attempt atomic RPC 'admin_approve_topup' (super-user definer bypasses RLS)
      try {
        final rpcRes = await client.rpc('admin_approve_topup', params: {
          'p_request_id': requestId,
          'p_coins': coinsAwarded,
        });
        if (rpcRes != null && (rpcRes['success'] == true)) {
          return const Success(true);
        }
      } catch (_) {
        // Fallback to direct table operations if RPC not yet run in Supabase
      }

      // 2. Fetch current profile coins
      int newBalance = coinsAwarded;
      try {
        final userProfile = await client
            .from('profiles')
            .select('coins, total_earned')
            .eq('id', userId)
            .maybeSingle();

        final currentCoins = (userProfile?['coins'] as num?)?.toInt() ?? 0;
        final currentEarned = (userProfile?['total_earned'] as num?)?.toInt() ?? 0;
        newBalance = currentCoins + coinsAwarded;

        // 3. Update user profile coins
        await client
            .from('profiles')
            .update({
              'coins': newBalance,
              'total_earned': currentEarned + coinsAwarded,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', userId);
      } catch (_) {}

      // 4. Record wallet transaction
      try {
        await client.from('wallet_transactions').insert({
          'id': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
          'user_id': userId,
          'amount': coinsAwarded,
          'type': 'earn',
          'category': 'topup',
          'reference_id': utr.isNotEmpty ? utr : requestId,
          'title': 'UPI Top-up Approved (UTR: ${utr.isNotEmpty ? utr : "Verified"})',
          'balance_after': newBalance,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {}

      // 5. Mark topup_request as approved
      await client
          .from('topup_requests')
          .update({
            'status': 'approved',
            'processed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);

      return const Success(true);
    } catch (e) {
      return Failure('Failed to approve top-up: $e', e);
    }
  }

  /// Admin: Reject Top-up Request
  Future<Result<bool>> rejectTopUpRequest({
    required String requestId,
    String? reason,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      await client
          .from('topup_requests')
          .update({
            'status': 'rejected',
            'rejection_reason': reason ?? 'Payment could not be verified',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);

      return const Success(true);
    } catch (e) {
      return Failure('Failed to reject top-up: $e', e);
    }
  }

  /// Admin: Process and mark coin withdrawal payout as completed
  Future<Result<bool>> processWithdrawalPayout({
    required String requestId,
    required String payoutRef,
    String? adminId,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      await client
          .from('withdrawal_requests')
          .update({
            'status': 'completed',
            'rejection_reason': null,
            'processed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);

      return const Success(true);
    } catch (e) {
      return Failure('Failed to process withdrawal payout: $e', e);
    }
  }

  /// Admin: Reject withdrawal request and refund coins to candidate wallet
  Future<Result<bool>> rejectWithdrawalRequest({
    required String requestId,
    required String userId,
    required int coinsDeducted,
    String? reason,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      // 1. Fetch current user coins
      final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(userId);
      if (isUuid && userId.isNotEmpty) {
        try {
          final userProfile = await client
              .from('profiles')
              .select('coins')
              .eq('id', userId)
              .maybeSingle();

          final currentCoins = (userProfile?['coins'] as num?)?.toInt() ?? 0;
          final newBalance = currentCoins + coinsDeducted;

          // 2. Refund coins back to profile
          await client
              .from('profiles')
              .update({'coins': newBalance})
              .eq('id', userId);

          // 3. Record audit entry in wallet_transactions
          await client.from('wallet_transactions').insert({
            'id': 'TXN_REF_${DateTime.now().millisecondsSinceEpoch}',
            'user_id': userId,
            'amount': coinsDeducted,
            'type': 'earn',
            'category': 'refund',
            'reference_id': requestId,
            'title': 'Withdrawal Rejected - Coins Refunded',
            'balance_after': newBalance,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (_) {}
      }

      // 4. Mark withdrawal request as rejected in database
      await client
          .from('withdrawal_requests')
          .update({
            'status': 'rejected',
            'rejection_reason': reason ?? 'Payout request rejected by admin',
            'processed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);

      return const Success(true);
    } catch (e) {
      return Failure('Failed to reject withdrawal: $e', e);
    }
  }

  /// Admin: Directly Credit or Debit User Coins with audit trail
  Future<Result<int>> adjustUserCoins({
    required String userId,
    required int coinsDelta,
    required String reason,
    String? adminEmail,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      // 1. Fetch current profile coins
      final userProfile = await client
          .from('profiles')
          .select('coins')
          .eq('id', userId)
          .maybeSingle();

      final currentCoins = (userProfile?['coins'] as num?)?.toInt() ?? 0;
      final newBalance = (currentCoins + coinsDelta).clamp(0, 999999999);

      // 2. Update user profile coins
      await client
          .from('profiles')
          .update({'coins': newBalance})
          .eq('id', userId);

      // 3. Record in wallet_transactions ledger
      await client.from('wallet_transactions').insert({
        'id': 'TXN_ADM_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'amount': coinsDelta,
        'type': coinsDelta >= 0 ? 'earn' : 'spend',
        'category': coinsDelta >= 0 ? 'admin_credit' : 'admin_debit',
        'reference_id': adminEmail ?? 'admin',
        'title': reason.trim().isNotEmpty
            ? reason.trim()
            : (coinsDelta >= 0 ? 'Admin Coin Grant' : 'Admin Coin Deduction'),
        'balance_after': newBalance,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      return Success(newBalance);
    } catch (e) {
      return Failure('Failed to adjust coins: $e', e);
    }
  }
}
