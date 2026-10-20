import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'overview_charts.dart';
import 'banner_image_data.dart';

class OverviewTab extends StatefulWidget {
  final VoidCallback onGoToTests;
  final VoidCallback onGoToFinance;
  final VoidCallback onGoToUsers;
  final VoidCallback onGoToAiCreator;
  final VoidCallback onGoToNotifications;
  final VoidCallback? onGoToCategories;
  final VoidCallback? onGoToLiveQuiz;
  final VoidCallback? onGoToTournaments;

  const OverviewTab({
    super.key,
    required this.onGoToTests,
    required this.onGoToFinance,
    required this.onGoToUsers,
    required this.onGoToAiCreator,
    required this.onGoToNotifications,
    this.onGoToCategories,
    this.onGoToLiveQuiz,
    this.onGoToTournaments,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  String _totalUsers = '12,458';
  String _totalQuizzes = '386';
  String _totalQuestions = '9,842';
  String _totalAttempts = '28,731';
  final String _activeLiveQuiz = '3';

  @override
  void initState() {
    super.initState();
    _fetchLiveMetricsIfAvailable();
  }

  Future<void> _fetchLiveMetricsIfAvailable() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    try {
      final userRes = await client.from('profiles').select('id');
      final usersCount = (userRes as List).length;

      final testsRes = await client.from('tests').select('id');
      final testsCount = (testsRes as List).length;

      final questionsRes = await client.from('questions').select('id');
      final questionsCount = (questionsRes as List).length;

      final attemptsRes = await client.from('attempts').select('id');
      final attemptsCount = (attemptsRes as List).length;

      if (mounted) {
        setState(() {
          if (usersCount > 0) _totalUsers = _formatCount(usersCount);
          if (testsCount > 0) _totalQuizzes = _formatCount(testsCount);
          if (questionsCount > 0) _totalQuestions = _formatCount(questionsCount);
          if (attemptsCount > 0) _totalAttempts = _formatCount(attemptsCount);
        });
      }
    } catch (_) {
      // Fallback to pixel-perfect default mock data
    }
  }

  String _formatCount(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: Welcome Banner (Left) + Quick Actions (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 980) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 57,
                      child: _buildWelcomeBanner(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 43,
                      child: _buildQuickActionsCard(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildWelcomeBanner(),
                    const SizedBox(height: 16),
                    _buildQuickActionsCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // ROW 2: 5 Metric Cards
          _buildMetricCardsRow(),
          const SizedBox(height: 20),

          // ROW 3: 3 Analytics Charts
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1180) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 46, child: _buildQuizAttemptsOverviewCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 29, child: _buildUserGrowthCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 25, child: _buildCategoryWiseCard()),
                  ],
                );
              } else if (constraints.maxWidth > 768) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildQuizAttemptsOverviewCard()),
                        const SizedBox(width: 20),
                        Expanded(child: _buildUserGrowthCard()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryWiseCard(),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildQuizAttemptsOverviewCard(),
                    const SizedBox(height: 16),
                    _buildUserGrowthCard(),
                    const SizedBox(height: 16),
                    _buildCategoryWiseCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // ROW 4: 4 Bottom Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1460) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentQuizzesCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRecentUsersCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRecentActivityCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPlatformStatusCard()),
                  ],
                );
              } else if (constraints.maxWidth > 768) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildRecentQuizzesCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRecentUsersCard()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildRecentActivityCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPlatformStatusCard()),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildRecentQuizzesCard(),
                    const SizedBox(height: 16),
                    _buildRecentUsersCard(),
                    const SizedBox(height: 16),
                    _buildRecentActivityCard(),
                    const SizedBox(height: 16),
                    _buildPlatformStatusCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 1: WELCOME BANNER
  // ==========================================
  Widget _buildWelcomeBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 450;
        return Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEEF2FF),
                Color(0xFFE0E7FF),
                Color(0xFFF0FDF4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Content Left
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome Back,\n',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.15,
                            ),
                          ),
                          TextSpan(
                            text: 'Admin! 👋',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: isSmall ? 210 : 300,
                      child: const Text(
                        'Manage quizzes, users, content and track platform performance all in one place.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Illustration Right
              if (!isSmall)
                Positioned(
                  right: 8,
                  bottom: 0,
                  top: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Image.memory(
                      kBannerCharacterBytes,
                      height: 190,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  late final List<Map<String, dynamic>> _quickActions = [
    {
      'id': 'create_quiz',
      'label': 'Create Quiz',
      'icon': Icons.add_circle_outline_rounded,
      'color': const Color(0xFF6366F1),
      'enabled': true,
    },
    {
      'id': 'add_question',
      'label': 'Add Question',
      'icon': Icons.description_outlined,
      'color': const Color(0xFF0EA5E9),
      'enabled': true,
    },
    {
      'id': 'manage_categories',
      'label': 'Manage Categories',
      'icon': Icons.folder_outlined,
      'color': const Color(0xFF10B981),
      'enabled': true,
    },
    {
      'id': 'start_live_quiz',
      'label': 'Start Live Quiz',
      'icon': Icons.cell_tower_rounded,
      'color': const Color(0xFFEF4444),
      'enabled': true,
    },
    {
      'id': 'create_tournament',
      'label': 'Create Tournament',
      'icon': Icons.emoji_events_outlined,
      'color': const Color(0xFFF59E0B),
      'enabled': true,
    },
    {
      'id': 'invite_users',
      'label': 'Invite Users',
      'icon': Icons.person_add_alt_1_outlined,
      'color': const Color(0xFFEC4899),
      'enabled': true,
    },
  ];

  VoidCallback _getActionCallback(String id) {
    switch (id) {
      case 'create_quiz':
        return widget.onGoToTests;
      case 'add_question':
        return widget.onGoToAiCreator;
      case 'manage_categories':
        return widget.onGoToCategories ?? widget.onGoToTests;
      case 'start_live_quiz':
        return widget.onGoToLiveQuiz ?? widget.onGoToTests;
      case 'create_tournament':
        return widget.onGoToTournaments ?? widget.onGoToTests;
      case 'invite_users':
        return widget.onGoToUsers;
      default:
        return () {};
    }
  }

  void _showCustomizeQuickActionsDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.tune_rounded, color: Color(0xFFEC4899), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Customize Quick Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose which quick action shortcuts appear on your dashboard overview.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _quickActions.length,
                        separatorBuilder: (ctx, idx) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final action = _quickActions[index];
                          final isEnabled = action['enabled'] as bool;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: action['color'] as Color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    action['icon'] as IconData,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    action['label'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: isEnabled,
                                  activeTrackColor: const Color(0xFFEC4899),
                                  onChanged: (val) {
                                    setDialogState(() {
                                      action['enabled'] = val;
                                    });
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              for (var action in _quickActions) {
                                action['enabled'] = true;
                              }
                            });
                            setState(() {});
                          },
                          child: const Text(
                            'Reset to Default',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quick Actions updated successfully'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color(0xFF0F172A),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ROW 1: QUICK ACTIONS
  // ==========================================
  Widget _buildQuickActionsCard() {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Quick Actions
          Row(
            children: const [
              Icon(
                Icons.bolt_rounded,
                size: 20,
                color: Color(0xFFEC4899),
              ),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Spacer(),

          // Quick Action Icons Row: Actions + Customize button to the right of Invite Users
          LayoutBuilder(
            builder: (context, constraints) {
              final actionWidgets = [
                ..._quickActions
                    .where((a) => a['enabled'] == true)
                    .map((a) => _buildQuickActionButton(
                          icon: a['icon'] as IconData,
                          label: a['label'] as String,
                          color: a['color'] as Color,
                          onTap: _getActionCallback(a['id'] as String),
                        )),
                _buildQuickActionButton(
                  icon: Icons.settings_outlined,
                  label: 'Customize',
                  color: const Color(0xFF64748B),
                  onTap: _showCustomizeQuickActionsDialog,
                ),
              ];

              if (constraints.maxWidth < 460) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: actionWidgets
                        .map((w) => Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: w,
                            ))
                        .toList(),
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actionWidgets,
              );
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
                height: 1.15,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ROW 2: 5 METRIC CARDS
  // ==========================================
  Widget _buildMetricCardsRow() {
    final metrics = [
      (
        title: 'Total Users',
        value: _totalUsers,
        growth: '+12%',
        subtitle: '+1,324 this week',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [10.0, 12.0, 11.5, 14.0, 16.0, 18.0, 22.0],
      ),
      (
        title: 'Total Quizzes',
        value: _totalQuizzes,
        growth: '+8%',
        subtitle: '+28 this week',
        icon: Icons.description_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [8.0, 9.0, 8.5, 11.0, 12.0, 13.5, 16.0],
      ),
      (
        title: 'Total Questions',
        value: _totalQuestions,
        growth: '+15%',
        subtitle: '+1,280 this week',
        icon: Icons.help_outline_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [12.0, 13.0, 15.0, 14.5, 17.0, 19.0, 24.0],
      ),
      (
        title: 'Total Attempts',
        value: _totalAttempts,
        growth: '+22%',
        subtitle: '+5,182 this week',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [14.0, 15.5, 18.0, 17.5, 21.0, 25.0, 30.0],
      ),
      (
        title: 'Active Live Quiz',
        value: _activeLiveQuiz,
        growth: '',
        subtitle: '+1 started today',
        icon: Icons.podcasts_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [2.0, 3.0, 2.5, 4.0, 3.2, 4.5, 3.8],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 1100
            ? (constraints.maxWidth - (16 * 4)) / 5
            : constraints.maxWidth > 700
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((m) {
            return Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon Squircle / Circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: m.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(m.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Middle Value and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            Text(
                              m.value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (m.growth.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.arrow_upward_rounded, size: 9, color: Color(0xFF10B981)),
                                    const SizedBox(width: 2),
                                    Text(
                                      m.growth,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.subtitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sparkline Curve
                  SparklineChart(
                    data: m.sparklineData,
                    color: m.color,
                    width: 58,
                    height: 30,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ==========================================
  // ROW 3: QUIZ ATTEMPTS OVERVIEW (CHART 1)
  // ==========================================
  Widget _buildQuizAttemptsOverviewCard() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1), size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Quiz Attempts Overview',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text(
                      'Oct 12, 2026 - Oct 18, 2026',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chart
          const QuizAttemptsLineChart(height: 165),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 3: USER GROWTH (CHART 2)
  // ==========================================
  Widget _buildUserGrowthCard() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.people_alt_rounded, color: Color(0xFF3B82F6), size: 19),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'User Growth',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Last 7 Days',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const UserGrowthBarChart(height: 165),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 3: CATEGORY WISE QUIZZES (CHART 3)
  // ==========================================
  Widget _buildCategoryWiseCard() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pie_chart_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Category Wise Quizzes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const CategoryWiseDonutChart(),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 4: RECENT QUIZZES
  // ==========================================
  Widget _buildRecentQuizzesCard() {
    final quizzes = [
      (
        title: 'General Science Mock Test',
        subtitle: 'General Science • 50 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 18, 2026',
        icon: Icons.science_outlined,
        color: const Color(0xFF6366F1),
      ),
      (
        title: 'Current Affairs - October 2026',
        subtitle: 'Current Affairs • 30 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 17, 2026',
        icon: Icons.public_outlined,
        color: const Color(0xFFF59E0B),
      ),
      (
        title: 'Basic Mathematics',
        subtitle: 'Mathematics • 40 Questions',
        status: 'Draft',
        isPublished: false,
        date: 'Oct 16, 2026',
        icon: Icons.calculate_outlined,
        color: const Color(0xFFEC4899),
      ),
      (
        title: 'Reasoning Practice Set',
        subtitle: 'Reasoning • 35 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 15, 2026',
        icon: Icons.psychology_outlined,
        color: const Color(0xFF0EA5E9),
      ),
      (
        title: 'Physics - Important Questions',
        subtitle: 'Physics • 50 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 14, 2026',
        icon: Icons.biotech_outlined,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Container(
      height: 355,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.description_outlined, color: Color(0xFFEF4444), size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Recent Quizzes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: widget.onGoToTests,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...quizzes.map((quiz) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.5),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: quiz.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(quiz.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quiz.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: quiz.isPublished
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quiz.status,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: quiz.isPublished
                                ? const Color(0xFF10B981)
                                : const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        quiz.date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 4: RECENT USERS
  // ==========================================
  Widget _buildRecentUsersCard() {
    final users = [
      (initials: 'RK', name: 'Rahul Kumar', email: 'rahulkumar@gmail.com', date: 'Oct 18, 2026', color: const Color(0xFF6366F1)),
      (initials: 'SP', name: 'Sneha Patel', email: 'sneha.patel@gmail.com', date: 'Oct 18, 2026', color: const Color(0xFF3B82F6)),
      (initials: 'AM', name: 'Amit Mishra', email: 'amitmishra123@gmail.com', date: 'Oct 17, 2026', color: const Color(0xFF8B5CF6)),
      (initials: 'PK', name: 'Pooja Kumari', email: 'pooja.kumari@email.com', date: 'Oct 17, 2026', color: const Color(0xFFEC4899)),
      (initials: 'VS', name: 'Vikash Singh', email: 'vikashsingh@email.com', date: 'Oct 16, 2026', color: const Color(0xFF7C3AED)),
    ];

    return Container(
      height: 355,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.people_alt_rounded, color: Color(0xFF3B82F6), size: 19),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Recent Users',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: widget.onGoToUsers,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...users.map((user) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: user.color,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.date,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 4: RECENT ACTIVITY
  // ==========================================
  Widget _buildRecentActivityCard() {
    final activities = [
      (
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFF59E0B),
        title: 'New quiz created: General Science Mock Test',
        time: '2 minutes ago',
      ),
      (
        icon: Icons.person_rounded,
        color: const Color(0xFF3B82F6),
        title: 'New user registered: Rahul Kumar',
        time: '15 minutes ago',
      ),
      (
        icon: Icons.play_circle_fill_rounded,
        color: const Color(0xFF10B981),
        title: 'Live quiz started: Daily Quiz - 18 Oct',
        time: '1 hour ago',
      ),
      (
        icon: Icons.help_rounded,
        color: const Color(0xFF0EA5E9),
        title: '50 new questions added in Mathematics',
        time: '2 hours ago',
      ),
      (
        icon: Icons.flag_rounded,
        color: const Color(0xFF8B5CF6),
        title: 'Quiz attempts reached 10,000',
        time: '3 hours ago',
      ),
      (
        icon: Icons.military_tech_rounded,
        color: const Color(0xFFF59E0B),
        title: 'Tournament ended: Weekly Challenge',
        time: '3 hours ago',
      ),
    ];

    return Container(
      height: 355,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Color(0xFFEF4444), size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: widget.onGoToNotifications,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...activities.map((act) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.5),
              child: Row(
                children: [
                  Icon(act.icon, color: act.color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      act.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    act.time,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 4: PLATFORM STATUS
  // ==========================================
  Widget _buildPlatformStatusCard() {
    final services = [
      'Database',
      'API Services',
      'Live Quiz Server',
      'Payment Gateway',
      'Notifications',
      'File Storage',
    ];

    return Container(
      height: 355,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Platform Status',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'All Systems Operational',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...services.map((svc) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            svc,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Operational',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Platform Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.speed_rounded, size: 14, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text('Uptime', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Text(
                '99.9%',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text('Response Time', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Text(
                '120ms',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: const [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 14, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text('Last Updated', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Text(
                'Oct 18, 2026 10:24 AM',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
