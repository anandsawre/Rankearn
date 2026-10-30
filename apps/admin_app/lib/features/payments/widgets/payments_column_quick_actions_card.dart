import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Compact 3-Button Quick Actions Card for the Payments Right-Rail Column.
/// Positioned directly between "Payment Method Distribution" and "Revenue Trend (Last 7 Days)".
/// Provides 1-tap quick action access to:
/// 1. Top-up Verification
/// 2. Process Withdrawal
/// 3. Finance & Merchant Settings
class PaymentsColumnQuickActionsCard extends StatelessWidget {
  final VoidCallback onTopup;
  final VoidCallback onWithdrawal;
  final VoidCallback onSettings;
  final VoidCallback? onCustomize;

  const PaymentsColumnQuickActionsCard({
    super.key,
    required this.onTopup,
    required this.onWithdrawal,
    required this.onSettings,
    this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Bolt Icon and "Quick Actions"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                ],
              ),
              if (onCustomize != null)
                InkWell(
                  onTap: onCustomize,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Quick Action Buttons Row
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  iconColor: const Color(0xFF00B96B),
                  cardBg: const Color(0xFFE8FAF2),
                  label: 'Top-up',
                  onTap: onTopup,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.arrow_outward_rounded,
                  iconColor: const Color(0xFFFF9F0A),
                  cardBg: const Color(0xFFFFFBEB),
                  label: 'Withdrawal',
                  onTap: onWithdrawal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.tune_rounded,
                  iconColor: const Color(0xFF6366F1),
                  cardBg: const Color(0xFFEEF2FF),
                  label: 'Settings',
                  onTap: onSettings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: iconColor.withAlpha(40), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withAlpha(50),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
