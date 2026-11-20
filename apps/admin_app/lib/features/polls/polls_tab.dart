import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'models/live_poll_model.dart';
import 'widgets/create_poll_panel.dart';
import 'widgets/live_poll_preview_panel.dart';
import 'widgets/live_results_panel.dart';

class PollsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialPolls;
  const PollsTab({super.key, this.initialPolls});

  @override
  State<PollsTab> createState() => _PollsTabState();
}

class _PollsTabState extends State<PollsTab> {
  // Navigation: 0 = Live Poll Dashboard, 1 = Polls History
  int _selectedTab = 0;

  // Real-time Supabase active poll
  PollModel? _activePollModel;
  LivePollData? _activeLivePoll;

  // Form draft for launching a new poll (clean with zero mock data)
  LivePollData _formPoll = LivePollData.empty();

  // History polls
  List<PollModel> _historyPolls = [];
  bool _isLoadingHistory = false;

  StreamSubscription<PollModel?>? _pollSubscription;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initLivePollStream();
    _loadHistory();
  }

  void _initLivePollStream() {
    // 1. Initial fetch
    PollsRepository().getActiveLivePoll().then((poll) {
      if (mounted) {
        _applyActivePoll(poll);
      }
    });

    // 2. Real-time stream from Supabase
    _pollSubscription = PollsRepository().streamActivePoll().listen((poll) {
      if (mounted) {
        _applyActivePoll(poll);
      }
    });
  }

  void _applyActivePoll(PollModel? poll) {
    setState(() {
      _activePollModel = poll;
      if (poll != null && poll.isActive && !poll.isExpired) {
        _activeLivePoll = LivePollData.fromPollModel(poll);
      } else {
        _activeLivePoll = null;
      }
    });

    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    if (_activeLivePoll == null || !_activeLivePoll!.isLive) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_activeLivePoll != null && _activeLivePoll!.isLive && !_activeLivePoll!.isPaused) {
        if (_activeLivePoll!.remainingSeconds > 0) {
          setState(() {
            _activeLivePoll!.remainingSeconds--;
          });
        } else {
          // Timer finished -> Poll expired
          timer.cancel();
          setState(() {
            _activeLivePoll!.isLive = false;
          });
          if (_activePollModel != null) {
            PollsRepository().endPoll(_activePollModel!.id).then((_) {
              _loadHistory();
            });
          }
        }
      }
    });
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    final history = await PollsRepository().getPollHistory();
    if (mounted) {
      setState(() {
        _historyPolls = history;
        _isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _pollSubscription?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- ACTIONS ---

  Future<void> _onLaunchPoll() async {
    final question = _formPoll.question.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poll question cannot be empty!')),
      );
      return;
    }

    final validOptions = _formPoll.options
        .map((o) => o.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 non-empty options are required.')),
      );
      return;
    }

    // Launch in Supabase
    final newPoll = await PollsRepository().createAndLaunchPoll(
      question: question,
      options: validOptions,
      durationSeconds: _formPoll.durationSeconds,
      targetSegment: 'all',
    );

    if (newPoll != null) {
      setState(() {
        _formPoll = LivePollData.empty();
        _applyActivePoll(newPoll);
      });
      _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 Live Poll Launched Successfully to Candidates!'),
            backgroundColor: AppColors.pollLeadingGreen,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to launch poll. Please check backend connection.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onResetPoll() {
    setState(() {
      _formPoll = LivePollData.empty();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poll form cleared.')),
    );
  }

  void _onEndPoll() {
    final pollId = _activePollModel?.id;
    if (pollId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active poll to end.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
        title: const Row(
          children: [
            Icon(Icons.stop_circle_outlined, color: AppColors.error),
            SizedBox(width: 8),
            Text('End Live Poll?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text('Are you sure you want to end this live poll? Candidate voting will be closed immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await PollsRepository().endPoll(pollId);
              _loadHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Live Poll ended.')),
                );
              }
            },
            child: const Text('End Poll'),
          ),
        ],
      ),
    );
  }

  void _onPauseResumePoll() {
    if (_activeLivePoll == null) return;
    setState(() {
      _activeLivePoll!.isPaused = !_activeLivePoll!.isPaused;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_activeLivePoll!.isPaused ? 'Poll paused' : 'Poll resumed'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onRestartPoll() {
    final pollId = _activePollModel?.id;
    if (pollId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No poll selected to restart.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
        title: const Row(
          children: [
            Icon(Icons.refresh_rounded, color: AppColors.pollPurplePrimary),
            SizedBox(width: 8),
            Text('Restart Poll?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text('Do you want to reset the countdown timer and reopen voting for this poll?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pollPurplePrimary,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final duration = _activeLivePoll?.durationSeconds ?? 30;
              await PollsRepository().restartPoll(pollId, duration);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Poll restarted!')),
                );
              }
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _onShowResult() {
    final displayPoll = _activeLivePoll ?? (_historyPolls.isNotEmpty ? LivePollData.fromPollModel(_historyPolls.first) : null);
    if (displayPoll == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No poll results available.')),
      );
      return;
    }

    final leader = displayPoll.leadingOption;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pollCard),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.coinGold),
            SizedBox(width: 8),
            Text('Live Poll Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayPoll.question,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            if (leader != null && displayPoll.totalVotes > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandGreenLight,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: AppColors.brandGreenMuted),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.pollLeadingGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Leading: ${leader.label} ${leader.text} (${displayPoll.getPercentage(leader).round()}%)',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brandGreenDark),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text('No votes recorded yet.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text('Total Votes Recorded: ${displayPoll.totalVotes}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pollPurplePrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onShare() {
    Clipboard.setData(const ClipboardData(text: 'https://rankearn.in/polls/live'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poll URL copied to clipboard!')),
    );
  }

  void _onDownload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading poll analytics report (CSV)...'),
        backgroundColor: AppColors.pollLeadingGreen,
      ),
    );
  }

  void _onFullscreen() {
    final displayPoll = _activeLivePoll ?? _formPoll;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              LivePollPreviewPanel(pollData: displayPoll),
            ],
          ),
        ),
      ),
    );
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 768 && screenWidth < 1100;

    final hasActivePoll = _activeLivePoll != null && _activeLivePoll!.isLive;
    // Data displayed in Center and Right: if active poll exists, show it; otherwise preview the form poll draft!
    final displayPoll = hasActivePoll ? _activeLivePoll! : _formPoll;

    return Container(
      color: AppColors.pollBackground, // Crisp lavender/white background token
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP SUB-HEADER BAR: Live Poll Dashboard | Polls History (N) | Active Session Pill
            _buildTopSubHeader(hasActivePoll),
            const SizedBox(height: 18),

            // MAIN CONTENT BASED ON SELECTED TAB
            if (_selectedTab == 0)
              _buildDashboardView(isDesktop, isTablet, displayPoll, hasActivePoll)
            else
              _buildHistoryView(),
          ],
        ),
      ),
    );
  }

  /// Top Sub-Header Bar matching reference screenshot exactly
  Widget _buildTopSubHeader(bool hasActivePoll) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        final tab1 = InkWell(
          onTap: () => setState(() => _selectedTab = 0),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedTab == 0 ? AppColors.pollPurplePrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Poll Dashboard',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );

        final tab2 = InkWell(
          onTap: () {
            setState(() => _selectedTab = 1);
            _loadHistory();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedTab == 1 ? AppColors.pollPurplePrimary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: _selectedTab == 1 ? null : Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: _selectedTab == 1 ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Polls History (${_historyPolls.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 1 ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );

        final statusBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: hasActivePoll ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
            borderRadius: AppRadii.borderPill,
            border: Border.all(
              color: hasActivePoll ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: hasActivePoll ? const Color(0xFF059669) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                hasActivePoll ? 'Active Poll Session' : 'No Active Poll',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: hasActivePoll ? const Color(0xFF065F46) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );

        if (isMobile) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      tab1,
                      const SizedBox(width: 8),
                      tab2,
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: statusBadge,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderLg,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            children: [
              tab1,
              const SizedBox(width: 8),
              tab2,
              const Spacer(),
              statusBadge,
            ],
          ),
        );
      },
    );
  }

  /// 3-Column Live Poll Dashboard
  Widget _buildDashboardView(bool isDesktop, bool isTablet, LivePollData displayPoll, bool hasActivePoll) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Create Poll (~28%)
          Expanded(
            flex: 28,
            child: CreatePollPanel(
              pollData: _formPoll,
              onPollChanged: (updated) => setState(() => _formPoll = updated),
              onLaunchPoll: _onLaunchPoll,
              onReset: _onResetPoll,
            ),
          ),
          const SizedBox(width: 20),

          // Center Column: Live Poll Preview & Stats (~44%)
          Expanded(
            flex: 44,
            child: LivePollPreviewPanel(
              pollData: displayPoll,
            ),
          ),
          const SizedBox(width: 20),

          // Right Column: Live Results & Poll Controls (~28%)
          Expanded(
            flex: 28,
            child: LiveResultsPanel(
              pollData: displayPoll,
              onAutoRefreshChanged: (val) => setState(() => displayPoll.autoRefresh = val),
              onEndPoll: _onEndPoll,
              onPauseResumePoll: _onPauseResumePoll,
              onRestartPoll: _onRestartPoll,
              onShowResult: _onShowResult,
              onShare: _onShare,
              onDownload: _onDownload,
              onFullscreen: _onFullscreen,
            ),
          ),
        ],
      );
    }

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: CreatePollPanel(
              pollData: _formPoll,
              onPollChanged: (updated) => setState(() => _formPoll = updated),
              onLaunchPoll: _onLaunchPoll,
              onReset: _onResetPoll,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                LivePollPreviewPanel(pollData: displayPoll),
                const SizedBox(height: 18),
                LiveResultsPanel(
                  pollData: displayPoll,
                  onAutoRefreshChanged: (val) => setState(() => displayPoll.autoRefresh = val),
                  onEndPoll: _onEndPoll,
                  onPauseResumePoll: _onPauseResumePoll,
                  onRestartPoll: _onRestartPoll,
                  onShowResult: _onShowResult,
                  onShare: _onShare,
                  onDownload: _onDownload,
                  onFullscreen: _onFullscreen,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile single column
    return Column(
      children: [
        LivePollPreviewPanel(pollData: displayPoll),
        const SizedBox(height: 16),
        LiveResultsPanel(
          pollData: displayPoll,
          onAutoRefreshChanged: (val) => setState(() => displayPoll.autoRefresh = val),
          onEndPoll: _onEndPoll,
          onPauseResumePoll: _onPauseResumePoll,
          onRestartPoll: _onRestartPoll,
          onShowResult: _onShowResult,
          onShare: _onShare,
          onDownload: _onDownload,
          onFullscreen: _onFullscreen,
        ),
        const SizedBox(height: 16),
        CreatePollPanel(
          pollData: _formPoll,
          onPollChanged: (updated) => setState(() => _formPoll = updated),
          onLaunchPoll: _onLaunchPoll,
          onReset: _onResetPoll,
        ),
      ],
    );
  }

  /// History view listing actual past polls from Supabase
  Widget _buildHistoryView() {
    if (_isLoadingHistory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_historyPolls.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.pollCard,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_toggle_off_rounded, size: 28, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Polls in History Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create and launch your first live poll from the Live Poll Dashboard.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedTab = 0),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create a Poll'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pollPurplePrimary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Recorded Polls (${_historyPolls.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.pollPurplePrimary),
              onPressed: _loadHistory,
              tooltip: 'Refresh History',
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _historyPolls.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final poll = _historyPolls[index];
            final leader = poll.leadingOption;
            final isCurrentlyLive = poll.isActive && !poll.isExpired;

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.pollCard,
                border: Border.all(
                  color: isCurrentlyLive ? AppColors.brandGreenMuted : AppColors.borderSubtle,
                  width: isCurrentlyLive ? 1.5 : 1,
                ),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrentlyLive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                          borderRadius: AppRadii.badge,
                          border: Border.all(
                            color: isCurrentlyLive ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          isCurrentlyLive ? 'LIVE NOW' : 'COMPLETED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isCurrentlyLive ? const Color(0xFF059669) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Target: ${poll.targetSegment.toUpperCase()}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      if (poll.createdAt != null)
                        Text(
                          '${poll.createdAt!.day}/${poll.createdAt!.month}/${poll.createdAt!.year}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    poll.question,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  // Options Breakdown Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: poll.options.map((opt) {
                      final pct = poll.getPercentage(opt).round();
                      final isLeading = poll.totalVotes > 0 && opt == leader;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLeading ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                          borderRadius: AppRadii.borderMd,
                          border: Border.all(
                            color: isLeading ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${opt.label}. ${opt.text}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isLeading ? FontWeight.w700 : FontWeight.w500,
                                color: isLeading ? const Color(0xFF065F46) : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$pct% (${opt.votes})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isLeading ? const Color(0xFF059669) : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${poll.totalVotes} Total Votes',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('Relaunch Poll'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.pollPurplePrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _formPoll = LivePollData(
                              question: poll.question,
                              options: poll.options.map((o) => LivePollOption(
                                id: 'opt_${o.index}',
                                label: o.label,
                                text: o.text,
                              )).toList(),
                            );
                            _selectedTab = 0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Poll loaded into Create form! Click Launch to go live.')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
