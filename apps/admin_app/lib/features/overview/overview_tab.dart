import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class OverviewTab extends StatelessWidget {
  final VoidCallback onGoToTests;
  final VoidCallback onGoToFinance;
  final VoidCallback onGoToUsers;
  final VoidCallback onGoToAiCreator;
  final VoidCallback onGoToNotifications;

  const OverviewTab({
    super.key,
    required this.onGoToTests,
    required this.onGoToFinance,
    required this.onGoToUsers,
    required this.onGoToAiCreator,
    required this.onGoToNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Four Master Stat Cards matching AdminPanel.tsx:4057-4096
          _buildStatGrid(context),
          const SizedBox(height: 24),

          // 2. Platform Health & Backend Edge Services Monitor
          _buildPlatformHealthCard(),
          const SizedBox(height: 24),

          // 3. Quick Action Shortcut Launchpad
          _buildQuickActionLaunchpad(context),
          const SizedBox(height: 24),

          // 4. Recent Platform Transactions & Activity Feed
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  // --- 1. Four Master Stat Cards Grid ---
  Widget _buildStatGrid(BuildContext context) {
    final stats = [
      (
        'TOTAL USERS',
        '24,850',
        Icons.people_outline,
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        onGoToUsers,
      ),
      (
        'ACTIVE TESTS',
        '142',
        Icons.menu_book_outlined,
        const Color(0xFF059669),
        const Color(0xFFECFDF5),
        onGoToTests,
      ),
      (
        'REVENUE',
        '₹4,28,500',
        Icons.currency_rupee,
        const Color(0xFFD97706),
        const Color(0xFFFFFBEB),
        onGoToFinance,
      ),
      (
        'AVG ACCURACY',
        '68.4%',
        Icons.bar_chart_outlined,
        const Color(0xFF7C3AED),
        const Color(0xFFF5F3FF),
        null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600 && !isDesktop;
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 48) / 4
            : isTablet
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: stats.map((stat) {
            return InkWell(
              onTap: stat.$6,
              borderRadius: AppRadii.borderLg,
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.borderLg,
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: stat.$5,
                        borderRadius: AppRadii.borderMd,
                      ),
                      child: Icon(stat.$3, color: stat.$4, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.$1,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat.$2,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- 2. Platform Health & Security Monitor ---
  Widget _buildPlatformHealthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: AppRadii.borderSm,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Backend Infrastructure & Security Health',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          'Live Supabase PostgreSQL Database & Edge Function Proxies',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'ALL SYSTEMS OPERATIONAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Service Indicators Grid
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: const [
              _ServiceIndicator(name: 'Supabase RLS Policies', status: '100% Protected', isHealthy: true),
              _ServiceIndicator(name: 'Gemini AI Proxy Edge Function', status: 'Healthy (42ms)', isHealthy: true),
              _ServiceIndicator(name: 'Submit Quiz Scoring Engine', status: 'Active (38ms)', isHealthy: true),
              _ServiceIndicator(name: 'FCM Push Notifications Service', status: 'Connected', isHealthy: true),
              _ServiceIndicator(name: 'Financial Ledger Atomicity', status: 'Strict RPC Active', isHealthy: true),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. Quick Action Shortcut Launchpad ---
  Widget _buildQuickActionLaunchpad(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Action Shortcuts', style: AppTypography.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionPill(
              icon: Icons.psychology_outlined,
              label: 'Generate AI Mock Test',
              color: AppColors.primary,
              bg: AppColors.primarySubtle,
              onTap: onGoToAiCreator,
            ),
            _buildActionPill(
              icon: Icons.check_circle_outline,
              label: 'Approve Payout Requests',
              color: const Color(0xFFD97706),
              bg: const Color(0xFFFFFBEB),
              onTap: onGoToFinance,
            ),
            _buildActionPill(
              icon: Icons.notifications_active_outlined,
              label: 'Dispatch Push Alert',
              color: const Color(0xFF2563EB),
              bg: const Color(0xFFEFF6FF),
              onTap: onGoToNotifications,
            ),
            _buildActionPill(
              icon: Icons.add_circle_outline,
              label: 'Create New Test Series',
              color: const Color(0xFF7C3AED),
              bg: const Color(0xFFF5F3FF),
              onTap: onGoToTests,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: color.withAlpha(60)),
          borderRadius: AppRadii.borderMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Recent Platform Transactions Feed ---
  Widget _buildRecentActivitySection() {
    final recentItems = [
      ('Deposit Top-Up Approved', 'Vikram Singh • 500 Coins (UTR: 429184029182)', '10m ago', Icons.add_circle, AppColors.primary),
      ('Withdrawal Request Submitted', 'Pooja Kumari • ₹250 to UPI: pooja@ybl', '25m ago', Icons.arrow_outward, const Color(0xFFD97706)),
      ('Contest Result Declared', '70th BPSC Prelims Speed Test • 84 Participants', '1h ago', Icons.emoji_events, const Color(0xFF7C3AED)),
      ('New Student Registered', 'Anand Sawre • Target Exam: SSC CGL 2026', '2h ago', Icons.person_add, const Color(0xFF2563EB)),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Recent Platform Audit Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text('Live Stream', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = recentItems[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.$5.withAlpha(25),
                    borderRadius: AppRadii.borderSm,
                  ),
                  child: Icon(item.$4, color: item.$5, size: 18),
                ),
                title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                subtitle: Text(item.$2, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                trailing: Text(item.$3, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceIndicator extends StatelessWidget {
  final String name;
  final String status;
  final bool isHealthy;

  const _ServiceIndicator({
    required this.name,
    required this.status,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.canvasDark,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isHealthy ? AppColors.primary : const Color(0xFFE11D48),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
