import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

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
  int _charCount = 0;
  static const int _maxChars = 250;

  @override
  void initState() {
    super.initState();
    _charCount = widget.messageController.text.length;
    widget.messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    if (mounted) {
      setState(() {
        _charCount = widget.messageController.text.length;
      });
    }
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onMessageChanged);
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.scheduledDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.adminPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.adminPrimaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: widget.scheduledDateTime != null
          ? TimeOfDay.fromDateTime(widget.scheduledDateTime!)
          : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.adminPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.adminPrimaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final scheduled = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      widget.onDateTimeChanged(scheduled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0810143A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.borderMd,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.adminPrimaryText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Compose, target and dispatch alerts across channels',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.adminSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Channel Selector
          const Text(
            'NOTIFICATION CHANNEL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.adminSecondaryText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          _buildChannelPills(),
          const SizedBox(height: 20),

          // Notification Title
          const Text(
            'Notification Title *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.adminPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: widget.titleController,
            hintText: 'e.g. 🏆 Mega Scholarship Test Live Now!',
            prefixIcon: const Icon(Icons.title_rounded, size: 20, color: AppColors.adminSecondaryText),
          ),
          const SizedBox(height: 18),

          // Notification Message + Character Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notification Message *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adminPrimaryText,
                ),
              ),
              Text(
                '$_charCount/$_maxChars',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _charCount > _maxChars ? AppColors.adminDanger : AppColors.adminSecondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: widget.messageController,
            hintText: 'Enter complete message details visible on the candidate\'s screen...',
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adminPrimaryText,
                        ),
                      ),
                      Text(
                        'Send automatically at a scheduled date and time',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.adminSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: widget.isScheduled,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.adminPurple,
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
                        style: const TextStyle(
                          fontSize: 13,
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adminPrimaryText,
                        ),
                      ),
                      Text(
                        'Attach deep link or web redirect to notification',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.adminSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: widget.hasActionButton,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.adminSuccess,
                onChanged: widget.onActionButtonToggled,
              ),
            ],
          ),

          if (widget.hasActionButton) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwo = constraints.maxWidth >= 500;
                if (isTwo) {
                  return Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: widget.actionLabelController,
                          hintText: 'Button Text (e.g. Join Now)',
                          prefixIcon: const Icon(Icons.smart_button_rounded, size: 20, color: AppColors.adminSecondaryText),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          controller: widget.actionUrlController,
                          hintText: 'Target Route (e.g. /tests)',
                          prefixIcon: const Icon(Icons.link_rounded, size: 20, color: AppColors.adminSecondaryText),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    AppTextField(
                      controller: widget.actionLabelController,
                      hintText: 'Button Text (e.g. Join Now)',
                      prefixIcon: const Icon(Icons.smart_button_rounded, size: 20, color: AppColors.adminSecondaryText),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: widget.actionUrlController,
                      hintText: 'Target Route (e.g. /tests)',
                      prefixIcon: const Icon(Icons.link_rounded, size: 20, color: AppColors.adminSecondaryText),
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 24),

          // Action Buttons: Reset, Save as Draft, Send Now
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.isSubmitting ? null : widget.onReset,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset Form'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.adminSecondaryText,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.isSubmitting ? null : widget.onSaveDraft,
                    icon: const Icon(Icons.drafts_outlined, size: 16),
                    label: const Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.adminPrimaryText,
                      side: const BorderSide(color: AppColors.adminBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.adminPurpleGradient,
                      borderRadius: AppRadii.borderMd,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x407628E8),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: widget.isSubmitting ? null : widget.onSendNow,
                      icon: widget.isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(
                              widget.isScheduled ? Icons.schedule_send_rounded : Icons.send_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                      label: Text(
                        widget.isSubmitting
                            ? 'Dispatching...'
                            : widget.isScheduled
                                ? 'Schedule Notification'
                                : 'Send Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelPills() {
    final channels = [
      {'id': 'push', 'label': 'Push Notification', 'icon': Icons.notifications_active_outlined},
      {'id': 'inapp', 'label': 'In-App Notification', 'icon': Icons.chat_bubble_outline_rounded},
      {'id': 'email', 'label': 'Email Alert', 'icon': Icons.email_outlined},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: channels.map((c) {
        final isSelected = widget.selectedChannel == c['id'];
        return InkWell(
          onTap: () => widget.onChannelChanged(c['id'] as String),
          borderRadius: AppRadii.borderMd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.adminPurple : Colors.white,
              borderRadius: AppRadii.borderMd,
              border: Border.all(
                color: isSelected ? AppColors.adminPurple : AppColors.adminBorder,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x307628E8),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  c['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.adminSecondaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  c['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.adminPrimaryText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAudienceSelector() {
    final audiences = [
      {'value': 'all', 'label': 'All Users'},
      {'value': 'students', 'label': 'Students'},
      {'value': 'teachers', 'label': 'Teachers'},
      {'value': 'active', 'label': 'Active Users'},
      {'value': 'inactive', 'label': 'Inactive Users'},
      {'value': 'quiz_participants', 'label': 'Quiz Participants'},
      {'value': 'specific', 'label': 'Specific Users'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Audience *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.adminPrimaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderMd,
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.targetAudience,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.adminSecondaryText),
              items: audiences.map((a) {
                return DropdownMenuItem<String>(
                  value: a['value'],
                  child: Text(
                    a['label']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.adminPrimaryText,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) widget.onAudienceChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      {'value': 'alert', 'label': 'Alert (High Priority)'},
      {'value': 'promotional', 'label': 'Promotional / Offer'},
      {'value': 'contest', 'label': 'Contest / Battle'},
      {'value': 'update', 'label': 'Product Update'},
      {'value': 'reminder', 'label': 'Quiz Reminder'},
      {'value': 'system', 'label': 'System Broadcast'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Type *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.adminPrimaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderMd,
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.notificationType,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.adminSecondaryText),
              items: types.map((t) {
                return DropdownMenuItem<String>(
                  value: t['value'],
                  child: Text(
                    t['label']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.adminPrimaryText,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) widget.onTypeChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
