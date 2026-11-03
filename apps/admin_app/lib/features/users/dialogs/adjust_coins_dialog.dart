import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

/// Modal dialog for Admin to directly Credit (+) or Debit (-) Coins from a user's wallet.
/// Persists directly to Supabase profiles & records audit entry in wallet_transactions.
class AdjustCoinsDialog extends StatefulWidget {
  final UserManagementItem user;
  final ValueChanged<int>? onCoinsUpdated;

  const AdjustCoinsDialog({
    super.key,
    required this.user,
    this.onCoinsUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required UserManagementItem user,
    ValueChanged<int>? onCoinsUpdated,
  }) {
    return AppModalDialog.show(
      context: context,
      builder: (_) => AdjustCoinsDialog(
        user: user,
        onCoinsUpdated: onCoinsUpdated,
      ),
    );
  }

  @override
  State<AdjustCoinsDialog> createState() => _AdjustCoinsDialogState();
}

class _AdjustCoinsDialogState extends State<AdjustCoinsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final WalletRepository _walletRepo = WalletRepository();

  bool _isCredit = true; // true = Credit (+), false = Debit (-)
  bool _isLoading = false;

  final List<int> _quickAmounts = [50, 100, 250, 500, 1000, 2500, 5000];

  final List<String> _quickReasons = [
    'Welcome Gift',
    'Contest Winner Reward',
    'Referral Bonus Credit',
    'Technical Compensation',
    'Special Admin Bonus',
    'Account Balance Correction',
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = '100';
    _reasonController.text = 'Special Admin Bonus';
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  int get _parsedAmount {
    return int.tryParse(_amountController.text.trim()) ?? 0;
  }

  int get _projectedBalance {
    final delta = _isCredit ? _parsedAmount : -_parsedAmount;
    final res = widget.user.coins + delta;
    return res < 0 ? 0 : res;
  }

  Future<void> _submitAdjustment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parsedAmount;
    if (amount <= 0) return;

    final delta = _isCredit ? amount : -amount;
    final reason = _reasonController.text.trim().isEmpty
        ? (_isCredit ? 'Admin Coin Credit' : 'Admin Coin Deduction')
        : _reasonController.text.trim();

    setState(() => _isLoading = true);

    final res = await _walletRepo.adjustUserCoins(
      userId: widget.user.id,
      coinsDelta: delta,
      reason: reason,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (res) {
      case Success(data: final newBalance):
        widget.onCoinsUpdated?.call(newBalance);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
            content: Row(
              children: [
                Icon(
                  _isCredit ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isCredit
                        ? 'Successfully credited $amount coins to ${widget.user.name}! (New Balance: $newBalance)'
                        : 'Successfully debited $amount coins from ${widget.user.name}! (New Balance: $newBalance)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      case Failure(message: final msg):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Failed: $msg'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Manage User Coins',
      subtitle: 'Credit rewards or deduct coins with audit ledger logging',
      iconData: Icons.monetization_on_rounded,
      gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      maxWidth: 520,
      maxHeight: 740,
      scrollable: true,
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitAdjustment,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isCredit ? Icons.add_rounded : Icons.remove_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(_isCredit ? 'Credit Coins' : 'Deduct Coins', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target User Card with Live Balance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF6B4EFF).withValues(alpha: 0.15),
                    child: Text(
                      widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6B4EFF)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101A3A),
                          ),
                        ),
                        Text(
                          widget.user.email,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10194F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC928), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.user.coins} Coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operation Type Toggle
            const Text(
              'Operation Type',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isCredit = true),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isCredit ? const Color(0xFFECFDF5) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isCredit ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                          width: _isCredit ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_rounded,
                            size: 18,
                            color: _isCredit ? const Color(0xFF059669) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Credit (+)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _isCredit ? FontWeight.w800 : FontWeight.w600,
                              color: _isCredit ? const Color(0xFF059669) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isCredit = false),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isCredit ? const Color(0xFFFEF2F2) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !_isCredit ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                          width: !_isCredit ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_circle_rounded,
                            size: 18,
                            color: !_isCredit ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Debit (-)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: !_isCredit ? FontWeight.w800 : FontWeight.w600,
                              color: !_isCredit ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Coin Amount Input
            const Text(
              'Amount of Coins *',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
              decoration: InputDecoration(
                hintText: 'Enter coin amount',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter coins';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Must be a positive number';
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Quick Amount Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickAmounts.map((amt) {
                final isSelected = _parsedAmount == amt;
                return InkWell(
                  onTap: () => setState(() => _amountController.text = amt.toString()),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      '+$amt',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFFB45309) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Reason / Audit Note
            const Text(
              'Audit Note / Reason *',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _reasonController,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: 'e.g. Winner of Weekly Battle #42',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.history_edu_rounded, color: Color(0xFF64748B), size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please provide a brief reason for audit logging';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Quick Reason Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickReasons.map((r) {
                return InkWell(
                  onTap: () => setState(() => _reasonController.text = r),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      r,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Projected Balance Preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isCredit ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isCredit ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current: ${widget.user.coins}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  Row(
                    children: [
                      Text(
                        _isCredit ? '+$_parsedAmount' : '-$_parsedAmount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                      const Text(' ➔ ', style: TextStyle(color: Color(0xFF94A3B8))),
                      Text(
                        'New: $_projectedBalance Coins',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _isCredit ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
