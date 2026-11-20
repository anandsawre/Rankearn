import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class PaymentSettingsDialog extends StatefulWidget {
  const PaymentSettingsDialog({super.key});

  @override
  State<PaymentSettingsDialog> createState() => _PaymentSettingsDialogState();
}

class _PaymentSettingsDialogState extends State<PaymentSettingsDialog> {
  bool _isLoading = true;
  bool _isSaving = false;

  bool _isLiveMode = true;
  bool _enableRazorpay = true;
  bool _enableUpiDirect = true;
  bool _autoRefundCancelled = true;

  late final TextEditingController _upiVpaController;
  late final TextEditingController _merchantNameController;
  late final TextEditingController _qrNoteController;
  late final TextEditingController _coinsPerRupeeController;
  late final TextEditingController _razorpayKeyController;

  @override
  void initState() {
    super.initState();
    _upiVpaController = TextEditingController();
    _merchantNameController = TextEditingController();
    _qrNoteController = TextEditingController();
    _coinsPerRupeeController = TextEditingController(text: '20');
    _razorpayKeyController = TextEditingController();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await client
          .from('app_configs')
          .select()
          .eq('key', 'payment_settings')
          .maybeSingle();

      if (res != null && res['value'] is Map) {
        final val = res['value'] as Map<String, dynamic>;
        _upiVpaController.text = val['upiId']?.toString() ?? val['upi_vpa']?.toString() ?? '';
        _merchantNameController.text = val['merchantName']?.toString() ?? '';
        _qrNoteController.text = val['qrNote']?.toString() ?? '';
        _coinsPerRupeeController.text = val['coinsPerRupee']?.toString() ?? '20';
        _razorpayKeyController.text = val['razorpayKeyId']?.toString() ?? val['razorpay_key']?.toString() ?? '';
        _isLiveMode = val['isLiveMode'] as bool? ?? true;
        _enableRazorpay = val['enable_razorpay'] as bool? ?? val['enableRazorpay'] as bool? ?? true;
        _enableUpiDirect = val['enable_upi_direct'] as bool? ?? val['isUPIEnabled'] as bool? ?? true;
        _autoRefundCancelled = val['auto_refund_cancelled'] as bool? ?? true;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);
      }
      return;
    }

    try {
      final existingRes = await client
          .from('app_configs')
          .select('value')
          .eq('key', 'payment_settings')
          .maybeSingle();

      final existingMap = (existingRes != null && existingRes['value'] is Map)
          ? Map<String, dynamic>.from(existingRes['value'] as Map)
          : <String, dynamic>{};

      existingMap['upiId'] = _upiVpaController.text.trim();
      existingMap['merchantName'] = _merchantNameController.text.trim();
      existingMap['qrNote'] = _qrNoteController.text.trim();
      final coinsPerRupee = int.tryParse(_coinsPerRupeeController.text.trim()) ?? 20;
      existingMap['coinsPerRupee'] = coinsPerRupee;
      existingMap['razorpayKeyId'] = _razorpayKeyController.text.trim();
      existingMap['isLiveMode'] = _isLiveMode;
      existingMap['enable_razorpay'] = _enableRazorpay;
      existingMap['enable_upi_direct'] = _enableUpiDirect;
      existingMap['isUPIEnabled'] = _enableUpiDirect;
      existingMap['auto_refund_cancelled'] = _autoRefundCancelled;

      await client.from('app_configs').upsert({
        'key': 'payment_settings',
        'value': existingMap,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment gateway & UPI configuration saved to Supabase!'),
            backgroundColor: AppColors.adminSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save payment configuration: $e'),
            backgroundColor: AppColors.adminDanger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _upiVpaController.dispose();
    _merchantNameController.dispose();
    _qrNoteController.dispose();
    _coinsPerRupeeController.dispose();
    _razorpayKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Payment Gateway & UPI Settings',
      subtitle: 'Configure real payment credentials, UPI VPA & transaction behavior',
      iconData: Icons.settings_rounded,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 620,
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
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
          onPressed: _isSaving ? null : _saveConfig,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Configuration'),
        ),
      ],
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: Color(0xFFFF9500)),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        activeThumbColor: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // UPI Direct Merchant VPA
                const Text('UPI Direct Merchant VPA *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                TextField(
                  controller: _upiVpaController,
                  decoration: AppModalDialog.inputDecoration(
                    'e.g. rankearn@upi or yourname@okaxis',
                    focusColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Merchant Display Name
                const Text('Merchant Display Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                TextField(
                  controller: _merchantNameController,
                  decoration: AppModalDialog.inputDecoration(
                    'e.g. Rankearn Official',
                    focusColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                // QR Payment Note
                const Text('QR Instruction Note for Users', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                TextField(
                  controller: _qrNoteController,
                  decoration: AppModalDialog.inputDecoration(
                    'e.g. Enter exact amount and copy 12-digit UTR below',
                    focusColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Coins Per Rupee
                const Text('Coins Per Rupee (Top-up Rate)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                TextField(
                  controller: _coinsPerRupeeController,
                  keyboardType: TextInputType.number,
                  decoration: AppModalDialog.inputDecoration(
                    '20',
                    focusColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Razorpay Public Key ID
                const Text('Razorpay Public Key ID', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                TextField(
                  controller: _razorpayKeyController,
                  decoration: AppModalDialog.inputDecoration(
                    'rzp_live_... or rzp_test_...',
                    focusColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 14),

                // Toggles
                SwitchListTile(
                  value: _enableRazorpay,
                  onChanged: (val) => setState(() => _enableRazorpay = val),
                  title: const Text('Enable Razorpay (Cards, NetBanking, UPI)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFFF9500),
                ),
                SwitchListTile(
                  value: _enableUpiDirect,
                  onChanged: (val) => setState(() => _enableUpiDirect = val),
                  title: const Text('Enable Direct Intent UPI (GPay, PhonePe, Paytm QR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFFF9500),
                ),
                SwitchListTile(
                  value: _autoRefundCancelled,
                  onChanged: (val) => setState(() => _autoRefundCancelled = val),
                  title: const Text('Auto-Refund fees if Tournament/Quiz is cancelled', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFFF9500),
                ),
              ],
            ),
    );
  }
}
