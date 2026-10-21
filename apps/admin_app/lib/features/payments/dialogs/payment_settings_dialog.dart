import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PaymentSettingsDialog extends StatefulWidget {
  const PaymentSettingsDialog({super.key});

  @override
  State<PaymentSettingsDialog> createState() => _PaymentSettingsDialogState();
}

class _PaymentSettingsDialogState extends State<PaymentSettingsDialog> {
  bool _isLiveMode = true;
  bool _enableRazorpay = true;
  bool _enableUpiDirect = true;
  bool _autoRefundCancelled = true;

  late final TextEditingController _upiVpaController;
  late final TextEditingController _razorpayKeyController;

  @override
  void initState() {
    super.initState();
    _upiVpaController = TextEditingController(text: 'rankearn.pay@icici');
    _razorpayKeyController = TextEditingController(text: 'rzp_live_948210491823');
  }

  @override
  void dispose() {
    _upiVpaController.dispose();
    _razorpayKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                            color: const Color(0xFFF43F5E).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.settings_outlined, color: Color(0xFFF43F5E), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Settings',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                              ),
                              Text(
                                'Configure payment gateways, webhooks & transaction behavior',
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

              // Live / Sandbox Mode Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLiveMode ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _isLiveMode ? const Color(0xFF10B981) : const Color(0xFFFF9F0A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLiveMode ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                          color: _isLiveMode ? const Color(0xFF10B981) : const Color(0xFFFF9F0A),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLiveMode ? 'Production / Live Mode Active' : 'Test / Sandbox Mode Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _isLiveMode ? const Color(0xFF065F46) : const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isLiveMode,
                      onChanged: (val) => setState(() => _isLiveMode = val),
                      // ignore: deprecated_member_use
                      activeColor: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Razorpay Public Key
              const Text('Razorpay Public Key ID', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              TextField(
                controller: _razorpayKeyController,
                decoration: InputDecoration(
                  hintText: 'rzp_live_...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 12),

              // UPI VPA
              const Text('UPI Direct Merchant VPA', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              TextField(
                controller: _upiVpaController,
                decoration: InputDecoration(
                  hintText: 'merchant@bank',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 14),

              // Toggles
              SwitchListTile(
                value: _enableRazorpay,
                onChanged: (val) => setState(() => _enableRazorpay = val),
                title: const Text('Enable Razorpay (Cards, NetBanking, UPI)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                // ignore: deprecated_member_use
                activeColor: const Color(0xFF5636F5),
              ),
              SwitchListTile(
                value: _enableUpiDirect,
                onChanged: (val) => setState(() => _enableUpiDirect = val),
                title: const Text('Enable Direct Intent UPI (GPay, PhonePe, Paytm)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                // ignore: deprecated_member_use
                activeColor: const Color(0xFF5636F5),
              ),
              SwitchListTile(
                value: _autoRefundCancelled,
                onChanged: (val) => setState(() => _autoRefundCancelled = val),
                title: const Text('Auto-Refund fees if Tournament/Quiz is cancelled', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                // ignore: deprecated_member_use
                activeColor: const Color(0xFF5636F5),
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment configuration updated successfully'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Save Configuration'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
