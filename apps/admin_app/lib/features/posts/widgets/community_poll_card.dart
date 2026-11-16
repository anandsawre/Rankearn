import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CommunityPollCard extends StatelessWidget {
  final Map<String, dynamic> poll;
  final VoidCallback onPin;
  final VoidCallback onEdit;
  final VoidCallback onAnalytics;
  final VoidCallback onDelete;

  const CommunityPollCard({
    super.key,
    required this.poll,
    required this.onPin,
    required this.onEdit,
    required this.onAnalytics,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = poll['title']?.toString() ?? 'अगला Live Quiz किस विषय पर हो? 🤔';
    final date = poll['date']?.toString() ?? 'Nov 10, 2026 • 06:15 PM • Poll';
    final isPinned = poll['isPinned'] == true;
    final views = poll['views']?.toString() ?? '9,840';
    final likes = poll['likes']?.toString() ?? '782';
    final comments = poll['comments']?.toString() ?? '412';

    final options = (poll['options'] as List<dynamic>?) ?? [
      {'label': 'General Science', 'pct': 0.42, 'count': '42% (3,920)'},
      {'label': 'Mathematics', 'pct': 0.28, 'count': '28% (2,610)'},
      {'label': 'Reasoning', 'pct': 0.18, 'count': '18% (1,680)'},
      {'label': 'General Awareness', 'pct': 0.12, 'count': '12% (1,120)'},
    ];

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Poll Icon + Question Title + Meta
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.poll_rounded,
                  size: 20,
                  color: AppColors.adminPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.adminCardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          date,
                          style: AppTypography.adminTableSecondary.copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Options Progress Bars
          ...options.map((opt) {
            final label = opt['label']?.toString() ?? '';
            final pct = (opt['pct'] as num?)?.toDouble() ?? 0.25;
            final count = opt['count']?.toString() ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Stack(
                children: [
                  // Background Bar
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.adminBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                  ),
                  // Progress Fill
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.adminPurple.withAlpha(55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // Text Content
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.adminSecondaryText, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminPrimaryText),
                            ),
                          ],
                        ),
                        Text(
                          count,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.adminPrimaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.adminBorder),
          const SizedBox(height: 10),

          // Bottom Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildMetric(Icons.visibility_outlined, views),
                  const SizedBox(width: 14),
                  _buildMetric(Icons.thumb_up_alt_outlined, likes),
                  const SizedBox(width: 14),
                  _buildMetric(Icons.chat_bubble_outline_rounded, comments),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, size: 18),
                    color: isPinned ? AppColors.adminPurple : AppColors.adminSecondaryText,
                    tooltip: isPinned ? 'Unpin' : 'Pin to Top',
                    onPressed: onPin,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.adminSecondaryText),
                    tooltip: 'Edit Poll',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.adminPurple),
                    tooltip: 'View Poll Analytics',
                    onPressed: onAnalytics,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.adminDanger),
                    tooltip: 'Delete Poll',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.adminSecondaryText),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.adminSecondaryText,
          ),
        ),
      ],
    );
  }
}
