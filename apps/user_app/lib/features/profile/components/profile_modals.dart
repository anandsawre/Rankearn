import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// Interactive Modals and Dialogs for the Rankearn Profile Dashboard
class ProfileModals {
  ProfileModals._();

  // ---------------------------------------------------------------------------
  // 1. EDIT PROFILE MODAL
  // ---------------------------------------------------------------------------
  static void showEditProfile({
    required BuildContext context,
    required UserProfile profile,
    required ValueChanged<UserProfile> onSave,
  }) {
    final nameCtrl = TextEditingController(text: profile.name);
    final phoneCtrl = TextEditingController(
      text: profile.phone ?? '+91 98765 43210',
    );
    final stateCtrl = TextEditingController(
      text: profile.state ?? 'Patna, Bihar',
    );
    final examCtrl = TextEditingController(
      text: profile.examPreparingFor ?? 'Student',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Profile', style: AppTypography.sectionHeading),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name field
                _buildTextField(
                  label: 'Full Name',
                  controller: nameCtrl,
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 14),

                // Phone field
                _buildTextField(
                  label: 'Phone Number',
                  controller: phoneCtrl,
                  icon: Icons.phone_rounded,
                ),
                const SizedBox(height: 14),

                // Location field
                _buildTextField(
                  label: 'Location / State',
                  controller: stateCtrl,
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 14),

                // Target Exam / Role field
                _buildTextField(
                  label: 'Target Exam / Role',
                  controller: examCtrl,
                  icon: Icons.school_rounded,
                ),
                const SizedBox(height: 20),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final updated = profile.copyWith(
                        name: nameCtrl.text.trim().isNotEmpty
                            ? nameCtrl.text.trim()
                            : profile.name,
                        phone: phoneCtrl.text.trim(),
                        state: stateCtrl.text.trim(),
                        examPreparingFor: examCtrl.text.trim(),
                      );
                      onSave(updated);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Color(0xFF10B981),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Save Changes',
                      style: AppTypography.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 2. NOTIFICATION SETTINGS MODAL
  // ---------------------------------------------------------------------------
  static void showNotificationSettings({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            bool pushEnabled = true;
            bool quizAlerts = true;
            bool battleAlerts = true;
            bool coinAlerts = true;

            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notification Settings',
                            style: AppTypography.sectionHeading,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text(
                        'Push Notifications',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Receive important alerts and announcements',
                        style: AppTypography.supporting,
                      ),
                      value: pushEnabled,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setModalState(() => pushEnabled = v),
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Test & Quiz Alerts',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Upcoming live contests and daily tests',
                        style: AppTypography.supporting,
                      ),
                      value: quizAlerts,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setModalState(() => quizAlerts = v),
                    ),
                    SwitchListTile(
                      title: const Text(
                        '1v1 Battle Challenges',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Notify when opponents challenge you',
                        style: AppTypography.supporting,
                      ),
                      value: battleAlerts,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setModalState(() => battleAlerts = v),
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Coins & Wallet Alerts',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Earnings, bonus credits and reward redemptions',
                        style: AppTypography.supporting,
                      ),
                      value: coinAlerts,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setModalState(() => coinAlerts = v),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 3. APP SETTINGS MODAL
  // ---------------------------------------------------------------------------
  static void showAppSettings({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'App Settings',
                        style: AppTypography.sectionHeading,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFF2563EB),
                  ),
                  title: const Text(
                    'Language',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('English (Default)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language switched to English (US)'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.volume_up_rounded,
                    color: Color(0xFF10B981),
                  ),
                  title: const Text(
                    'Sound Effects & Audio',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Quiz timers and battle victory sound'),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.vibration_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  title: const Text(
                    'Haptic Vibration',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Tactile feedback on correct/wrong answers',
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4. INVITE FRIENDS / REFERRAL MODAL
  // ---------------------------------------------------------------------------
  static void showInviteFriends({
    required BuildContext context,
    required String referralCode,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFF059669),
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Invite Friends & Earn 100 Coins',
                style: AppTypography.sectionHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Share your unique referral code with friends. Both of you receive 100 Bonus Coins on sign-up!',
                style: AppTypography.supporting,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // Code Box with Copy Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR REFERRAL CODE',
                          style: AppTypography.microTag,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          referralCode,
                          style: AppTypography.metricValue.copyWith(
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Referral code $referralCode copied to clipboard!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 5. ROLE SELECTOR MODAL
  // ---------------------------------------------------------------------------
  static void showRoleSelector({
    required BuildContext context,
    required UserProfile profile,
    required ValueChanged<UserProfile> onSave,
  }) {
    const roles = [
      'Student',
      '70th BPSC Aspirant',
      'UPSC Civil Services Aspirant',
      'SSC CGL / CHSL Aspirant',
      'Railway RRB Aspirant',
      'Banking (IBPS / SBI) Aspirant',
      'College Graduate',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Target Exam / Role',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 12),
              ...roles.map((role) {
                final isSelected = profile.examPreparingFor == role;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFF94A3B8),
                  ),
                  title: Text(
                    role,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    final updated = profile.copyWith(examPreparingFor: role);
                    onSave(updated);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 6. SIMPLE INFO VIEWER MODAL (Terms / Privacy / About)
  // ---------------------------------------------------------------------------
  static void showInfoModal({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTypography.sectionHeading),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(content, style: AppTypography.bodyMedium),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceSubtle,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.brandGreen,
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
