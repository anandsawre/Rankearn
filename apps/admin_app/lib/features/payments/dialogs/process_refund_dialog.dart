import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/payment_item.dart';

class ProcessRefundDialog extends StatefulWidget {
  final PaymentItem? initialPayment;
  final List<PaymentItem> availablePayments;
  final Future<void> Function(PaymentItem payment, double refundAmount, String reason) onConfirmRefund;

  const ProcessRefundDialog({
    super.key,
    this.initialPayment,
    required this.availablePayments,
    required this.onConfirmRefund,
  });

  @override
  State<ProcessRefundDialog> createState() => _ProcessRefundDialogState();
}

class _ProcessRefundDialogState extends State<ProcessRefundDialog> {
  final _formKey = GlobalKey<FormState>();
  late PaymentItem? _selectedPayment;
  late TextEditingController _amountController;
  late TextEditingController _reasonController;
  bool _isFullRefund = true;
  bool _isSubmitting = false;
  String _selectedReason = 'User Request';

  static const List<String> _refundReasons = [
    'User Request',
    'Accidental Double Payment',
    'Technical Glitch during Quiz/Contest',
    'Tournament Cancelled',
    'Dissatisfaction / Quality Issue',
    'Fraudulent Transaction',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPayment = widget.initialPayment ??
        (widget.availablePayments.isNotEmpty ? widget.availablePayments.first : null);
    _amountController = TextEditingController(
      text: _selectedPayment != null ? _selectedPayment!.amount.toInt().toString() : '0',
    );
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onPaymentChanged(PaymentItem? p) {
    if (p == null) return;
    setState(() {
      _selectedPayment = p;
      if (_isFullRefund) {
        _amountController.text = p.amount.toInt().toString();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedPayment == null) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final reason = _selectedReason == 'Other' ? _reasonController.text : _selectedReason;

    setState(() => _isSubmitting = true);
    try {
      await widget.onConfirmRefund(_selectedPayment!, amount, reason);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refund of ₹${amount.toInt()} initiated successfully for ${_selectedPayment!.transactionId}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refund error: $e'), backgroundColor: const Color(0xFFDC2626)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0084FF).withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.replay_rounded, color: Color(0xFF0084FF), size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Process Refund',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                                ),
                                Text(
                                  'Issue a secure full or partial refund to user',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.borderSubtle),

                // Select Transaction dropdown if multiple
                const Text('Select Transaction', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentItem>(
                      value: _selectedPayment,
                      isExpanded: true,
                      onChanged: _onPaymentChanged,
                      items: widget.availablePayments.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.userName} — ₹${p.amount.toInt()} (${p.transactionId}) [${p.status.label}]',
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Full vs Partial Radio
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isFullRefund = true;
                            if (_selectedPayment != null) {
                              _amountController.text = _selectedPayment!.amount.toInt().toString();
                            }
                          });
                        },
                        child: Row(
                          children: [
                            // ignore: deprecated_member_use
                            Radio<bool>(
                              value: true,
                              // ignore: deprecated_member_use
                              groupValue: _isFullRefund,
                              // ignore: deprecated_member_use
                              onChanged: (val) {
                                setState(() {
                                  _isFullRefund = true;
                                  if (_selectedPayment != null) {
                                    _amountController.text = _selectedPayment!.amount.toInt().toString();
                                  }
                                });
                              },
                              // ignore: deprecated_member_use
                              activeColor: const Color(0xFF5636F5),
                            ),
                            const Text('Full Refund', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isFullRefund = false),
                        child: Row(
                          children: [
                            // ignore: deprecated_member_use
                            Radio<bool>(
                              value: false,
                              // ignore: deprecated_member_use
                              groupValue: _isFullRefund,
                              // ignore: deprecated_member_use
                              onChanged: (val) => setState(() => _isFullRefund = false),
                              // ignore: deprecated_member_use
                              activeColor: const Color(0xFF5636F5),
                            ),
                            const Text('Partial Refund', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Refund Amount Field
                TextFormField(
                  controller: _amountController,
                  enabled: !_isFullRefund,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Refund Amount (₹)',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: _isFullRefund ? const Color(0xFFF1F5F9) : Colors.white,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter refund amount';
                    final numVal = double.tryParse(val);
                    if (numVal == null || numVal <= 0) return 'Enter a valid amount';
                    if (_selectedPayment != null && numVal > _selectedPayment!.amount) {
                      return 'Cannot exceed original amount (₹${_selectedPayment!.amount.toInt()})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Reason dropdown
                const Text('Refund Reason', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReason,
                      isExpanded: true,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedReason = val);
                      },
                      items: _refundReasons.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                    ),
                  ),
                ),

                if (_selectedReason == 'Other') ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Specify Reason',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please specify reason' : null,
                  ),
                ],
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded, size: 16),
                      label: Text(_isSubmitting ? 'Processing...' : 'Confirm Refund'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
