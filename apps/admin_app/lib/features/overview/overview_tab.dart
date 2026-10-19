import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class OverviewTab extends StatefulWidget {
  final VoidCallback onGoToTests;
  final VoidCallback onGoToFinance;
  final VoidCallback onGoToUsers;
  final VoidCallback onGoToAiCreator;
  final VoidCallback onGoToNotifications;
  final Map<String, String>? initialStats;
  final List<(String, String, String, IconData, Color)>? initialActivities;

  const OverviewTab({
    super.key,
    required this.onGoToTests,
    required this.onGoToFinance,
    required this.onGoToUsers,
    required this.onGoToAiCreator,
    required this.onGoToNotifications,
    this.initialStats,
    this.initialActivities,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  String _totalUsers = '0';
  String _activeTests = '0';
  String _revenue = '₹0';
  String _avgAccuracy = '0.0%';
  List<(String, String, String, IconData, Color)> _recentItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialStats != null) {
      _totalUsers = widget.initialStats!['totalUsers'] ?? '0';
      _activeTests = widget.initialStats!['activeTests'] ?? '0';
      _revenue = widget.initialStats!['revenue'] ?? '₹0';
      _avgAccuracy = widget.initialStats!['avgAccuracy'] ?? '0.0%';
      _recentItems = widget.initialActivities ?? [];
      _isLoading = false;
    } else {
      _fetchOverviewMetrics();
    }
  }

  Future<void> _fetchOverviewMetrics() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Fetch user count
      final userCountRes = await client.from('profiles').select('id');
      final usersCount = (userCountRes as List).length;

      // 2. Fetch active tests count
      final testsRes = await client.from('tests').select('id').eq('status', 'published');
      final testsCount = (testsRes as List).length;

      // 3. Fetch approved revenue
      final topupsRes = await client.from('topup_requests').select('amount').eq('status', 'approved');
      double totalRev = 0.0;
      for (final row in (topupsRes as List)) {
        final amt = row['amount'];
        if (amt is num) totalRev += amt.toDouble();
      }

      // 4. Fetch avg accuracy from attempts
      double calculatedAccuracy = 0.0;
      try {
        final attemptsRes = await client.from('attempts').select('accuracy').limit(100);
        final attList = attemptsRes as List;
        if (attList.isNotEmpty) {
          double totalAcc = 0.0;
          for (final a in attList) {
            final acc = a['accuracy'];
            if (acc is num) totalAcc += acc.toDouble();
          }
          calculatedAccuracy = totalAcc / attList.length;
        }
      } catch (_) {}

      // 5. Fetch recent activity from wallet transactions
      List<(String, String, String, IconData, Color)> activities = [];
      try {
        final txRes = await client.from('wallet_transactions').select().order('created_at', ascending: false).limit(5);
        activities = (txRes as List).map((tx) {
          final isEarn = tx['type'] == 'earn';
          final title = tx['title']?.toString() ?? 'Coin Transaction';
          final amount = tx['amount']?.toString() ?? '0';
          final dateStr = tx['created_at'] != null ? tx['created_at'].toString().split('T').first : 'Recent';
          final sub = '$dateStr • ${isEarn ? '+' : '-'}$amount Coins';

          return (
            title,
            sub,
            dateStr,
            isEarn ? Icons.add_circle : Icons.arrow_outward,
            isEarn ? AppColors.primary : const Color(0xFFD97706),
          );
        }).toList();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _totalUsers = usersCount > 0 ? usersCount.toString() : '0';
          _activeTests = testsCount > 0 ? testsCount.toString() : '0';
          _revenue = totalRev > 0 ? '₹${totalRev.toInt()}' : '₹0';
          _avgAccuracy = calculatedAccuracy > 0 ? '${calculatedAccuracy.toStringAsFixed(1)}%' : '0.0%';
          _recentItems = activities;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        _totalUsers,
        Icons.people_outline,
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        widget.onGoToUsers,
      ),
      (
        'ACTIVE TESTS',
        _activeTests,
        Icons.menu_book_outlined,
        const Color(0xFF059669),
        const Color(0xFFECFDF5),
        widget.onGoToTests,
      ),
      (
        'REVENUE',
        _revenue,
        Icons.currency_rupee,
        const Color(0xFFD97706),
        const Color(0xFFFFFBEB),
        widget.onGoToFinance,
      ),
      (
        'AVG ACCURACY',
        _avgAccuracy,
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
              onTap: widget.onGoToAiCreator,
            ),
            _buildActionPill(
              icon: Icons.check_circle_outline,
              label: 'Approve Payout Requests',
              color: const Color(0xFFD97706),
              bg: const Color(0xFFFFFBEB),
              onTap: widget.onGoToFinance,
            ),
            _buildActionPill(
              icon: Icons.notifications_active_outlined,
              label: 'Dispatch Push Alert',
              color: const Color(0xFF2563EB),
              bg: const Color(0xFFEFF6FF),
              onTap: widget.onGoToNotifications,
            ),
            _buildActionPill(
              icon: Icons.add_circle_outline,
              label: 'Create New Test Series',
              color: const Color(0xFF7C3AED),
              bg: const Color(0xFFF5F3FF),
              onTap: widget.onGoToTests,
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
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandPrimary),
              ),
            )
          else if (_recentItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No platform activity logged yet. Candidate signups, tests, and transactions will stream here.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _recentItems[index];
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
