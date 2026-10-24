import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'withdrawal_panel_web.dart';

export 'withdrawal_panel_web.dart';

/// True on Web platform builds.
const bool isWithdrawalSupported = true;

/// Opens the mobile/desktop bottom sheet modal containing the WithdrawalPanel.
void openWithdrawalModal(
  BuildContext context, {
  required int userCoins,
  required Future<bool> Function({
    required int coins,
    required double payoutAmount,
    required String upiId,
  }) onWithdraw,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (modalContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(modalContext).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            WithdrawalPanel(
              userCoins: userCoins,
              onWithdraw: (
                {required coins, required payoutAmount, required upiId}
              ) async {
                final ok = await onWithdraw(
                  coins: coins,
                  payoutAmount: payoutAmount,
                  upiId: upiId,
                );
                if (ok && modalContext.mounted) {
                  Navigator.pop(modalContext);
                }
                return ok;
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Dispatches the real withdrawal request to the backend database.
Future<bool> executeWithdrawal({
  required String userId,
  required int coins,
  required String upiId,
  required double payoutAmount,
}) async {
  try {
    final res = await WalletRepository().submitWithdrawalRequest(
      userId: userId,
      coinsDeducted: coins,
      payoutAmount: payoutAmount,
      method: 'upi',
      upiId: upiId,
    );
    return res is Success<bool>;
  } catch (e) {
    debugPrint('executeWithdrawal error: $e');
    return false;
  }
}
