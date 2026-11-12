import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final AdminDashboardRepository? repository;
  final AdminDashboardSnapshot? initialSnapshot;

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
    this.repository,
    this.initialSnapshot,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  static const String _quickActionsPrefsKey = 'admin_overview_quick_actions_v1';
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late final AdminDashboardRepository _repository;
  late DateTimeRange _attemptsDateRange;
  String _userGrowthPeriod = 'Last 7 Days';

  AdminDashboardSnapshot? _snapshot;
  bool _isLoading = true;
  String? _errorMessage;

  final List<Map<String, dynamic>> _quickActions = [
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

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AdminDashboardRepository();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _attemptsDateRange = DateTimeRange(
      start: today.subtract(const Duration(days: 6)),
      end: today,
    );

    if (widget.initialSnapshot != null) {
      _snapshot = widget.initialSnapshot;
      _isLoading = false;
    } else {
      _loadQuickActionPreferences();
      _fetchDashboardData();
    }
  }

  Future<void> _loadQuickActionPreferences() async {
    try {
      Map<String, bool>? prefsMap = await _repository.fetchQuickActionPreferences();
      if (prefsMap == null) {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getStringList(_quickActionsPrefsKey);
        if (saved != null) {
          prefsMap = {for (final a in _quickActions) a['id'] as String: saved.contains(a['id'])};
        }
      }

      if (prefsMap != null && mounted) {
        setState(() {
          for (final action in _quickActions) {
            final id = action['id'] as String;
            if (prefsMap!.containsKey(id)) {
              action['enabled'] = prefsMap[id] ?? true;
            }
          }
        });
      }
    } catch (_) {
      // Default shortcuts remain enabled
    }
  }

  Future<void> _saveQuickActionPreferences() async {
    final map = <String, bool>{
      for (final a in _quickActions) a['id'] as String: a['enabled'] == true,
    };
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabledIds = map.entries.where((e) => e.value).map((e) => e.key).toList();
      await prefs.setStringList(_quickActionsPrefsKey, enabledIds);
      await _repository.saveQuickActionPreferences(map);
    } catch (_) {
      // Non-fatal UI preference persistence
    }
  }

  Future<void> _fetchDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _repository.fetchOverviewSnapshot(
      attemptsStartDate: _attemptsDateRange.start,
      attemptsEndDate: _attemptsDateRange.end,
      userGrowthPeriod: _userGrowthPeriod,
    );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _snapshot = data;
          _isLoading = false;
          _errorMessage = null;
        });
      case Failure(:final message):
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
    }
  }

  Future<void> _pickAttemptsDateRange() async {
    final picked = await AppDateRangePicker.show(
      context: context,
      initialDateRange: _attemptsDateRange,
    );

    if (picked != null && mounted) {
      setState(() {
        _attemptsDateRange = picked;
      });
      await _fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],

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

          // ROW 2: 5 Live KPI Metric Cards
          _buildMetricCardsRow(),
          const SizedBox(height: 20),

          // ROW 3: 3 Live Analytics Charts
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

          // ROW 4: 4 Live Activity & Telemetry Cards
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

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorRoseLight,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: _isLoading ? null : _fetchDashboardData,
            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
            label: Text(
              'Retry',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 1: WELCOME BANNER
  // ==========================================
  Widget _buildWelcomeBanner() {
    final currentUser = SupabaseConfig.clientSafe?.auth.currentUser;
    final rawName = (currentUser?.userMetadata?['name'] ??
            currentUser?.userMetadata?['full_name'])
        ?.toString()
        .trim();
    final adminDisplayName =
        (rawName != null && rawName.isNotEmpty) ? rawName : 'Admin';

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
                    Row(
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome Back, ',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontHeading,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.15,
                                  ),
                                ),
                                TextSpan(
                                  text: '$adminDisplayName! 👋',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontHeading,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: 'Refresh live metrics',
                          child: InkWell(
                            onTap: _isLoading ? null : _fetchDashboardData,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.8,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.brandPurple,
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.refresh_rounded,
                                      size: 13,
                                      color: AppColors.brandPurple,
                                    ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isLoading ? 'Syncing...' : 'Sync',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontHeading,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brandPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage quizzes, users, content and track live platform performance all in one place.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
              subtitle:
                  'Choose which quick action shortcuts appear on your dashboard overview',
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
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(this.context);
                    await _saveQuickActionPreferences();
                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                    }
                    if (!mounted) return;
                    messenger.showSnackBar(
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
                  separatorBuilder: (ctx, idx) =>
                      Divider(height: 1, color: AppColors.borderSubtle),
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
  // ROW 2: 5 METRIC CARDS (LIVE DATABASE METRICS)
  // ==========================================
  Widget _buildMetricCardsRow() {
    final snap = _snapshot;
    final bool loadingInitial = _isLoading && snap == null;

    final metrics = [
      (
        title: 'Total Users',
        value: loadingInitial ? '—' : _formatCount(snap?.usersMetric.total ?? 0),
        growth: loadingInitial ? '' : (snap?.usersMetric.growthLabel ?? ''),
        isPositive: snap?.usersMetric.isGrowthPositive ?? true,
        subtitle: loadingInitial
            ? 'Loading users...'
            : (snap?.usersMetric.subtitle ?? '0 this week'),
        icon: Icons.people_alt_rounded,
        color: AppColors.brandBlue,
        sparklineData: snap?.usersMetric.sparklineData,
        onTap: widget.onGoToUsers,
      ),
      (
        title: 'Total Quizzes',
        value: loadingInitial ? '—' : _formatCount(snap?.quizzesMetric.total ?? 0),
        growth: loadingInitial ? '' : (snap?.quizzesMetric.growthLabel ?? ''),
        isPositive: snap?.quizzesMetric.isGrowthPositive ?? true,
        subtitle: loadingInitial
            ? 'Loading quizzes...'
            : (snap?.quizzesMetric.subtitle ?? '0 this week'),
        icon: Icons.description_rounded,
        color: AppColors.brandGreen,
        sparklineData: snap?.quizzesMetric.sparklineData,
        onTap: widget.onGoToTests,
      ),
      (
        title: 'Total Questions',
        value: loadingInitial ? '—' : _formatCount(snap?.questionsMetric.total ?? 0),
        growth: loadingInitial ? '' : (snap?.questionsMetric.growthLabel ?? ''),
        isPositive: snap?.questionsMetric.isGrowthPositive ?? true,
        subtitle: loadingInitial
            ? 'Loading questions...'
            : (snap?.questionsMetric.subtitle ?? '0 this week'),
        icon: Icons.help_outline_rounded,
        color: AppColors.coinGold,
        sparklineData: snap?.questionsMetric.sparklineData,
        onTap: widget.onGoToTests,
      ),
      (
        title: 'Total Attempts',
        value: loadingInitial ? '—' : _formatCount(snap?.attemptsMetric.total ?? 0),
        growth: loadingInitial ? '' : (snap?.attemptsMetric.growthLabel ?? ''),
        isPositive: snap?.attemptsMetric.isGrowthPositive ?? true,
        subtitle: loadingInitial
            ? 'Loading attempts...'
            : (snap?.attemptsMetric.subtitle ?? '0 this week'),
        icon: Icons.emoji_events_rounded,
        color: AppColors.battleAdminPurple,
        sparklineData: snap?.attemptsMetric.sparklineData,
        onTap: widget.onGoToTests,
      ),
      (
        title: 'Active Live Quiz',
        value: loadingInitial
            ? '—'
            : _formatCount(snap?.activeLiveQuizzesCount ?? 0),
        growth: '',
        isPositive: true,
        subtitle: loadingInitial
            ? 'Checking live schedule...'
            : (snap != null && snap.activeLiveQuizzesCount > 0
                ? 'Active live contests'
                : 'No live contest active'),
        icon: Icons.podcasts_rounded,
        color: AppColors.liveRed,
        sparklineData: snap?.activeLiveQuizzesSparkline,
        onTap: widget.onGoToLiveQuiz ?? widget.onGoToTests,
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
              isGrowthPositive: m.isPositive,
              subtitle: m.subtitle,
              icon: m.icon,
              color: m.color,
              sparklineData: m.sparklineData,
              onTap: m.onTap,
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
    final chart = _snapshot?.attemptsChart;
    final rangeText =
        '${_formatFullDate(_attemptsDateRange.start)} - ${_formatFullDate(_attemptsDateRange.end)}';

    return AppLineChartCard(
      title: 'Quiz Attempts Overview',
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.brandPurple,
      isLoading: _isLoading && _snapshot == null,
      dates: chart?.labels ?? const [],
      values: chart?.values ?? const [],
      highlightedIndex: chart?.highlightedIndex,
      tooltipDate: chart?.tooltipDate,
      tooltipValue: chart?.tooltipValue,
      emptyText: _errorMessage != null
          ? 'Unable to load attempts data'
          : 'No attempts recorded in selected range',
      trailingHeader: AdminTableDateRangeButton(
        text: rangeText,
        onTap: _pickAttemptsDateRange,
      ),
    );
  }

  // ==========================================
  // ROW 3: USER GROWTH (CHART 2)
  // ==========================================
  Widget _buildUserGrowthCard() {
    final chart = _snapshot?.userGrowthChart;

    return AppBarChartCard(
      title: 'User Growth',
      icon: Icons.people_alt_rounded,
      iconColor: AppColors.brandBlue,
      isLoading: _isLoading && _snapshot == null,
      dates: chart?.labels ?? const [],
      values: chart?.values ?? const [],
      emptyText: _errorMessage != null
          ? 'Unable to load user growth'
          : 'No user registrations in $_userGrowthPeriod',
      trailingHeader: AdminTableDropdown<String>(
        value: _userGrowthPeriod,
        items: const ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Year'],
        onChanged: (val) {
          if (val == _userGrowthPeriod) return;
          setState(() => _userGrowthPeriod = val);
          _fetchDashboardData();
        },
      ),
    );
  }

  // ==========================================
  // ROW 3: CATEGORY WISE QUIZZES (CHART 3)
  // ==========================================
  Widget _buildCategoryWiseCard() {
    const palette = [
      AppColors.brandBlue,
      AppColors.battleAdminPurple,
      AppColors.coinGold,
      Color(0xFF06B6D4),
      AppColors.brandPink,
      AppColors.textMuted,
    ];

    final breakdown = _snapshot?.categoryBreakdown ?? const [];
    final slices = breakdown.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      final color = _parseHexColor(item.hexColor) ?? palette[idx % palette.length];
      return DonutSlice(
        label: item.label,
        percentage: item.percentage,
        count: item.count,
        color: color,
      );
    }).toList();

    return AppDonutChartCard(
      height: 260,
      padding: const EdgeInsets.all(20),
      title: 'Category Wise Quizzes',
      icon: Icons.pie_chart_rounded,
      iconBg: AppColors.liveRed,
      isLoading: _isLoading && _snapshot == null,
      totalCount: _snapshot?.totalCategoriesQuizzesCount ?? 0,
      totalLabel: 'Total',
      chartSize: 145,
      strokeWidth: 20.0,
      strokeCap: StrokeCap.round,
      slices: slices,
    );
  }

  // ==========================================
  // ROW 4: RECENT QUIZZES
  // ==========================================
  Widget _buildRecentQuizzesCard() {
    const quizColors = [
      AppColors.brandPurple,
      AppColors.coinGold,
      AppColors.brandPink,
      AppColors.brandBlue,
      AppColors.battleAdminPurple,
    ];

    final items = (_snapshot?.recentQuizzes ?? const []).asMap().entries.map((entry) {
      final idx = entry.key;
      final q = entry.value;
      return RecentQuizItem(
        title: q.title,
        subtitle: '${q.subjectLabel} • ${q.totalQuestions} Questions',
        status: q.status,
        isPublished: q.isPublished,
        date: _formatFullDate(q.createdAt),
        icon: _iconForSubject(q.subjectLabel),
        color: quizColors[idx % quizColors.length],
        onTap: widget.onGoToTests,
      );
    }).toList();

    return AppRecentQuizzesCard(
      isLoading: _isLoading && _snapshot == null,
      quizzes: items,
      onViewAll: widget.onGoToTests,
      emptyText: _errorMessage != null ? 'Failed to load quizzes' : 'No quizzes created yet',
    );
  }

  // ==========================================
  // ROW 4: RECENT USERS
  // ==========================================
  Widget _buildRecentUsersCard() {
    const userColors = [
      AppColors.brandPurple,
      AppColors.brandBlue,
      AppColors.battleAdminPurple,
      AppColors.brandPink,
      AppColors.brandGreen,
    ];

    final items = (_snapshot?.recentUsers ?? const []).asMap().entries.map((entry) {
      final idx = entry.key;
      final u = entry.value;
      return RecentUserItem(
        initials: _initialsForName(u.name),
        name: u.name,
        email: u.email,
        date: _formatFullDate(u.createdAt),
        color: userColors[idx % userColors.length],
        onTap: widget.onGoToUsers,
      );
    }).toList();

    return AppRecentUsersCard(
      isLoading: _isLoading && _snapshot == null,
      users: items,
      onViewAll: widget.onGoToUsers,
      emptyText: _errorMessage != null ? 'Failed to load users' : 'No registered users yet',
    );
  }

  // ==========================================
  // ROW 4: RECENT ACTIVITY
  // ==========================================
  Widget _buildRecentActivityCard() {
    final items = (_snapshot?.recentActivities ?? const []).map((ev) {
      final (icon, color) = _styleForActivity(ev.type);
      return RecentActivityItem(
        icon: icon,
        color: color,
        title: ev.title,
        time: _formatTimeAgo(ev.createdAt),
        onTap: () {
          switch (ev.type) {
            case DashboardActivityType.quizCreated:
            case DashboardActivityType.attemptCompleted:
              widget.onGoToTests();
              break;
            case DashboardActivityType.liveQuiz:
              (widget.onGoToLiveQuiz ?? widget.onGoToTests)();
              break;
            case DashboardActivityType.userRegistered:
            case DashboardActivityType.userActivity:
              widget.onGoToUsers();
              break;
            case DashboardActivityType.topupRequest:
            case DashboardActivityType.withdrawalRequest:
              widget.onGoToFinance();
              break;
          }
        },
      );
    }).toList();

    return AppRecentActivityCard(
      isLoading: _isLoading && _snapshot == null,
      activities: items,
      onViewAll: widget.onGoToNotifications,
      emptyText: _errorMessage != null ? 'Failed to load activity' : 'No recent platform activity',
    );
  }

  // ==========================================
  // ROW 4: PLATFORM STATUS
  // ==========================================
  Widget _buildPlatformStatusCard() {
    final snap = _snapshot;
    if (_isLoading && snap == null) {
      return const AppPlatformStatusCard(
        isLoading: true,
        badgeText: 'Checking Systems...',
        isAllOperational: true,
      );
    }

    if (snap == null) {
      return AppPlatformStatusCard(
        badgeText: _errorMessage != null ? 'Connection Error' : 'Unavailable',
        isAllOperational: false,
        services: const [
          PlatformServiceItem(
            name: 'Database Connection',
            status: 'Offline',
            isHealthy: false,
          ),
        ],
        metrics: [
          PlatformMetricItem(
            icon: Icons.history_rounded,
            label: 'Last Attempt',
            value: _formatTimestamp(DateTime.now()),
          ),
        ],
      );
    }

    final healthyCount = snap.services.where((s) => s.isHealthy).length;
    final allOk = snap.isAllOperational;

    return AppPlatformStatusCard(
      badgeText: allOk ? 'All Systems Operational' : 'Degraded Service',
      isAllOperational: allOk,
      services: snap.services
          .map(
            (s) => PlatformServiceItem(
              name: s.name,
              status: s.status,
              isHealthy: s.isHealthy,
            ),
          )
          .toList(),
      metrics: [
        PlatformMetricItem(
          icon: Icons.verified_user_outlined,
          label: 'Health Checks',
          value: '$healthyCount/${snap.services.length} Passed',
        ),
        PlatformMetricItem(
          icon: Icons.schedule_rounded,
          label: 'Response Time',
          value: '${snap.apiLatencyMs}ms',
        ),
        PlatformMetricItem(
          icon: Icons.history_rounded,
          label: 'Last Synced',
          value: _formatTimestamp(snap.fetchedAt),
        ),
      ],
    );
  }

  // ==========================================
  // FORMAT & STYLE HELPERS
  // ==========================================
  String _formatCount(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  String _formatFullDate(DateTime dt) {
    return '${_months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  String _formatTimestamp(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year} $hour12:$min $amPm';
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _formatFullDate(dt);
  }

  String _initialsForName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      final val = int.tryParse('FF$cleaned', radix: 16);
      if (val != null) return Color(val);
    } else if (cleaned.length == 8) {
      final val = int.tryParse(cleaned, radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }

  IconData _iconForSubject(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('science') || lower.contains('chem')) {
      return Icons.science_outlined;
    } else if (lower.contains('phys')) {
      return Icons.biotech_outlined;
    } else if (lower.contains('math')) {
      return Icons.calculate_outlined;
    } else if (lower.contains('reason')) {
      return Icons.psychology_outlined;
    } else if (lower.contains('current') || lower.contains('affairs') || lower.contains('gk')) {
      return Icons.public_outlined;
    } else if (lower.contains('history') || lower.contains('polity')) {
      return Icons.menu_book_outlined;
    }
    return Icons.description_outlined;
  }

  (IconData, Color) _styleForActivity(DashboardActivityType type) {
    switch (type) {
      case DashboardActivityType.quizCreated:
        return (Icons.emoji_events_rounded, AppColors.coinGold);
      case DashboardActivityType.userRegistered:
        return (Icons.person_rounded, AppColors.brandBlue);
      case DashboardActivityType.attemptCompleted:
        return (Icons.flag_rounded, AppColors.battleAdminPurple);
      case DashboardActivityType.liveQuiz:
        return (Icons.play_circle_fill_rounded, AppColors.brandGreen);
      case DashboardActivityType.topupRequest:
      case DashboardActivityType.withdrawalRequest:
        return (Icons.account_balance_wallet_rounded, AppColors.brandOrange);
      case DashboardActivityType.userActivity:
        return (Icons.bolt_rounded, AppColors.infoBlue);
    }
  }
}
