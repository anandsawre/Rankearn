import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PaymentSettingsCard extends StatelessWidget {
  final bool enablePayments;
  final String defaultGateway;
  final bool enableRazorpay;
  final bool enableCashfree;
  final bool enablePayU;
  final ValueChanged<bool> onEnablePaymentsChanged;
  final ValueChanged<String?> onDefaultGatewayChanged;
  final ValueChanged<bool> onEnableRazorpayChanged;
  final ValueChanged<bool> onEnableCashfreeChanged;
  final ValueChanged<bool> onEnablePayUChanged;
  final VoidCallback onConfigureKeys;
  final VoidCallback? onSave;

  const PaymentSettingsCard({
    super.key,
    required this.enablePayments,
    required this.defaultGateway,
    required this.enableRazorpay,
    required this.enableCashfree,
    required this.enablePayU,
    required this.onEnablePaymentsChanged,
    required this.onDefaultGatewayChanged,
    required this.onEnableRazorpayChanged,
    required this.onEnableCashfreeChanged,
    required this.onEnablePayUChanged,
    required this.onConfigureKeys,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.adminPurpleLight,
                      borderRadius: AppRadii.adminControl,
                    ),
                    child: const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.adminPurple),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Payment Settings',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Enable Payments',
                      style: AppTypography.adminFieldLabelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSwitch.primary(
                    value: enablePayments,
                    onChanged: onEnablePaymentsChanged,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text('Default Gateway', style: AppTypography.adminFieldLabelSmall),
              const SizedBox(height: 6),
              AppDropdown<String>(
                inlineLabel: true,
                value: defaultGateway,
                items: const [
                  AppDropdownItem(value: 'Razorpay', label: 'Razorpay'),
                  AppDropdownItem(value: 'Cashfree', label: 'Cashfree Payments'),
                  AppDropdownItem(value: 'PayU', label: 'PayU Money'),
                ],
                onChanged: onDefaultGatewayChanged,
              ),
              const SizedBox(height: 12),

              // Razorpay
              _buildGatewayRow('Razorpay', const Color(0xFF0C2340), enableRazorpay, onEnableRazorpayChanged),
              const SizedBox(height: 8),

              // Cashfree
              _buildGatewayRow('Cashfree', const Color(0xFF00838F), enableCashfree, onEnableCashfreeChanged),
              const SizedBox(height: 8),

              // PayU
              _buildGatewayRow('PayU', const Color(0xFF558B2F), enablePayU, onEnablePayUChanged),
              const SizedBox(height: 14),

              InkWell(
                onTap: onConfigureKeys,
                borderRadius: AppRadii.adminControl,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.adminPurpleLight.withAlpha(80),
                    borderRadius: AppRadii.adminControl,
                    border: Border.all(color: AppColors.adminPurple.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key_rounded, size: 16, color: AppColors.adminPurple),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Configure Payment Keys & UPI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.adminPurple,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.adminPurple),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (onSave != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: AppButton.adminPrimary(
                  label: 'Save Payment Settings',
                  leadingIcon: const Icon(Icons.save_rounded, size: 16),
                  onPressed: onSave,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGatewayRow(String name, Color badgeColor, bool enabled, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: AppRadii.adminControl,
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: AppRadii.adminBadge,
            ),
            alignment: Alignment.center,
            child: Text(
              name[0],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: AppTypography.adminTablePrimary.copyWith(fontSize: 13),
            ),
          ),
          AppSwitch.small(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
