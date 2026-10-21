import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/payment_item.dart';

class PaymentDetailsDialog extends StatelessWidget {
  final PaymentItem payment;
  final VoidCallback onProcessRefund;
  final VoidCallback onViewReceipt;

  const PaymentDetailsDialog({
    super.key,
    required this.payment,
    required this.onProcessRefund,
    required this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
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
                            color: const Color(0xFF2587F8).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2587F8), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transaction Details',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                              ),
                              Text(
                                payment.transactionId,
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
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

              // Status & Amount Highlight Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transaction Amount', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${payment.amount.toInt()}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF101A3A)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: payment.status.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payment.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: payment.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details Grid
              _buildDetailRow('User Name', payment.userName),
              _buildDetailRow('User Email', payment.userEmail),
              _buildDetailRow('Purpose', payment.purpose.label),
              _buildDetailRow('Payment Method', payment.paymentMethod.label),
              _buildDetailRow('Order ID', payment.orderId),
              _buildDetailRow('Gateway Reference', payment.gatewayReference ?? 'rzp_capt_789123'),
              _buildDetailRow('Date & Time', '${payment.dateTime.day}/${payment.dateTime.month}/${payment.dateTime.year} at ${payment.dateTime.hour}:${payment.dateTime.minute.toString().padLeft(2, '0')}'),

              if (payment.status == PaymentStatus.refunded || payment.status == PaymentStatus.partiallyRefunded) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Refund of ₹${payment.refundAmount ?? payment.amount} processed on ${payment.refundReason ?? "Customer request"}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onViewReceipt,
                    icon: const Icon(Icons.receipt_outlined, size: 16),
                    label: const Text('View Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5636F5),
                      side: const BorderSide(color: Color(0xFF5636F5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (payment.status == PaymentStatus.success)
                    ElevatedButton.icon(
                      onPressed: onProcessRefund,
                      icon: const Icon(Icons.replay_rounded, size: 16),
                      label: const Text('Process Refund'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
