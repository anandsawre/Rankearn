import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_transaction_model.dart';
import '../supabase/supabase_config.dart';

/// Wallet, Transactions, and Financial Operations Repository
class WalletRepository {
  final SupabaseClient _client;

  WalletRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// Fetch User Transaction Ledger with Pagination
  Future<Result<List<WalletTransactionModel>>> getTransactions({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from('wallet_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (data as List).map((m) => WalletTransactionModel.fromMap(m)).toList();
      return Success(list);
    } catch (e) {
      return Failure('Error fetching transactions: $e', e);
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
    try {
      final cleanUtr = utr.trim().toUpperCase();

      await _client.from('topup_requests').insert({
        'id': 'TOPUP_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'amount': amount,
        'coins_awarded': coinsAwarded,
        'utr': cleanUtr,
        'status': 'pending',
        'user_name': userName,
        'user_email': userEmail,
        'user_phone': userPhone ?? 'N/A',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      return const Success(true);
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
  }) async {
    try {
      await _client.from('withdrawal_requests').insert({
        'id': 'WITHDRAW_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'coins_deducted': coinsDeducted,
        'payout_amount': payoutAmount,
        'method': method,
        'upi_id': upiId,
        'bank_details': bankDetails ?? {},
        'status': 'pending',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      return const Success(true);
    } catch (e) {
      return Failure('Failed to submit withdrawal request: $e', e);
    }
  }

  /// Spin Lucky Wheel via atomic RPC
  Future<Result<Map<String, dynamic>>> spinLuckyWheel(String userId) async {
    try {
      final res = await _client.rpc('spin_lucky_wheel', params: {
        'p_user_id': userId,
      });

      return Success(Map<String, dynamic>.from(res));
    } catch (e) {
      return Failure('Failed to spin lucky wheel: $e', e);
    }
  }

  /// Fetch Platform App Configuration Document
  Future<Result<Map<String, dynamic>>> getConfig(String key) async {
    try {
      final data = await _client
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
}
