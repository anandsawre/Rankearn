import 'package:flutter/widgets.dart';

/// Disabled on Android / iOS APK/AAB native platform builds.
const bool isWithdrawalSupported = false;

/// Stub component for native builds. Zero-footprint, renders nothing.
class WithdrawalPanel extends StatelessWidget {
  final int userCoins;
  final dynamic onWithdraw;

  const WithdrawalPanel({
    super.key,
    required this.userCoins,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Stub modal opener for native builds. No-op.
void openWithdrawalModal(
  BuildContext context, {
  required int userCoins,
  dynamic onWithdraw,
}) {}

/// Stub withdrawal dispatcher for native builds. No-op.
Future<bool> executeWithdrawal({
  required String userId,
  required int coins,
  required String upiId,
  required double payoutAmount,
}) async => false;
