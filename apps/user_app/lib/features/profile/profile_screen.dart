import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final void Function(UserProfile updatedProfile) onUpdateProfile;
  final VoidCallback onLogout;
  final VoidCallback onOpenSupport;
  final VoidCallback onOpenFeedback;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onUpdateProfile,
    required this.onLogout,
    required this.onOpenSupport,
    required this.onOpenFeedback,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _currentProfile;

  // Controllers for edit modal
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _stateController;
  late final TextEditingController _examController;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _nameController = TextEditingController(text: _currentProfile.name);
    _phoneController = TextEditingController(text: _currentProfile.phone ?? '');
    _stateController = TextEditingController(text: _currentProfile.state ?? '');
    _examController = TextEditingController(text: _currentProfile.examPreparingFor ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _examController.dispose();
    super.dispose();
  }

  void _openEditProfileDialog() {
    _nameController.text = _currentProfile.name;
    _phoneController.text = _currentProfile.phone ?? '';
    _stateController.text = _currentProfile.state ?? '';
    _examController.text = _currentProfile.examPreparingFor ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emerald Gradient Header matching React Edit Profile Modal
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: AppRadii.borderMd,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EDIT PROFILE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Personal details & exam preferences',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Preview with Camera badge
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primarySubtle,
                              child: Text(
                                _nameController.text.isNotEmpty ? _nameController.text[0] : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Fields
                      const Text('Full Name', style: AppTypography.labelLarge),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('Phone Number', style: AppTypography.labelLarge),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('State', style: AppTypography.labelLarge),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _stateController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                                    border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Target Exam', style: AppTypography.labelLarge),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _examController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.shield_outlined, color: AppColors.primary),
                                    border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Cancel',
                              variant: AppButtonVariant.secondary,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              label: 'Update Profile',
                              variant: AppButtonVariant.primary,
                              onPressed: () {
                                final updated = _currentProfile.copyWith(
                                  name: _nameController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  state: _stateController.text.trim(),
                                  examPreparingFor: _examController.text.trim(),
                                );
                                setState(() => _currentProfile = updated);
                                widget.onUpdateProfile(updated);
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated successfully!'),
                                    backgroundColor: AppColors.primary,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text('Are you sure you want to sign out from your Rankearn account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onLogout();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _currentProfile.subscriptionStatus == 'premium';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Master Profile Header Card matching React Profile.tsx:298-345
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Top User Section
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.canvasDark.withAlpha(120),
                  child: Row(
                    children: [
                      // Avatar with Camera edit button
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              _currentProfile.name.isNotEmpty ? _currentProfile.name[0] : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _openEditProfileDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // User Info Stack
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _currentProfile.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isPro)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      border: Border.all(color: const Color(0xFFFDE68A)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.star, color: Color(0xFFD97706), size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'PRO',
                                          style: TextStyle(
                                            color: Color(0xFFB45309),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Target Exam Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withAlpha(60)),
                              ),
                              child: Text(
                                _currentProfile.examPreparingFor ?? '70th BPSC Aspirant',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: const [
                                Icon(Icons.calendar_today, size: 12, color: Color(0xFF3B82F6)),
                                SizedBox(width: 4),
                                Text(
                                  'Joined Oct 2026',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Performance Summary Quick Stats
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    children: [
                      _buildPerformanceStat('Tests Taken', '18', Icons.quiz),
                      _buildPerformanceStat('Avg Score', '78%', Icons.analytics),
                      _buildPerformanceStat('Rank', '#14', Icons.military_tech),
                      _buildPerformanceStat('Won Coins', '${_currentProfile.coins}', Icons.monetization_on),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. PRO Pass Upgrade Card (Matching React Subscription.tsx)
          _buildProPassCard(isPro),
          const SizedBox(height: 16),

          // 3. Account Details Section Card
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Header with Edit Pencil Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Color(0xFF3B82F6), size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Account Details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 14),
                        ),
                        onPressed: _openEditProfileDialog,
                        tooltip: 'Edit Profile',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Section Rows
                _buildAccountDetailRow(
                  icon: Icons.mail_outline,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  label: 'EMAIL ADDRESS',
                  value: _currentProfile.email,
                ),
                const Divider(height: 1, color: AppColors.border),
                _buildAccountDetailRow(
                  icon: Icons.phone_outlined,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFECFDF5),
                  label: 'PHONE NUMBER',
                  value: _currentProfile.phone ?? '+91 98765 43210',
                ),
                const Divider(height: 1, color: AppColors.border),
                _buildAccountDetailRow(
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  iconBg: const Color(0xFFEEF2FF),
                  label: 'STATE',
                  value: _currentProfile.state ?? 'Bihar, India',
                ),
                const Divider(height: 1, color: AppColors.border),
                _buildAccountDetailRow(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFF5F3FF),
                  label: 'SUBSCRIPTION PLAN',
                  value: isPro ? 'PRO Member (Active Pass)' : 'Free Plan (Basic)',
                ),
                const Divider(height: 1, color: AppColors.border),

                // Sign Out Row
                InkWell(
                  onTap: _confirmLogout,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: AppRadii.borderMd,
                          ),
                          child: const Icon(Icons.logout, color: Color(0xFFE11D48), size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'SESSION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                              Text(
                                'Sign Out from Account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFFFDA4AF)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Help & Support Card
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildNavRow(
                  icon: Icons.chat_bubble_outline,
                  title: 'Support Chat',
                  subtitle: 'Get quick help with tests and wallet',
                  onTap: widget.onOpenSupport,
                ),
                const Divider(height: 1, color: AppColors.border),
                _buildNavRow(
                  icon: Icons.star_outline,
                  title: 'Give Feedback',
                  subtitle: 'Share your thoughts and suggestions',
                  onTap: widget.onOpenFeedback,
                ),
                const Divider(height: 1, color: AppColors.border),
                _buildNavRow(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy & Terms',
                  subtitle: 'Read our platform terms and safety policies',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Platform Legal Terms & Policy...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProPassCard(bool isPro) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: AppRadii.borderSm,
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Rankearn PRO Pass',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              if (isPro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE (28 DAYS)',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                )
              else
                const Text(
                  '₹250 / Month',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB45309),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '• Unlimited Full Mock Tests for all State & Central Exams\n• 50% Flat Entry Discount on Daily Paid Tournaments\n• PRO Golden Badge on Profile & All-India Leaderboard',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF78350F),
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (!isPro)
            AppButton(
              label: 'Upgrade to PRO (5,000 Coins) →',
              variant: AppButtonVariant.primary,
              fullWidth: true,
              onPressed: () {
                if (_currentProfile.coins < 5000) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You need 5,000 Coins to activate PRO Pass. Top up your wallet first.'),
                      backgroundColor: Color(0xFFE11D48),
                    ),
                  );
                  return;
                }
                final updated = _currentProfile.copyWith(
                  coins: _currentProfile.coins - 5000,
                  subscriptionStatus: 'premium',
                );
                setState(() => _currentProfile = updated);
                widget.onUpdateProfile(updated);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Congratulations! Welcome to Rankearn PRO 🎉'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadii.borderMd,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.canvasDark,
                borderRadius: AppRadii.borderMd,
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}
