import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/tournament_item.dart';

class TournamentDetailsDialog extends StatelessWidget {
  final TournamentItem item;
  final VoidCallback? onEdit;

  const TournamentDetailsDialog({
    super.key,
    required this.item,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: item.title,
      subtitle: '${item.category} • ${item.status.label}',
      iconData: Icons.emoji_events_rounded,
      maxWidth: 520,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
        if (onEdit != null)
          AppModalDialog.primaryButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit!();
            },
            icon: const Icon(Icons.edit_rounded, size: 14),
            child: const Text(
              'Edit Tournament',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.subtitle.isNotEmpty) ...[
            Text(
              item.subtitle,
              style: AppTypography.bodySmall.copyWith(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
          ],

          // Details Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadii.cardSubtle,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow('Category', item.category),
                const Divider(height: 16, color: AppColors.border),
                _buildInfoRow('Status', item.status.label, badgeColor: item.status.color, badgeBg: item.status.backgroundColor),
                const Divider(height: 16, color: AppColors.border),
                _buildInfoRow('Prize Pool', '₹${_formatNumber(item.prizePool)}', isBold: true),
                const Divider(height: 16, color: AppColors.border),
                _buildInfoRow('Entry Fee', item.entryFee == 0 ? 'Free (₹0)' : '₹${item.entryFee}'),
                const Divider(height: 16, color: AppColors.border),
                _buildInfoRow('Participants', '${_formatNumber(item.participants)} registered'),
                const Divider(height: 16, color: AppColors.border),
                _buildInfoRow('Start Date/Time', '${_formatDate(item.startDate)} at ${_formatTime(item.startDate)}'),
                const Divider(height: 16, color: AppColors.border),
                _buildInfoRow('End Date/Time', '${_formatDate(item.endDate)} at ${_formatTime(item.endDate)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? badgeColor, Color? badgeBg, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
        if (badgeColor != null && badgeBg != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? const Color(0xFF101A3A) : const Color(0xFF1E293B),
            ),
          ),
      ],
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      final part1 = s.substring(0, len - 3);
      final part2 = s.substring(len - 3);
      return '$part1,$part2';
    }
    return n.toString();
  }

  static String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minuteStr $period';
  }
}
