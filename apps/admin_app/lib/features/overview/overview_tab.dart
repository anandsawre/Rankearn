import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
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
  String _userGrowthPeriod = 'Last 7 Days';
  String _totalUsers = '12,458';
  String _usersGrowth = '+12%';
  String _usersSubtitle = '+1,324 this week';

  String _totalQuizzes = '386';
  String _quizzesGrowth = '+8%';
  String _quizzesSubtitle = '+28 this week';

  String _totalQuestions = '9,842';
  String _questionsGrowth = '+15%';
  String _questionsSubtitle = '+1,280 this week';

  String _totalAttempts = '28,731';
  String _attemptsGrowth = '+22%';
  String _attemptsSubtitle = '+5,182 this week';

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
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      final userRes = await client.from('profiles').select('id, created_at');
      final usersList = userRes as List;
      final usersCount = usersList.length;
      final usersWeek = usersList.where((u) {
        final ca = u['created_at'];
        return ca != null && DateTime.tryParse(ca.toString())?.isAfter(oneWeekAgo) == true;
      }).length;

      final testsRes = await client.from('tests').select('id, created_at');
      final testsList = testsRes as List;
      final testsCount = testsList.length;
      final testsWeek = testsList.where((t) {
        final ca = t['created_at'];
        return ca != null && DateTime.tryParse(ca.toString())?.isAfter(oneWeekAgo) == true;
      }).length;

      final questionsRes = await client.from('questions').select('id, created_at');
      final questionsList = questionsRes as List;
      final questionsCount = questionsList.length;
      final questionsWeek = questionsList.where((q) {
        final ca = q['created_at'];
        return ca != null && DateTime.tryParse(ca.toString())?.isAfter(oneWeekAgo) == true;
      }).length;

      final attemptsRes = await client.from('attempts').select('id, created_at');
      final attemptsList = attemptsRes as List;
      final attemptsCount = attemptsList.length;
      final attemptsWeek = attemptsList.where((a) {
        final ca = a['created_at'];
        return ca != null && DateTime.tryParse(ca.toString())?.isAfter(oneWeekAgo) == true;
      }).length;

      if (mounted) {
        setState(() {
          if (usersCount > 0) {
            _totalUsers = _formatCount(usersCount);
            if (usersWeek > 0) {
              _usersSubtitle = '+$usersWeek this week';
              _usersGrowth = '+${((usersWeek / usersCount) * 100).round()}%';
            } else {
              _usersSubtitle = 'Registered platform users';
              _usersGrowth = '';
            }
          }

          if (testsCount > 0) {
            _totalQuizzes = _formatCount(testsCount);
            if (testsWeek > 0) {
              _quizzesSubtitle = '+$testsWeek this week';
              _quizzesGrowth = '+${((testsWeek / testsCount) * 100).round()}%';
            } else {
              _quizzesSubtitle = 'Published test series';
              _quizzesGrowth = '';
            }
          }

          if (questionsCount > 0) {
            _totalQuestions = _formatCount(questionsCount);
            if (questionsWeek > 0) {
              _questionsSubtitle = '+$questionsWeek this week';
              _questionsGrowth = '+${((questionsWeek / questionsCount) * 100).round()}%';
            } else {
              _questionsSubtitle = 'Active question bank';
              _questionsGrowth = '';
            }
          }

          if (attemptsCount > 0) {
            _totalAttempts = _formatCount(attemptsCount);
            if (attemptsWeek > 0) {
              _attemptsSubtitle = '+$attemptsWeek this week';
              _attemptsGrowth = '+${((attemptsWeek / attemptsCount) * 100).round()}%';
            } else {
              _attemptsSubtitle = 'Completed user attempts';
              _attemptsGrowth = '';
            }
          }
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
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 43,
                      child: _buildQuickActionsCard(),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isSmall = screenWidth < 1100;
        return Container(
          width: double.infinity,
          height: 124,
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
                padding: EdgeInsets.only(
                  left: 20,
                  top: 12,
                  bottom: 12,
                  right: isSmall ? 20 : 140,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome Back, ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.15,
                            ),
                          ),
                          TextSpan(
                            text: 'Admin! 👋',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Manage quizzes, users, content and track platform performance all in one place.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                      height: 124,
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
      'label': 'Create\nQuiz',
      'icon': Icons.add_circle_outline_rounded,
      'color': AppColors.brandPurple,
      'cardColor': AppColors.brandPurpleLight,
      'enabled': true,
    },
    {
      'id': 'add_question',
      'label': 'Add\nQuestion',
      'icon': Icons.description_outlined,
      'color': AppColors.brandBlue,
      'cardColor': AppColors.brandBlueLight,
      'enabled': true,
    },
    {
      'id': 'manage_categories',
      'label': 'Target\nExams',
      'icon': Icons.explore_outlined,
      'color': AppColors.battleAdminPurple,
      'cardColor': AppColors.battleAdminPurpleLight,
      'enabled': true,
    },
    {
      'id': 'start_live_quiz',
      'label': 'Start Live\nQuiz',
      'icon': Icons.cell_tower_rounded,
      'color': AppColors.liveRed,
      'cardColor': AppColors.liveRedLight,
      'enabled': true,
    },
    {
      'id': 'create_tournament',
      'label': 'Create\nTournament',
      'icon': Icons.emoji_events_outlined,
      'color': AppColors.coinGold,
      'cardColor': AppColors.coinGoldLight,
      'enabled': true,
    },
    {
      'id': 'invite_users',
      'label': 'Invite\nUsers',
      'icon': Icons.person_add_alt_1_outlined,
      'color': AppColors.brandPink,
      'cardColor': AppColors.brandPinkLight,
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
    AppModalDialog.show(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppModalDialog(
              title: 'Customize Quick Actions',
              subtitle: 'Choose which quick action shortcuts appear on your dashboard overview',
              iconData: Icons.tune_rounded,
              gradientColors: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
              maxWidth: 520,
              footerLeft: TextButton(
                onPressed: () {
                  setDialogState(() {
                    for (var action in _quickActions) {
                      action['enabled'] = true;
                    }
                  });
                  setState(() {});
                },
                child: Text(
                  'Reset to Default',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Quick Actions updated successfully',
                          style: TextStyle(fontFamily: AppTypography.fontHeading),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.textPrimary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _quickActions.length,
                  separatorBuilder: (ctx, idx) => Divider(height: 1, color: AppColors.borderSubtle),
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
                              (action['label'] as String).replaceAll('\n', ' '),
                              style: TextStyle(
                                fontFamily: AppTypography.fontHeading,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Switch(
                            value: isEnabled,
                            activeTrackColor: AppColors.brandPink,
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
    final activeActions = _quickActions
        .where((a) => a['enabled'] == true)
        .map((a) {
          final id = a['id'] as String;
          final color = a['color'] as Color;
          final cardColor = a['cardColor'] as Color? ?? color.withValues(alpha: 0.12);
          return QuickActionItemData(
            label: a['label'] as String,
            icon: a['icon'] as IconData,
            iconColor: color,
            cardColor: cardColor,
            onTap: _getActionCallback(id),
          );
        })
        .toList();

    return QuickActionsCard(
      height: 124,
      compact: true,
      onCustomize: _showCustomizeQuickActionsDialog,
      actions: activeActions,
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
        growth: _usersGrowth,
        subtitle: _usersSubtitle,
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [10.0, 12.0, 11.5, 14.0, 16.0, 18.0, 22.0],
      ),
      (
        title: 'Total Quizzes',
        value: _totalQuizzes,
        growth: _quizzesGrowth,
        subtitle: _quizzesSubtitle,
        icon: Icons.description_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [8.0, 9.0, 8.5, 11.0, 12.0, 13.5, 16.0],
      ),
      (
        title: 'Total Questions',
        value: _totalQuestions,
        growth: _questionsGrowth,
        subtitle: _questionsSubtitle,
        icon: Icons.help_outline_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [12.0, 13.0, 15.0, 14.5, 17.0, 19.0, 24.0],
      ),
      (
        title: 'Total Attempts',
        value: _totalAttempts,
        growth: _attemptsGrowth,
        subtitle: _attemptsSubtitle,
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [14.0, 15.5, 18.0, 17.5, 21.0, 25.0, 30.0],
      ),
      (
        title: 'Active Live Quiz',
        value: _activeLiveQuiz,
        growth: '',
        subtitle: 'Active live contests',
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
            return AdminMetricCard(
              width: cardWidth,
              title: m.title,
              value: m.value,
              growth: m.growth,
              subtitle: m.subtitle,
              icon: m.icon,
              color: m.color,
              sparklineData: m.sparklineData,
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
    return AppLineChartCard(
      title: 'Quiz Attempts Overview',
      icon: Icons.bar_chart_rounded,
      iconColor: const Color(0xFF6366F1),
      trailingHeader: AdminTableDateRangeButton(
        text: 'Oct 12, 2026 - Oct 18, 2026',
        onTap: () {},
      ),
    );
  }

  // ==========================================
  // ROW 3: USER GROWTH (CHART 2)
  // ==========================================
  Widget _buildUserGrowthCard() {
    return AppBarChartCard(
      title: 'User Growth',
      icon: Icons.people_alt_rounded,
      iconColor: const Color(0xFF3B82F6),
      trailingHeader: AdminTableDropdown<String>(
        value: _userGrowthPeriod,
        items: const ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Year'],
        onChanged: (val) {
          setState(() => _userGrowthPeriod = val);
        },
      ),
    );
  }

  // ==========================================
  // ROW 3: CATEGORY WISE QUIZZES (CHART 3)
  // ==========================================
  Widget _buildCategoryWiseCard() {
    return const AppDonutChartCard(
      height: 260,
      padding: EdgeInsets.all(20),
      title: 'Category Wise Quizzes',
      icon: Icons.pie_chart_rounded,
      iconBg: Color(0xFFEF4444),
      totalCount: 386,
      totalLabel: 'Total',
      chartSize: 145,
      strokeWidth: 20.0,
      strokeCap: StrokeCap.round,
      slices: [
        DonutSlice(label: 'General Science', percentage: 28, color: Color(0xFF3B82F6)),
        DonutSlice(label: 'Mathematics', percentage: 22, color: Color(0xFF8B5CF6)),
        DonutSlice(label: 'Reasoning', percentage: 18, color: Color(0xFFF59E0B)),
        DonutSlice(label: 'Current Affairs', percentage: 14, color: Color(0xFF06B6D4)),
        DonutSlice(label: 'Technical', percentage: 10, color: Color(0xFFEC4899)),
        DonutSlice(label: 'Others', percentage: 8, color: Color(0xFF94A3B8)),
      ],
    );
  }

  // ==========================================
  // ROW 4: RECENT QUIZZES
  // ==========================================
  Widget _buildRecentQuizzesCard() {
    return AppRecentQuizzesCard(
      onViewAll: widget.onGoToTests,
    );
  }

  // ==========================================
  // ROW 4: RECENT USERS
  // ==========================================
  Widget _buildRecentUsersCard() {
    return AppRecentUsersCard(
      onViewAll: widget.onGoToUsers,
    );
  }

  // ==========================================
  // ROW 4: RECENT ACTIVITY
  // ==========================================
  Widget _buildRecentActivityCard() {
    return AppRecentActivityCard(
      onViewAll: widget.onGoToNotifications,
    );
  }

  // ==========================================
  // ROW 4: PLATFORM STATUS
  // ==========================================
  Widget _buildPlatformStatusCard() {
    return const AppPlatformStatusCard();
  }
}
