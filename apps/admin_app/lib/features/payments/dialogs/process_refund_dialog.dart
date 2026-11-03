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
    return AppModalDialog(
      title: 'Process Refund',
      subtitle: 'Issue a secure full or partial refund to user',
      iconData: Icons.replay_rounded,
      gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
      maxWidth: 540,
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm Refund'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Select Transaction custom AppDropdown
            AppDropdown<PaymentItem>(
              label: 'Select Transaction',
              value: _selectedPayment,
              items: widget.availablePayments.map((p) {
                return AppDropdownItem(
                  value: p,
                  label: '${p.userName} — ₹${p.amount.toInt()} (${p.transactionId}) [${p.status.label}]',
                );
              }).toList(),
              onChanged: _onPaymentChanged,
            ),
            const SizedBox(height: 16),

            // Full vs Partial Radio
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
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
                          activeColor: const Color(0xFFFF9500),
                        ),
                        const Text('Full Refund', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
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
                          activeColor: const Color(0xFFFF9500),
                        ),
                        const Text('Partial Refund', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Refund Amount Field
            const Text(
              'Refund Amount (₹)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountController,
              enabled: !_isFullRefund,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: AppModalDialog.inputDecoration(
                '',
                prefixText: '₹ ',
                fillColor: _isFullRefund ? const Color(0xFFF1F5F9) : Colors.white,
                focusColor: AppColors.primary,
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
            AppDropdown<String>(
              label: 'Refund Reason',
              value: _selectedReason,
              items: _refundReasons.map((r) => AppDropdownItem(value: r, label: r)).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedReason = val);
              },
            ),

            if (_selectedReason == 'Other') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                decoration: AppModalDialog.inputDecoration(
                  '',
                  labelText: 'Specify Reason',
                  focusColor: AppColors.primary,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please specify reason' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
