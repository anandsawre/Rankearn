import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

enum NotificationPreviewMode { inAppPopup, pushNotification }

/// High-fidelity, real-time live device preview simulator for Admin Notification Composer.
/// Supports switching between:
/// 1. In-App Pop-Up Dialog (centered on screen, full banner, custom CTA, matching User App)
/// 2. Lock Screen / Push Notification Card (Android/Web notification with rich image)
class NotificationPreviewCard extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController messageController;
  final TextEditingController imageUrlController;
  final TextEditingController actionLabelController;
  final TextEditingController actionUrlController;
  final bool hasImage;
  final bool hasActionButton;
  final String selectedChannel;
  final String notificationType;
  final NotificationPreviewMode initialMode;
  final NotificationPreviewMode? currentMode;
  final ValueChanged<NotificationPreviewMode>? onModeChanged;
  final bool showHeaderModeSwitcher;

  const NotificationPreviewCard({
    super.key,
    required this.titleController,
    required this.messageController,
    required this.imageUrlController,
    required this.actionLabelController,
    required this.actionUrlController,
    required this.hasImage,
    required this.hasActionButton,
    required this.selectedChannel,
    required this.notificationType,
    this.initialMode = NotificationPreviewMode.inAppPopup,
    this.currentMode,
    this.onModeChanged,
    this.showHeaderModeSwitcher = true,
  });

  /// Centralized mode switcher pill: renders [In-App Pop-up] and [Push Notification] buttons.
  /// Can be used directly in modal dialog footers or standalone bars with exact 38px height matching admin buttons.
  static Widget buildModeSwitcher({
    required NotificationPreviewMode mode,
    required ValueChanged<NotificationPreviewMode> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: AppRadii.adminControl,
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildModeButtonWidget(
              isSelected: mode == NotificationPreviewMode.inAppPopup,
              label: 'In-App Pop-up',
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => onChanged(NotificationPreviewMode.inAppPopup),
            ),
            const SizedBox(width: 4),
            _buildModeButtonWidget(
              isSelected: mode == NotificationPreviewMode.pushNotification,
              label: 'Push Notification',
              icon: Icons.notifications_active_outlined,
              onTap: () => onChanged(NotificationPreviewMode.pushNotification),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildModeButtonWidget({
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 32,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.adminSecondaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.adminSecondaryText,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<NotificationPreviewCard> createState() => _NotificationPreviewCardState();
}

class _NotificationPreviewCardState extends State<NotificationPreviewCard> {
  late NotificationPreviewMode _mode;

  NotificationPreviewMode get effectiveMode => widget.currentMode ?? _mode;

  @override
  void initState() {
    super.initState();
    if (widget.currentMode != null) {
      _mode = widget.currentMode!;
    } else if (widget.selectedChannel == 'inapp') {
      _mode = NotificationPreviewMode.inAppPopup;
    } else if (widget.selectedChannel == 'push') {
      _mode = NotificationPreviewMode.pushNotification;
    } else {
      _mode = widget.initialMode;
    }
  }

  @override
  void didUpdateWidget(NotificationPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMode != null && widget.currentMode != oldWidget.currentMode) {
      _mode = widget.currentMode!;
    } else if (oldWidget.selectedChannel != widget.selectedChannel) {
      if (widget.selectedChannel == 'inapp') {
        _mode = NotificationPreviewMode.inAppPopup;
      } else if (widget.selectedChannel == 'push') {
        _mode = NotificationPreviewMode.pushNotification;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.titleController,
        widget.messageController,
        widget.imageUrlController,
        widget.actionLabelController,
        widget.actionUrlController,
      ]),
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.adminCardBackground,
            borderRadius: AppRadii.adminCard,
            border: Border.all(color: AppColors.adminBorder),
            boxShadow: AppShadows.adminCard,
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Responsive Header with Title and Mode Switcher
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 540;
                  final titlePod = Row(
                    mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.adminPurpleLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.devices_rounded, size: 18, color: AppColors.adminPurple),
                      ),
                      const SizedBox(width: 8),
                      isCompact
                          ? const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Live Device Simulator',
                                    style: AppTypography.adminCardTitle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Real-time candidate view preview',
                                    style: AppTypography.adminCardSubtitle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            )
                          : const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Live Device Simulator', style: AppTypography.adminCardTitle),
                                Text('Real-time candidate view preview', style: AppTypography.adminCardSubtitle),
                              ],
                            ),
                    ],
                  );

                  if (!widget.showHeaderModeSwitcher) {
                    return titlePod;
                  }

                  final switcherPod = NotificationPreviewCard.buildModeSwitcher(
                    mode: effectiveMode,
                    onChanged: (newMode) {
                      setState(() => _mode = newMode);
                      widget.onModeChanged?.call(newMode);
                    },
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titlePod,
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: switcherPod,
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      titlePod,
                      switcherPod,
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.adminBorder, height: 1),
              const SizedBox(height: 20),

              // Realistic Smartphone Mockup Frame
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFF334155), width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Smartphone Status Bar & Camera Island
                        Container(
                          height: 38,
                          color: const Color(0xFF0B1120),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '9:41',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              // Camera Island Pill
                              Container(
                                width: 72,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const Row(
                                children: [
                                  Icon(Icons.signal_cellular_alt_rounded, size: 13, color: Colors.white),
                                  SizedBox(width: 4),
                                  Icon(Icons.wifi_rounded, size: 13, color: Colors.white),
                                  SizedBox(width: 4),
                                  Icon(Icons.battery_5_bar_rounded, size: 14, color: Colors.white),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Device Screen Content Canvas (Gradient Wallpaper with no network dependencies)
                        Container(
                          constraints: const BoxConstraints(minHeight: 440, maxHeight: 490),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: effectiveMode == NotificationPreviewMode.inAppPopup
                                ? const RadialGradient(
                                    center: Alignment.topCenter,
                                    radius: 1.2,
                                    colors: [
                                      Color(0xFF334155),
                                      Color(0xFF1E293B),
                                      Color(0xFF0F172A),
                                    ],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF1E1B4B),
                                      Color(0xFF0F172A),
                                      Color(0xFF020617),
                                    ],
                                  ),
                          ),
                          child: effectiveMode == NotificationPreviewMode.inAppPopup
                              ? _buildInAppPopupPreview()
                              : _buildPushNotificationPreview(),
                        ),

                        // Bottom Home Indicator Bar
                        Container(
                          height: 18,
                          color: const Color(0xFF0B1120),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Footnote indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.adminSecondaryText),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      effectiveMode == NotificationPreviewMode.inAppPopup
                          ? 'Simulating candidate app center pop-up dialog'
                          : 'Simulating lock-screen & desktop push notification',
                      style: AppTypography.adminTableSecondary.copyWith(fontSize: 11.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  /// 1. In-App Pop-up Dialog Preview (matches exact user_app styling)
  Widget _buildInAppPopupPreview() {
    final title = widget.titleController.text.trim();
    final message = widget.messageController.text.trim();
    final imageUrl = widget.hasImage ? widget.imageUrlController.text.trim() : '';
    final hasImg = imageUrl.isNotEmpty;
    final actionLabel = widget.hasActionButton && widget.actionLabelController.text.trim().isNotEmpty
        ? widget.actionLabelController.text.trim()
        : 'View Details';

    final isImageOnly = hasImg && title.isEmpty && message.isEmpty;

    return Container(
      color: Colors.black.withValues(alpha: 0.65), // Dimmed backdrop
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.card, // 16px matching app
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Image Container
              if (hasImg)
                Container(
                  constraints: const BoxConstraints(maxHeight: 180, minHeight: 90),
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 100,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 28),
                            SizedBox(height: 4),
                            Text('Image preview', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Content Body
              Padding(
                padding: EdgeInsets.fromLTRB(14, isImageOnly ? 10 : 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge (only if title provided)
                    if (!isImageOnly && title.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: AppRadii.badge,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.campaign_rounded, color: Color(0xFFD97706), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              _getBadgeLabel(widget.notificationType),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Title
                    if (!isImageOnly)
                      Text(
                        title.isNotEmpty ? title : 'Notification Title Preview',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: title.isNotEmpty ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Message
                    if (!isImageOnly) ...[
                      const SizedBox(height: 4),
                      Text(
                        message.isNotEmpty ? message : 'Your candidate notification message description will appear here.',
                        style: TextStyle(
                          fontSize: 12,
                          color: message.isNotEmpty ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                    ] else
                      const SizedBox(height: 10),

                    // Action Buttons (Dismiss + Custom Button Text)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Dismiss',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.hasActionButton || !isImageOnly) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  actionLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
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
    );
  }

  /// 2. Push Notification Lockscreen Banner Preview
  Widget _buildPushNotificationPreview() {
    final title = widget.titleController.text.trim();
    final message = widget.messageController.text.trim();
    final imageUrl = widget.hasImage ? widget.imageUrlController.text.trim() : '';
    final hasImg = imageUrl.isNotEmpty;
    final actionLabel = widget.hasActionButton && widget.actionLabelController.text.trim().isNotEmpty
        ? widget.actionLabelController.text.trim()
        : 'Open';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Clock Header
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const Text(
            'Thursday, 21 November',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 28),

          // Push Notification Floating Card
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top App Identity Row
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'RANKEARN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'now',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title & Body
                Text(
                  title.isNotEmpty ? title : 'Rankearn Broadcast Title',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: title.isNotEmpty ? Colors.white : Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message.isNotEmpty ? message : 'Tap to explore test series, spin wheel, or view announcement details...',
                  style: TextStyle(
                    fontSize: 12,
                    color: message.isNotEmpty ? Colors.white70 : Colors.white38,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Rich Banner Image
                if (hasImg) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      color: Colors.white10,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],

                // Action Pill
                if (widget.hasActionButton) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBadgeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
      case 'high':
        return 'Important Alert';
      case 'quiz':
      case 'contest':
        return 'Contest / Quiz';
      case 'offer':
      case 'reward':
        return 'Special Offer';
      default:
        return 'Announcement';
    }
  }
}
