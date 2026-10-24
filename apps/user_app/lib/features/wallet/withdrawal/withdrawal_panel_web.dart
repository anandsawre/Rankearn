import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../components/wallet_icons.dart';

class WithdrawalPreset {
  final int coins;
  final int rupees;

  const WithdrawalPreset({required this.coins, required this.rupees});
}

/// Web-Only Withdrawal Panel with UPI conversion and authentic NPCI brand asset.
class WithdrawalPanel extends StatefulWidget {
  final int userCoins;
  final Future<bool> Function({
    required int coins,
    required double payoutAmount,
    required String upiId,
  }) onWithdraw;

  const WithdrawalPanel({
    super.key,
    required this.userCoins,
    required this.onWithdraw,
  });

  @override
  State<WithdrawalPanel> createState() => _WithdrawalPanelState();
}

class _WithdrawalPanelState extends State<WithdrawalPanel> {
  static const List<WithdrawalPreset> presets = [
    WithdrawalPreset(coins: 1000, rupees: 100),
    WithdrawalPreset(coins: 2500, rupees: 250),
    WithdrawalPreset(coins: 5000, rupees: 500),
    WithdrawalPreset(coins: 10000, rupees: 1000),
  ];

  late int _selectedCoins;
  final TextEditingController _upiController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCoins = presets.first.coins;
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  bool _isValidUpi(String upi) {
    final trimmed = upi.trim();
    if (trimmed.isEmpty) return false;
    final upiRegex = RegExp(r'^[\w.\-_]{2,256}@[\w]{2,64}$');
    return upiRegex.hasMatch(trimmed);
  }

  Future<void> _handleWithdraw() async {
    setState(() => _errorMessage = null);
    final upiId = _upiController.text.trim();

    if (!_isValidUpi(upiId)) {
      setState(
        () => _errorMessage = 'Please enter a valid UPI ID (e.g. yourname@upi)',
      );
      return;
    }

    if (widget.userCoins < _selectedCoins) {
      setState(
        () => _errorMessage =
            'Insufficient coins. You have ${widget.userCoins} coins, but $_selectedCoins are required.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final payout = _selectedCoins * 0.10;
    final success = await widget.onWithdraw(
      coins: _selectedCoins,
      payoutAmount: payout,
      upiId: upiId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) {
      _upiController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.walletBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Icon + Title + Rate Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const UpiIconBadge(size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Withdraw to UPI',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.walletNavy,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Convert your coins to real money',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.walletSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6D8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Text(
                  '1 Coin = ₹0.10',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8D5B00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Presets 2x2 Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 10) / 2;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: presets.map((preset) {
                  final isSelected = _selectedCoins == preset.coins;
                  return InkWell(
                    onTap: () => setState(() => _selectedCoins = preset.coins),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: itemWidth,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8FDF2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.walletPrimaryGreen
                              : AppColors.walletBorder,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_formatCoins(preset.coins)} Coins',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF007A43)
                                  : AppColors.walletSecondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${preset.rupees}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? const Color(0xFF007A43)
                                  : AppColors.walletNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 14),

          // UPI ID Input Field
          TextField(
            controller: _upiController,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.walletNavy,
            ),
            decoration: InputDecoration(
              hintText: 'Enter UPI ID (e.g. yourname@upi)',
              hintStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.walletSecondaryText,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: UpiIconBadge(size: 18),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _errorMessage != null
                      ? AppColors.walletErrorRed
                      : AppColors.walletBorder,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _errorMessage != null
                      ? AppColors.walletErrorRed
                      : AppColors.walletBorder,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.walletPrimaryGreen,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.walletErrorRed,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.walletErrorRed,
                  width: 1.5,
                ),
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.walletErrorRed,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Withdraw Now Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.walletPrimaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Withdraw Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCoins(int amount) {
    if (amount >= 1000) {
      final s = amount.toString();
      final lastThree = s.substring(s.length - 3);
      final remaining = s.substring(0, s.length - 3);
      return '$remaining,$lastThree';
    }
    return amount.toString();
  }
}
