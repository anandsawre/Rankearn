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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Text('Enable Payments', style: AppTypography.adminFieldLabelSmall),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: enablePayments,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.adminPurple,
                  onChanged: onEnablePaymentsChanged,
                ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.key_rounded, size: 16, color: AppColors.adminPurple),
                      SizedBox(width: 8),
                      Text(
                        'Configure API Keys',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adminPurple,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.adminPurple),
                ],
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
              borderRadius: BorderRadius.circular(6),
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
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: enabled,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.adminPurple,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

