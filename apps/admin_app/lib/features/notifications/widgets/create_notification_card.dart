import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'notification_preview_card.dart';

class CreateNotificationCard extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController messageController;
  final TextEditingController actionLabelController;
  final TextEditingController actionUrlController;
  final String selectedChannel;
  final ValueChanged<String> onChannelChanged;
  final String targetAudience;
  final ValueChanged<String> onAudienceChanged;
  final String notificationType;
  final ValueChanged<String> onTypeChanged;
  final bool isScheduled;
  final ValueChanged<bool> onScheduleToggled;
  final DateTime? scheduledDateTime;
  final ValueChanged<DateTime?> onDateTimeChanged;
  final bool hasImage;
  final ValueChanged<bool> onImageToggled;
  final TextEditingController imageUrlController;
  final bool hasActionButton;
  final ValueChanged<bool> onActionButtonToggled;
  final bool isSubmitting;
  final VoidCallback onSendNow;
  final VoidCallback onSaveDraft;
  final VoidCallback onReset;

  const CreateNotificationCard({
    super.key,
    required this.titleController,
    required this.messageController,
    required this.actionLabelController,
    required this.actionUrlController,
    required this.selectedChannel,
    required this.onChannelChanged,
    required this.targetAudience,
    required this.onAudienceChanged,
    required this.notificationType,
    required this.onTypeChanged,
    required this.isScheduled,
    required this.onScheduleToggled,
    required this.scheduledDateTime,
    required this.onDateTimeChanged,
    required this.hasImage,
    required this.onImageToggled,
    required this.imageUrlController,
    required this.hasActionButton,
    required this.onActionButtonToggled,
    required this.isSubmitting,
    required this.onSendNow,
    required this.onSaveDraft,
    required this.onReset,
  });

  @override
  State<CreateNotificationCard> createState() => _CreateNotificationCardState();
}

class _CreateNotificationCardState extends State<CreateNotificationCard> {
  static const List<Map<String, dynamic>> _userAppTabs = [
    {
      'id': '/spin',
      'label': '🎡 Lucky Wheel (Spin & Win)',
      'icon': Icons.rotate_right_rounded,
      'defaultLabel': 'Spin Now',
    },
    {
      'id': '/tests',
      'label': '📝 Test Series & Quizzes',
      'icon': Icons.assignment_rounded,
      'defaultLabel': 'Explore Tests',
    },
    {
      'id': '/live',
      'label': '⚡ Live Tests & Contests',
      'icon': Icons.bolt_rounded,
      'defaultLabel': 'Join Contest',
    },
    {
      'id': '/battle',
      'label': '⚔️ 1v1 Quiz Battles',
      'icon': Icons.sports_esports_rounded,
      'defaultLabel': 'Play Battle',
    },
    {
      'id': '/tournament',
      'label': '🏆 Tournaments Hub',
      'icon': Icons.emoji_events_rounded,
      'defaultLabel': 'View Tournament',
    },
    {
      'id': '/rewards',
      'label': '🎁 Rewards & Earnings Hub',
      'icon': Icons.card_giftcard_rounded,
      'defaultLabel': 'Claim Rewards',
    },
    {
      'id': '/wallet',
      'label': '💰 Wallet & Coins',
      'icon': Icons.account_balance_wallet_rounded,
      'defaultLabel': 'Open Wallet',
    },
    {
      'id': '/leaderboard',
      'label': '📊 Leaderboard',
      'icon': Icons.leaderboard_rounded,
      'defaultLabel': 'View Ranks',
    },
    {
      'id': '/profile',
      'label': '👤 User Profile',
      'icon': Icons.person_rounded,
      'defaultLabel': 'My Profile',
    },
    {
      'id': '/home',
      'label': '🏠 Home Screen',
      'icon': Icons.home_rounded,
      'defaultLabel': 'Open App',
    },
    {
      'id': 'custom',
      'label': '🔗 Custom Link / External Route',
      'icon': Icons.link_rounded,
      'defaultLabel': 'View Details',
    },
  ];

  String _selectedRouteTab = '/spin';
  bool _showInlinePreview = false;

  void _showLiveDevicePreviewModal() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Candidate Device Simulator',
        subtitle: 'Live visual preview across In-App & Push channels',
        iconData: Icons.smartphone_rounded,
        gradientColors: const [AppColors.adminViolet, AppColors.brandPurple],
        maxWidth: 540,
        scrollable: true,
        fullScreenOnMobile: false,
        actions: [
          AppModalDialog.cancelButton(ctx, label: 'Close Preview'),
        ],
        child: NotificationPreviewCard(
          titleController: widget.titleController,
          messageController: widget.messageController,
          imageUrlController: widget.imageUrlController,
          actionLabelController: widget.actionLabelController,
          actionUrlController: widget.actionUrlController,
          hasImage: widget.hasImage,
          hasActionButton: widget.hasActionButton,
          selectedChannel: widget.selectedChannel,
          notificationType: widget.notificationType,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final currentUrl = widget.actionUrlController.text.trim();
    if (currentUrl.isNotEmpty) {
      final exists = _userAppTabs.any((t) => t['id'] == currentUrl);
      _selectedRouteTab = exists ? currentUrl : 'custom';
    } else {
      _selectedRouteTab = '/spin';
      widget.actionUrlController.text = '/spin';
      if (widget.actionLabelController.text.trim().isEmpty) {
        widget.actionLabelController.text = 'Spin Now';
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final scheduled = await AppDateTimePicker.show(
      context: context,
      initialDateTime: widget.scheduledDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      primaryColor: AppColors.adminPurple,
      gradientColors: const [AppColors.adminViolet, AppColors.brandPurple],
    );

    if (scheduled != null && mounted) {
      widget.onDateTimeChanged(scheduled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.fromBorderSide(BorderSide(color: AppColors.adminBorder)),
        boxShadow: AppShadows.adminCard,
      ),
      padding: AppSpacing.adminCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                child: const Icon(
                  Icons.edit_notifications_rounded,
                  color: AppColors.adminPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Notification',
                      style: AppTypography.adminCardTitle,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Compose, target and dispatch alerts across channels',
                      style: AppTypography.adminCardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Notification Title & Channel Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 550;
              final titleField = AppTextField(
                controller: widget.titleController,
                hintText: 'Notification Title * (Optional for image-only in-app pop-up)',
                prefixIcon: const Icon(Icons.title_rounded, size: 20, color: AppColors.adminSecondaryText),
              );

              final channelDropdown = SizedBox(
                width: isWide ? 230 : double.infinity,
                child: _buildChannelSelector(),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: titleField),
                    const SizedBox(width: 14),
                    channelDropdown,
                  ],
                );
              }

              return Column(
                children: [
                  titleField,
                  const SizedBox(height: 12),
                  channelDropdown,
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Notification Message
          AppTextField(
            controller: widget.messageController,
            hintText: 'Notification Message (Optional: Enter message or leave empty for image-only banner)',
            maxLines: 4,
          ),
          const SizedBox(height: 18),

          // Target Audience & Notification Type Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth >= 500;
              if (isTwoColumn) {
                return Row(
                  children: [
                    Expanded(child: _buildAudienceSelector()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTypeSelector()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildAudienceSelector(),
                  const SizedBox(height: 16),
                  _buildTypeSelector(),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Divider
          const Divider(color: AppColors.adminBorder, height: 1),
          const SizedBox(height: 18),

          // Schedule Send Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule_send_rounded, size: 20, color: AppColors.adminPurple),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule Send',
                        style: AppTypography.adminFieldLabel,
                      ),
                      Text(
                        'Send automatically at a scheduled date and time',
                        style: AppTypography.adminTableSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              AppSwitch.primary(
                value: widget.isScheduled,
                onChanged: widget.onScheduleToggled,
              ),
            ],
          ),

          if (widget.isScheduled) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: AppRadii.borderMd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight.withAlpha(80),
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: AppColors.adminPurple.withAlpha(90)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_rounded, color: AppColors.adminPurple, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.scheduledDateTime != null
                            ? 'Scheduled for: ${widget.scheduledDateTime!.toLocal().toString().substring(0, 16)}'
                            : 'Select Date & Time for Scheduled Dispatch',
                        style: AppTypography.adminTablePrimary.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.adminPurple,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.adminPurple),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Attach Banner Image Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.image_outlined, size: 20, color: AppColors.adminBlue),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attach Banner Image',
                        style: AppTypography.adminFieldLabel,
                      ),
                      Text(
                        'Display rich image inside push & in-app pop-up',
                        style: AppTypography.adminTableSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              AppSwitch.primary(
                value: widget.hasImage,
                onChanged: widget.onImageToggled,
              ),
            ],
          ),

          if (widget.hasImage) ...[
            const SizedBox(height: 12),
            AppTextField(
              controller: widget.imageUrlController,
              hintText: 'Direct Image URL (e.g. https://images.unsplash.com/... or .png / .jpg)',
              prefixIcon: const Icon(Icons.link_rounded, size: 20, color: AppColors.adminSecondaryText),
            ),
            const SizedBox(height: 8),
            // Live Preview of Image
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.imageUrlController,
              builder: (context, value, _) {
                final url = value.text.trim();
                if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
                  return const SizedBox.shrink();
                }
                return Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(color: AppColors.adminBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppColors.adminNeutral.withValues(alpha: 0.1),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_rounded, color: AppColors.adminDanger, size: 20),
                                SizedBox(width: 8),
                                Text('Invalid or unreachable image link', style: TextStyle(color: AppColors.adminDanger, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black.withValues(alpha: 0.6),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            onPressed: () => widget.imageUrlController.clear(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 16),

          // Add Action Button Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 20, color: AppColors.adminSuccess),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Action Button (CTA)',
                        style: AppTypography.adminFieldLabel,
                      ),
                      Text(
                        'Attach deep link or web redirect to notification',
                        style: AppTypography.adminTableSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              AppSwitch.success(
                value: widget.hasActionButton,
                onChanged: widget.onActionButtonToggled,
              ),
            ],
          ),

          if (widget.hasActionButton) ...[
            const SizedBox(height: 12),
            // User App Tab Redirection Dropdown
            Row(
              children: [
                const Icon(Icons.alt_route_rounded, size: 18, color: AppColors.adminPurple),
                const SizedBox(width: 8),
                Text(
                  'Select Redirection Tab in User App',
                  style: AppTypography.adminFieldLabel.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildRouteDropdown(),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwo = constraints.maxWidth >= 500;
                final buttonTextField = AppTextField(
                  controller: widget.actionLabelController,
                  hintText: 'Button Text (e.g. Spin Now, Join Quiz)',
                  prefixIcon: const Icon(Icons.smart_button_rounded, size: 20, color: AppColors.adminSecondaryText),
                );
                final routeField = AppTextField(
                  controller: widget.actionUrlController,
                  hintText: 'Target Route (Auto-selected or enter custom route/URL)',
                  prefixIcon: const Icon(Icons.link_rounded, size: 20, color: AppColors.adminSecondaryText),
                );

                if (isTwo) {
                  return Row(
                    children: [
                      Expanded(child: buttonTextField),
                      const SizedBox(width: 14),
                      Expanded(child: routeField),
                    ],
                  );
                }
                return Column(
                  children: [
                    buttonTextField,
                    const SizedBox(height: 10),
                    routeField,
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 24),

          // Action Buttons: Reset, Save as Draft, Send Now (Adaptive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;

              final resetButton = AppButton.adminGhost(
                label: 'Reset Form',
                leadingIcon: const Icon(Icons.refresh_rounded, size: 16),
                onPressed: widget.isSubmitting ? null : widget.onReset,
              );

              final previewButton = AppButton.adminOutline(
                label: 'Preview Device',
                leadingIcon: const Icon(Icons.smartphone_rounded, size: 16),
                onPressed: _showLiveDevicePreviewModal,
              );

              final saveDraftButton = AppButton.adminSecondary(
                label: 'Save Draft',
                leadingIcon: const Icon(Icons.drafts_outlined, size: 16),
                onPressed: widget.isSubmitting ? null : widget.onSaveDraft,
              );

              final primaryButton = AppButton.adminPrimary(
                label: widget.isSubmitting
                    ? 'Dispatching...'
                    : widget.isScheduled
                        ? 'Schedule Notification'
                        : 'Send Now',
                isLoading: widget.isSubmitting,
                leadingIcon: Icon(
                  widget.isScheduled ? Icons.schedule_send_rounded : Icons.send_rounded,
                  size: 16,
                ),
                onPressed: widget.isSubmitting ? null : widget.onSendNow,
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: resetButton),
                        const SizedBox(width: 8),
                        Expanded(child: previewButton),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: saveDraftButton),
                        const SizedBox(width: 8),
                        Expanded(child: primaryButton),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  resetButton,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      previewButton,
                      const SizedBox(width: 10),
                      saveDraftButton,
                      const SizedBox(width: 10),
                      primaryButton,
                    ],
                  ),
                ],
              );
            },
          ),

          // Live Device Preview Accordion / Simulator
          const SizedBox(height: 18),
          const Divider(color: AppColors.adminBorder, height: 1),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => setState(() => _showInlinePreview = !_showInlinePreview),
            borderRadius: AppRadii.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _showInlinePreview
                    ? AppColors.adminPurpleLight.withValues(alpha: 0.6)
                    : AppColors.adminBackground,
                borderRadius: AppRadii.adminControl,
                border: Border.all(
                  color: _showInlinePreview ? AppColors.adminPurple : AppColors.adminBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.devices_rounded, size: 18, color: AppColors.adminPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Live Candidate Device Preview',
                        style: AppTypography.adminFieldLabel.copyWith(
                          color: AppColors.adminPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.adminPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _showInlinePreview ? 'Interactive Mode' : 'Click to preview',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _showInlinePreview
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.adminPurple,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_showInlinePreview) ...[
            const SizedBox(height: 16),
            NotificationPreviewCard(
              titleController: widget.titleController,
              messageController: widget.messageController,
              imageUrlController: widget.imageUrlController,
              actionLabelController: widget.actionLabelController,
              actionUrlController: widget.actionUrlController,
              hasImage: widget.hasImage,
              hasActionButton: widget.hasActionButton,
              selectedChannel: widget.selectedChannel,
              notificationType: widget.notificationType,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteDropdown() {
    return AppDropdown<String>(
      key: const ValueKey('notif_dropdown_redirection_tab'),
      inlineLabel: false,
      value: _selectedRouteTab,
      height: AppSpacing.adminControlHeight,
      borderRadius: AppRadii.adminControl,
      items: _userAppTabs.map((t) {
        return AppDropdownItem<String>(
          value: t['id'] as String,
          label: t['label'] as String,
          icon: t['icon'] as IconData,
        );
      }).toList(),
      onChanged: (val) {
        if (val == null) return;
        setState(() {
          _selectedRouteTab = val;
          if (val != 'custom') {
            widget.actionUrlController.text = val;
            final tab = _userAppTabs.firstWhere((t) => t['id'] == val);
            final defaultBtn = tab['defaultLabel'] as String;
            final currentBtn = widget.actionLabelController.text.trim();
            final isDefault = currentBtn.isEmpty || _userAppTabs.any((t) => t['defaultLabel'] == currentBtn);
            if (isDefault) {
              widget.actionLabelController.text = defaultBtn;
            }
          }
        });
      },
    );
  }

  Widget _buildChannelSelector() {
    final channels = [
      {'id': 'push', 'label': 'Push Notification', 'icon': Icons.notifications_active_outlined},
      {'id': 'inapp', 'label': 'In-App Notification', 'icon': Icons.chat_bubble_outline_rounded},
      {'id': 'email', 'label': 'Email Alert', 'icon': Icons.email_outlined},
    ];

    return AppDropdown<String>(
      key: const ValueKey('notif_dropdown_channel'),
      inlineLabel: true,
      value: widget.selectedChannel,
      height: AppSpacing.adminControlHeight,
      borderRadius: AppRadii.adminControl,
      items: channels.map((c) {
        return AppDropdownItem<String>(
          value: c['id'] as String,
          label: c['label'] as String,
          icon: c['icon'] as IconData,
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) widget.onChannelChanged(v);
      },
    );
  }

  Widget _buildAudienceSelector() {
    final audiences = [
      {'value': 'all', 'label': 'All Users', 'icon': Icons.groups_outlined},
      {'value': 'students', 'label': 'Students', 'icon': Icons.school_outlined},
      {'value': 'teachers', 'label': 'Teachers', 'icon': Icons.person_pin_outlined},
      {'value': 'active', 'label': 'Active Users', 'icon': Icons.offline_bolt_outlined},
      {'value': 'inactive', 'label': 'Inactive Users', 'icon': Icons.bedtime_outlined},
      {'value': 'quiz_participants', 'label': 'Quiz Participants', 'icon': Icons.quiz_outlined},
      {'value': 'specific', 'label': 'Specific Users', 'icon': Icons.person_search_outlined},
    ];

    return AppDropdown<String>(
      key: const ValueKey('notif_dropdown_audience'),
      inlineLabel: true,
      value: widget.targetAudience,
      height: AppSpacing.adminControlHeight,
      borderRadius: AppRadii.adminControl,
      items: audiences.map((a) {
        return AppDropdownItem<String>(
          value: a['value'] as String,
          label: a['label'] as String,
          icon: a['icon'] as IconData,
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) widget.onAudienceChanged(v);
      },
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      {'value': 'alert', 'label': 'Alert (High Priority)', 'icon': Icons.warning_amber_rounded},
      {'value': 'promotional', 'label': 'Promotional / Offer', 'icon': Icons.local_offer_outlined},
      {'value': 'contest', 'label': 'Contest / Battle', 'icon': Icons.emoji_events_outlined},
      {'value': 'update', 'label': 'Product Update', 'icon': Icons.system_update_alt_rounded},
      {'value': 'reminder', 'label': 'Quiz Reminder', 'icon': Icons.alarm_on_rounded},
      {'value': 'system', 'label': 'System Broadcast', 'icon': Icons.cell_tower_rounded},
    ];

    return AppDropdown<String>(
      key: const ValueKey('notif_dropdown_type'),
      inlineLabel: true,
      value: widget.notificationType,
      height: AppSpacing.adminControlHeight,
      borderRadius: AppRadii.adminControl,
      items: types.map((t) {
        return AppDropdownItem<String>(
          value: t['value'] as String,
          label: t['label'] as String,
          icon: t['icon'] as IconData,
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) widget.onTypeChanged(v);
      },
    );
  }
}
