import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
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
    return showDialog(
      context: context,
      barrierDismissible: false,
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header with Close
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: Color(0xFFF59E0B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Manage User Coins',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF101A3A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Credit rewards or deduct coins with audit ledger logging',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),

                  // 2. Target User Card with Live Balance
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  const SizedBox(height: 18),

                  // 3. Operation Toggle: Credit (+) vs Debit (-)
                  const Text(
                    'Operation Type',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isCredit = true),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isCredit ? const Color(0xFFECFDF5) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isCredit ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                                width: _isCredit ? 2 : 1,
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
                                const SizedBox(width: 6),
                                Text(
                                  'Credit Coins (+)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
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
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isCredit ? const Color(0xFFFEF2F2) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !_isCredit ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                                width: !_isCredit ? 2 : 1,
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
                                const SizedBox(width: 6),
                                Text(
                                  'Debit Coins (-)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
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
                  const SizedBox(height: 18),

                  // 4. Coin Amount Input
                  const Text(
                    'Coin Amount',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
                    decoration: InputDecoration(
                      hintText: 'Enter coin amount (e.g. 500)',
                      prefixIcon: const Icon(Icons.toll_rounded, color: Color(0xFFF59E0B)),
                      suffixText: 'Coins',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                      ),
                    ),
                    validator: (v) {
                      final val = int.tryParse(v?.trim() ?? '');
                      if (val == null || val <= 0) {
                        return 'Please enter a valid positive coin amount';
                      }
                      if (!_isCredit && val > widget.user.coins) {
                        return 'Cannot deduct more than current balance (${widget.user.coins} Coins)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Quick Amount Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _quickAmounts.map((amt) {
                      final isSelected = _amountController.text.trim() == amt.toString();
                      return InkWell(
                        onTap: () {
                          _amountController.text = amt.toString();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6B4EFF) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6B4EFF) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Text(
                            '+$amt',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 5. Reason / Remark Input
                  const Text(
                    'Reason / Purpose',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Contest Reward, Goodwill Compensation',
                      prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF64748B)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
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
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            r,
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 6. Projected Balance Preview
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
                  const SizedBox(height: 22),

                  // 7. Actions (Cancel & Confirm)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitAdjustment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
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
                                  Text(_isCredit ? 'Credit Coins' : 'Deduct Coins'),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
