import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Modal dialog for rich in-app pop-up notifications:
/// - Card roundness tokenized to AppRadii.card (matching all app cards)
/// - Tokenized AppButton (Dismiss & Primary CTA) with no arrow icons
/// - Supports Image-Only popups (no title, no description, no badge)
/// - Clean corner (no corner X button; dismissed via Dismiss button or backdrop tap)
class InAppNotificationDialog extends StatelessWidget {
  final Map<String, dynamic> notification;
  final ValueChanged<String>? onAction;

  const InAppNotificationDialog({
    super.key,
    required this.notification,
    this.onAction,
  });

  /// Displays the in-app notification dialog centered on screen.
  /// [barrierDismissible] is true so users can easily tap outside to close.
  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> notification,
    ValueChanged<String>? onAction,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => InAppNotificationDialog(
        notification: notification,
        onAction: onAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawTitle = notification['title']?.toString().trim() ?? '';
    final message = notification['message']?.toString().trim() ?? '';
    final imageUrl = notification['image_url']?.toString().trim();
    final actionUrl = notification['action_url']?.toString().trim();
    final type = notification['type']?.toString().toLowerCase() ?? 'alert';
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    // Detect if this is an image-only notification (no custom title or description)
    final bool isTitleProvided = rawTitle.isNotEmpty &&
        rawTitle != 'Announcement' &&
        rawTitle != 'Image Announcement';
    final bool isMessageProvided = message.isNotEmpty;
    final bool isImageOnly = hasImage && !isTitleProvided && !isMessageProvided;

    IconData badgeIcon = Icons.campaign_rounded;
    Color badgeColor = AppColors.primary;
    Color badgeBg = AppColors.primarySubtle;
    String typeLabel = 'Announcement';

    if (type == 'alert' || type == 'high') {
      badgeIcon = Icons.warning_amber_rounded;
      badgeColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFEF3C7);
      typeLabel = 'Important Alert';
    } else if (type == 'quiz' || type == 'contest') {
      badgeIcon = Icons.emoji_events_rounded;
      badgeColor = const Color(0xFF7C3AED);
      badgeBg = const Color(0xFFF5F3FF);
      typeLabel = 'Contest / Quiz';
    } else if (type == 'offer' || type == 'reward') {
      badgeIcon = Icons.card_giftcard_rounded;
      badgeColor = const Color(0xFFEA580C);
      badgeBg = const Color(0xFFFFF7ED);
      typeLabel = 'Special Offer';
    }

    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.card, // Matched with all app cards
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Full Image Banner (preserves complete aspect ratio without cropping)
                  if (hasImage)
                    GestureDetector(
                      onTap: (actionUrl != null && actionUrl.isNotEmpty)
                          ? () {
                              Navigator.of(context).pop();
                              if (onAction != null) {
                                onAction!(actionUrl);
                              }
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxHeight: 340,
                          minHeight: 120,
                        ),
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain, // Full image preserved completely
                          alignment: Alignment.center,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 140,
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 36),
                                  SizedBox(height: 6),
                                  Text(
                                    'Image preview unavailable',
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Content Body (Title, Message, Badge) - Hidden if Image-Only
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      isImageOnly ? 14 : 16,
                      18,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge Tag (Only shown if title/content is provided)
                        if (!isImageOnly && isTitleProvided) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: AppRadii.badge,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(badgeIcon, color: badgeColor, size: 14),
                                    const SizedBox(width: 5),
                                    Text(
                                      typeLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Title (Only if provided)
                        if (!isImageOnly && isTitleProvided) ...[
                          Text(
                            rawTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.3,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],

                        // Message (Only if provided)
                        if (!isImageOnly && isMessageProvided) ...[
                          const SizedBox(height: 6),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],

                        if (!isImageOnly && (isTitleProvided || isMessageProvided))
                          const SizedBox(height: 16),

                        // Tokenized Action Buttons (No arrow icons)
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Dismiss',
                                variant: AppButtonVariant.secondary,
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            if (actionUrl != null && actionUrl.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  label: 'View Details',
                                  variant: AppButtonVariant.primary,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if (onAction != null) {
                                      onAction!(actionUrl);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
