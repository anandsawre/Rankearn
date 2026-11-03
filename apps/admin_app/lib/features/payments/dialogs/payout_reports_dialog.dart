import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PayoutReportsDialog extends StatelessWidget {
  const PayoutReportsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Payout & Settlement Reports',
      subtitle: 'Financial reconciliation and automated gateway disbursements',
      iconData: Icons.bar_chart_rounded,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 640,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          ),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              children: [
                _buildRow('Gross Transaction Volume', '₹ 12,45,780', isPositive: true),
                const SizedBox(height: 6),
                _buildRow('Refunds Deducted', '- ₹ 14,210', isNegative: true),
                const SizedBox(height: 6),
                _buildRow('Gateway Fees & Taxes (Razorpay / Stripe)', '- ₹ 29,398', isNegative: true),
                const SizedBox(height: 6),
                _buildRow('Platform Commissions Retained', '₹ 1,86,400', isPositive: true),
                const Divider(height: 16, color: Color(0xFFCBD5E1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Net Disbursed Settlements', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101A3A))),
                    Text('₹ 10,15,772', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Recent Settlement Batches
          const Text('Recent Settlement Batches', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A))),
          const SizedBox(height: 8),

          _buildBatchTile('setl_99382104', 'Razorpay Standard', '₹ 4,50,000', 'Oct 18, 2026', 'Settled'),
          _buildBatchTile('setl_99382098', 'ICICI Direct UPI', '₹ 3,20,500', 'Oct 15, 2026', 'Settled'),
          _buildBatchTile('setl_99381985', 'HDFC Payment Gateway', '₹ 2,45,272', 'Oct 12, 2026', 'Settled'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isPositive = false, bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary))),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isNegative ? const Color(0xFFDC2626) : (isPositive ? const Color(0xFF101A3A) : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchTile(String ref, String provider, String amount, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ref, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                      Text('$provider • $date', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF101A3A))),
        ],
      ),
    );
  }
}
