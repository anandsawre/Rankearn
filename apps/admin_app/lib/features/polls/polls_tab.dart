import 'dart:async';
import 'dart:math' as math;
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
  late LivePollData _livePoll;

  Timer? _countdownTimer;
  Timer? _liveVoteTimer;

  @override
  void initState() {
    super.initState();
    _livePoll = LivePollData.defaultLive();
    _startTimers();
  }

  void _startTimers() {
    // 1. Countdown timer
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_livePoll.isLive && !_livePoll.isPaused && _livePoll.remainingSeconds > 0) {
        setState(() {
          _livePoll.remainingSeconds--;
        });
      }
    });

    // 2. Real-time simulated vote inflow when autoRefresh is enabled
    _liveVoteTimer?.cancel();
    _liveVoteTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!mounted) return;
      if (_livePoll.isLive &&
          !_livePoll.isPaused &&
          _livePoll.autoRefresh &&
          _livePoll.remainingSeconds > 0 &&
          _livePoll.options.isNotEmpty) {
        setState(() {
          // Weighted vote increment (Tiger gets slightly higher weight to match leader)
          final rand = math.Random();
          final index = rand.nextDouble() < 0.65 && _livePoll.options.length > 1
              ? 1 // Option B
              : rand.nextInt(_livePoll.options.length);

          _livePoll.options[index].votes += rand.nextInt(3) + 1;
          _livePoll.liveViewers += rand.nextInt(3) - 1;
          if (_livePoll.liveViewers < 2500) _livePoll.liveViewers = 2847;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _liveVoteTimer?.cancel();
    super.dispose();
  }

  void _onLaunchPoll() {
    if (_livePoll.question.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poll question cannot be empty!')),
      );
      return;
    }
    if (_livePoll.options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 options are required.')),
      );
      return;
    }

    setState(() {
      _livePoll.isLive = true;
      _livePoll.isPaused = false;
      _livePoll.remainingSeconds = _livePoll.durationSeconds;
    });

    // Sync to Supabase
    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      final newId = 'poll-${DateTime.now().millisecondsSinceEpoch}';
      final optionsList = _livePoll.options.map((o) => {'text': o.text, 'votes': o.votes}).toList();
      client.from('polls').insert({
        'id': newId,
        'question': _livePoll.question.trim(),
        'options': optionsList,
        'votes': {},
        'target_segment': 'all',
        'is_active': true,
      }).catchError((_) {});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚀 Live Poll Launched Successfully!'),
        backgroundColor: AppColors.pollLeadingGreen,
      ),
    );
  }

  void _onResetPoll() {
    setState(() {
      _livePoll = LivePollData.defaultLive();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poll reset to default.')),
    );
  }

  void _onEndPoll() {
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
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _livePoll.isLive = false;
                _livePoll.remainingSeconds = 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live Poll ended.')),
              );
            },
            child: const Text('End Poll'),
          ),
        ],
      ),
    );
  }

  void _onPauseResumePoll() {
    setState(() {
      _livePoll.isPaused = !_livePoll.isPaused;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_livePoll.isPaused ? 'Poll paused' : 'Poll resumed'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onRestartPoll() {
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
        content: const Text('Do you want to reset the timer and restart voting for this poll?'),
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
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _livePoll.isLive = true;
                _livePoll.isPaused = false;
                _livePoll.remainingSeconds = _livePoll.durationSeconds;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Poll restarted!')),
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _onShowResult() {
    final leader = _livePoll.leadingOption;
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
              _livePoll.question,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            if (leader != null)
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
                        'Leading: ${leader.label} ${leader.text} (${_livePoll.getPercentage(leader).round()}%)',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brandGreenDark),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text('Total Votes Recorded: ${_livePoll.totalVotes}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
              LivePollPreviewPanel(pollData: _livePoll),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 768 && screenWidth < 1100;

    return Container(
      color: AppColors.pollBackground, // Crisp lavender/white background token
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3-COLUMN DESKTOP LAYOUT MATCHING SCREENSHOT EXACTLY
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Create Poll (~28%)
                  Expanded(
                    flex: 28,
                    child: CreatePollPanel(
                      pollData: _livePoll,
                      onPollChanged: (updated) => setState(() => _livePoll = updated),
                      onLaunchPoll: _onLaunchPoll,
                      onReset: _onResetPoll,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Center Column: Live Poll Preview & Stats (~44%)
                  Expanded(
                    flex: 44,
                    child: LivePollPreviewPanel(
                      pollData: _livePoll,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right Column: Live Results & Poll Controls (~28%)
                  Expanded(
                    flex: 28,
                    child: LiveResultsPanel(
                      pollData: _livePoll,
                      onAutoRefreshChanged: (val) => setState(() => _livePoll.autoRefresh = val),
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
              )
            else if (isTablet)
              // 2-Column Responsive Layout for Tablet
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: CreatePollPanel(
                      pollData: _livePoll,
                      onPollChanged: (updated) => setState(() => _livePoll = updated),
                      onLaunchPoll: _onLaunchPoll,
                      onReset: _onResetPoll,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        LivePollPreviewPanel(pollData: _livePoll),
                        const SizedBox(height: 18),
                        LiveResultsPanel(
                          pollData: _livePoll,
                          onAutoRefreshChanged: (val) => setState(() => _livePoll.autoRefresh = val),
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
              )
            else
              // Single-column vertically stacked layout for Mobile
              Column(
                children: [
                  LivePollPreviewPanel(pollData: _livePoll),
                  const SizedBox(height: 16),
                  LiveResultsPanel(
                    pollData: _livePoll,
                    onAutoRefreshChanged: (val) => setState(() => _livePoll.autoRefresh = val),
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
                    pollData: _livePoll,
                    onPollChanged: (updated) => setState(() => _livePoll = updated),
                    onLaunchPoll: _onLaunchPoll,
                    onReset: _onResetPoll,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
