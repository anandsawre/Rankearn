import 'package:flutter/material.dart';

/// Modal dialog for rich in-app pop-up notifications:
/// - Positioned dead-center on the screen with dim backdrop
/// - Full-size image display (preserves full aspect ratio, no crop)
/// - Prominent close button pinned to the top-right corner
/// - No auto-close timer (stays open until explicitly dismissed or action tapped)
class InAppNotificationDialog extends StatelessWidget {
  final Map<String, dynamic> notification;
  final ValueChanged<String>? onAction;

  const InAppNotificationDialog({
    super.key,
    required this.notification,
    this.onAction,
  });

  /// Displays the in-app notification dialog centered on screen.
  /// [barrierDismissible] is false by default so it does not accidentally close on tap outside.
  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> notification,
    ValueChanged<String>? onAction,
    bool barrierDismissible = false,
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
    final title = notification['title']?.toString() ?? 'Announcement';
    final message = notification['message']?.toString() ?? '';
    final imageUrl = notification['image_url']?.toString().trim();
    final actionUrl = notification['action_url']?.toString().trim();
    final type = notification['type']?.toString().toLowerCase() ?? 'alert';
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    IconData badgeIcon = Icons.campaign_rounded;
    Color badgeColor = const Color(0xFF059669);
    Color badgeBg = const Color(0xFFF0FDF4);
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
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Dialog Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Image Container (no cropping, full aspect ratio displayed)
                      if (hasImage)
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 340,
                            minHeight: 140,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
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
                                    Text('Image preview unavailable',
                                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Text and Action Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge Tag
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(8),
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
                            const SizedBox(height: 12),

                            // Notification Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                            ),

                            // Notification Message
                            if (message.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Buttons (Action CTA + Dismiss)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Dismiss',
                                      style: TextStyle(
                                        color: Color(0xFF475569),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                if (actionUrl != null && actionUrl.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (onAction != null) {
                                          onAction!(actionUrl);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('View Details', style: TextStyle(fontWeight: FontWeight.w700)),
                                          SizedBox(width: 6),
                                          Icon(Icons.arrow_forward_rounded, size: 16),
                                        ],
                                      ),
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

              // Corner Close Button (Placed right on the top-right corner of the dialog)
              Positioned(
                top: -12,
                right: -12,
                child: Material(
                  color: Colors.white,
                  elevation: 6,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
