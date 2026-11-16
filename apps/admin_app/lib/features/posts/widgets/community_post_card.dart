import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CommunityPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onPin;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onPin,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = post['title']?.toString() ?? 'Community Update';
    final content = post['content']?.toString() ?? post['excerpt']?.toString() ?? '';
    final date = post['date']?.toString() ?? 'Nov 11, 2026 • 10:30 AM';
    final isPinned = post['isPinned'] == true;
    final views = post['views']?.toString() ?? '12,480';
    final likes = post['likes']?.toString() ?? '1,426';
    final comments = post['comments']?.toString() ?? '278';
    final shares = post['shares']?.toString() ?? '86';
    final imageUrl = post['imageUrl']?.toString() ?? '';
    final isPdf = post['isPdf'] == true || (post['attachmentType'] == 'pdf');

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
          // Top Row: Icon + Title + Meta + Thumbnail
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPdf ? const Color(0xFFEFF6FF) : AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isPdf ? Icons.picture_as_pdf_rounded : Icons.campaign_rounded,
                  size: 20,
                  color: isPdf ? const Color(0xFF2563EB) : AppColors.adminPurple,
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
                            'Published',
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
              if (imageUrl.isNotEmpty) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 110,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 110,
                      height: 60,
                      color: AppColors.adminPurpleLight,
                      child: const Icon(Icons.image_outlined, color: AppColors.adminPurple),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Body text
          if (content.isNotEmpty)
            Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.adminPrimaryText,
                height: 1.45,
              ),
            ),

          // PDF Box if applicable
          if (isPdf) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.adminBackground,
                borderRadius: AppRadii.adminControl,
                border: Border.all(color: AppColors.adminBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PDF', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cell_Biology_Notes.pdf', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.adminPrimaryText)),
                        Text('5.2 MB', style: TextStyle(fontSize: 10, color: AppColors.adminSecondaryText)),
                      ],
                    ),
                  ),
                  const Icon(Icons.download_rounded, size: 20, color: AppColors.adminPurple),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.adminBorder),
          const SizedBox(height: 10),

          // Bottom Bar: Metrics & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Metrics
              Row(
                children: [
                  _buildMetric(Icons.visibility_outlined, views),
                  const SizedBox(width: 14),
                  _buildMetric(Icons.thumb_up_alt_outlined, likes),
                  const SizedBox(width: 14),
                  _buildMetric(Icons.chat_bubble_outline_rounded, comments),
                  const SizedBox(width: 14),
                  _buildMetric(Icons.share_outlined, shares),
                ],
              ),

              // Actions
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
                    tooltip: 'Edit Post',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.adminSecondaryText),
                    tooltip: 'Duplicate',
                    onPressed: onDuplicate,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.adminDanger),
                    tooltip: 'Delete Post',
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
