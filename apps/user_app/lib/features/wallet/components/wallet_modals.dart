import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'wallet_icons.dart';
import 'buy_coins_modal.dart';

class WalletModals {
  WalletModals._();

  /// "Buy Coins / Top-up" Modal Dialog / BottomSheet
  static void showBuyCoinsModal(
    BuildContext context, {
    required UserProfile profile,
    VoidCallback? onTopUpSubmitted,
  }) {
    BuyCoinsModal.show(
      context,
      profile: profile,
      onTopUpSubmitted: onTopUpSubmitted,
    );
  }

  /// "How It Works" Explanation Dialog
  static void showHowItWorksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          actionsPadding: const EdgeInsets.all(20),
          title: Row(
            children: const [
              Icon(
                Icons.help_outline_rounded,
                color: AppColors.walletPrimaryGreen,
                size: 26,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'How Wallet Works',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.walletNavy,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHowItWorksItem(
                  icon: Icons.monetization_on_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'Coin Value & Rate',
                  description:
                      '1 Coin = ₹0.10 INR. 1,000 Coins equal ₹100 real money withdrawable directly to your UPI ID.',
                ),
                const SizedBox(height: 12),
                _buildHowItWorksItem(
                  icon: Icons.military_tech_rounded,
                  color: const Color(0xFF00B96B),
                  title: 'How to Earn Coins',
                  description:
                      'Score top ranks in Full Mock Tests, win 1v1 Battle Arenas, spin the daily lucky fortune wheel, and complete daily study tasks.',
                ),
                const SizedBox(height: 12),
                _buildHowItWorksItem(
                  icon: Icons.account_balance_rounded,
                  color: const Color(0xFF2587F8),
                  title: 'Fast UPI Withdrawals',
                  description:
                      'Minimum withdrawal is 1,000 Coins (₹100). Payouts are credited directly to your bank account via UPI within 24 hours.',
                ),
                const SizedBox(height: 12),
                _buildHowItWorksItem(
                  icon: Icons.card_giftcard_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: 'Referral Rewards',
                  description:
                      'Invite friends using your unique referral code. Earn 200 coins immediately once your friend joins!',
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.walletPrimaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Got It',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildHowItWorksItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.walletNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.walletSecondaryText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Refer & Earn Modal Dialog
  static void showReferralModal(
    BuildContext context, {
    required String referralCode,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F3FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Invite Friends & Earn Coins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.walletNavy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Share your unique code with your fellow aspirants. You will earn 200 Coins for every successful registration!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.walletSecondaryText,
                ),
              ),
              const SizedBox(height: 20),

              // Code Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDDD6FE),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR REFERRAL CODE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.walletSecondaryText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          referralCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF8B5CF6),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Referral code copied to clipboard!'),
                            backgroundColor: Color(0xFF8B5CF6),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            'Join Rankearn using my referral code $referralCode and earn coins to win cash prizes! https://rankearn.in/join?ref=$referralCode',
                      ),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral link copied to clipboard!'),
                        backgroundColor: Color(0xFF8B5CF6),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text(
                    'Share Invite Link',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.walletPrimaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Redeem Offers & Coupons Modal
  static void showRedeemOffersModal(
    BuildContext context, {
    required int userCoins,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Redeem Coin Rewards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.walletNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6D8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const RankearnCurrencyCoin(size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$userCoins Coins',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8D5B00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildOfferTile(
                context,
                title: 'BPSC Prelims Mock Series Pass',
                description: 'Unlock 15 Premium Full Mocks with solutions',
                coinsRequired: 500,
                userCoins: userCoins,
              ),
              const SizedBox(height: 12),
              _buildOfferTile(
                context,
                title: 'Mega Contest Free Entry Pass',
                description: 'Enter any ₹50 prize league with zero cash',
                coinsRequired: 300,
                userCoins: userCoins,
              ),
              const SizedBox(height: 12),
              _buildOfferTile(
                context,
                title: '1-Month Pro Subscription',
                description: 'Unlimited 1v1 battles & detailed analytics',
                coinsRequired: 1500,
                userCoins: userCoins,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildOfferTile(
    BuildContext context, {
    required String title,
    required String description,
    required int coinsRequired,
    required int userCoins,
  }) {
    final canAfford = userCoins >= coinsRequired;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.walletBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: Color(0xFF7C3AED),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.walletNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.walletSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (canAfford) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Offer redeemed successfully! $coinsRequired Coins used.',
                    ),
                    backgroundColor: AppColors.walletPrimaryGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Need $coinsRequired Coins to redeem this offer.',
                    ),
                    backgroundColor: AppColors.walletErrorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford
                  ? AppColors.walletPrimaryGreen
                  : Colors.grey.shade300,
              foregroundColor: canAfford ? Colors.white : Colors.grey.shade600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '$coinsRequired Coins',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Transaction Details Dialog
  static void showTransactionDetails(
    BuildContext context,
    WalletTransactionModel tx,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final isPositive = tx.amount > 0 || tx.type == 'earn';
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFE8FDF2)
                      : const Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isPositive
                      ? AppColors.walletPrimaryGreen
                      : AppColors.walletErrorRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.walletNavy,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Transaction ID', tx.id),
              _detailRow(
                'Coins Change',
                '${isPositive ? "+" : "-"}${tx.amount.abs()} Coins',
              ),
              _detailRow(
                'INR Value',
                '≈ ₹${(tx.amount.abs() * 0.10).toStringAsFixed(2)}',
              ),
              _detailRow('Balance After', '${tx.balanceAfter} Coins'),
              _detailRow('Category', tx.category),
              _detailRow(
                'Date & Time',
                tx.createdAt.toLocal().toString().split('.').first,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.walletSecondaryText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.walletNavy,
            ),
          ),
        ],
      ),
    );
  }
}
