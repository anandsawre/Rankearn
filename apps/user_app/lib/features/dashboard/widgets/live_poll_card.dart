import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// Interactive, Real-Time Live Poll Card for Candidates on the User App Dashboard
class LivePollCard extends StatefulWidget {
  final UserProfile profile;

  const LivePollCard({
    super.key,
    required this.profile,
  });

  @override
  State<LivePollCard> createState() => _LivePollCardState();
}

class _LivePollCardState extends State<LivePollCard> with SingleTickerProviderStateMixin {
  PollModel? _activePoll;
  int? _votedOption;
  bool _isVoting = false;
  int _remainingSeconds = 0;

  StreamSubscription<PollModel?>? _pollSub;
  Timer? _countdownTimer;

  late AnimationController _waveController;

  static const List<Color> _optionColors = [
    AppColors.brandBlue,
    AppColors.brandGreen,
    AppColors.brandPurple,
    AppColors.coinGold,
    AppColors.brandPink,
    AppColors.brandOrange,
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _subscribeToLivePoll();
  }

  void _subscribeToLivePoll() {
    // 1. Initial fetch
    PollsRepository().getActiveLivePoll().then((poll) {
      if (mounted) {
        _handlePollUpdate(poll);
      }
    });

    // 2. Real-time stream from Supabase
    _pollSub = PollsRepository().streamActivePoll().listen((poll) {
      if (mounted) {
        _handlePollUpdate(poll);
      }
    });
  }

  void _handlePollUpdate(PollModel? poll) {
    if (poll == null || !poll.isActive || poll.isExpired) {
      setState(() {
        _activePoll = null;
        _remainingSeconds = 0;
      });
      _countdownTimer?.cancel();
      return;
    }

    // Target segment filtering
    if (poll.targetSegment != 'all') {
      final isPro = widget.profile.subscriptionStatus == 'premium';
      if (poll.targetSegment == 'pro' && !isPro) {
        setState(() => _activePoll = null);
        return;
      }
      if (poll.targetSegment == 'free' && isPro) {
        setState(() => _activePoll = null);
        return;
      }
    }

    final isNewPoll = _activePoll?.id != poll.id;
    setState(() {
      _activePoll = poll;
      _remainingSeconds = poll.remainingSeconds;
    });

    if (isNewPoll) {
      _votedOption = null;
      _checkUserVoted(poll.id);
      _startTimer();
    }
  }

  Future<void> _checkUserVoted(String pollId) async {
    final voted = await PollsRepository().getUserVotedOption(pollId, widget.profile.id);
    if (mounted) {
      setState(() {
        _votedOption = voted;
      });
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    if (_remainingSeconds <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pollSub?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _castVote(int optionIndex) async {
    final poll = _activePoll;
    if (poll == null || _votedOption != null || _isVoting) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isVoting = true;
      _votedOption = optionIndex; // Optimistic update
    });

    final success = await PollsRepository().castVote(
      pollId: poll.id,
      userId: widget.profile.id,
      optionIndex: optionIndex,
    );

    if (mounted) {
      setState(() {
        _isVoting = false;
        if (!success) {
          // If failed, rollback
          _votedOption = null;
        }
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cast vote. Please try again.')),
        );
      }
    }
  }

  String _formatTimer(int seconds) {
    if (seconds <= 0) return '00:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final poll = _activePoll;
    if (poll == null) {
      return const SizedBox.shrink();
    }

    final hasVoted = _votedOption != null;
    final totalVotes = poll.totalVotes;
    final isTimeUp = _remainingSeconds <= 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: hasVoted ? const Color(0xFFE2E8F0) : AppColors.brandPurple.withAlpha(50),
          width: hasVoted ? 1.0 : 1.5,
        ),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle top colored banner accent
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 4,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.pollPurplePrimary, AppColors.brandBlue],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row: LIVE Badge, Time Left, Total Votes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LIVE POLL Badge with Red Background, White Text & Ripple Wave Dot (No shadow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: isTimeUp ? const Color(0xFFF1F5F9) : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isTimeUp ? const Color(0xFFCBD5E1) : const Color(0xFFDC2626),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isTimeUp)
                            AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                return SizedBox(
                                  width: 13,
                                  height: 13,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Expanding ripple waves
                                      CustomPaint(
                                        size: const Size(13, 13),
                                        painter: _DotWavePainter(
                                          progress: _waveController.value,
                                          color: Colors.white,
                                        ),
                                      ),
                                      // Solid center dot
                                      Container(
                                        width: 5.5,
                                        height: 5.5,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          else
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            isTimeUp ? 'POLL ENDED' : 'LIVE POLL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isTimeUp ? const Color(0xFF64748B) : Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Countdown Timer Badge (Subtly Rounded)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            _formatTimer(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Question Text
                Text(
                  poll.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 14),

                // Options List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: poll.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = poll.options[index];
                    final pct = poll.getPercentage(opt).round();
                    final isSelected = _votedOption == index;
                    final accentColor = _optionColors[index % _optionColors.length];

                    if (hasVoted) {
                      // VOTED STATE: Progress bar with percentage and checkmark
                      return Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: AppRadii.borderMd,
                          border: Border.all(
                            color: isSelected ? AppColors.pollLeadingGreen : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Animated percentage progress fill
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: pct > 0 ? (pct / 100.0).clamp(0.0, 1.0) : 0.0,
                                  heightFactor: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.pollLeadingGreen.withAlpha(35)
                                          : accentColor.withAlpha(25),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Content Row (Vertically centered)
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Letter Badge
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.pollLeadingGreen : accentColor.withAlpha(40),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        opt.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected ? Colors.white : accentColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Text
                                    Expanded(
                                      child: Text(
                                        opt.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    if (isSelected) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.brandGreenLight,
                                          borderRadius: AppRadii.badge,
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_rounded, size: 13, color: AppColors.pollLeadingGreen),
                                            SizedBox(width: 3),
                                            Text(
                                              'Your Vote',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.brandGreenDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],

                                    // Percentage
                                    Text(
                                      '$pct%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? AppColors.pollLeadingGreen : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // NOT VOTED STATE: Interactive vote button
                    return InkWell(
                      onTap: (_isVoting || isTimeUp) ? null : () => _castVote(index),
                      borderRadius: AppRadii.borderMd,
                      child: Container(
                        height: 48,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.borderMd,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Letter Badge
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(25),
                                shape: BoxShape.circle,
                                border: Border.all(color: accentColor.withAlpha(60)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Option text
                            Expanded(
                              child: Text(
                                opt.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Tap to vote icon
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: AppColors.textSecondary.withAlpha(120),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Footer Row: Total votes count
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'} recorded',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the continuous expanding wave/radar ripple animation
class _DotWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _DotWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Wave 1
    final radius1 = 2.8 + (maxRadius - 2.8) * progress;
    final alpha1 = ((1.0 - progress) * 0.75 * 255).round().clamp(0, 255);
    final paint1 = Paint()
      ..color = color.withAlpha(alpha1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, radius1, paint1);

    // Wave 2 (Phase-shifted for continuous fluid ripples)
    final progress2 = (progress + 0.5) % 1.0;
    final radius2 = 2.8 + (maxRadius - 2.8) * progress2;
    final alpha2 = ((1.0 - progress2) * 0.45 * 255).round().clamp(0, 255);
    final paint2 = Paint()
      ..color = color.withAlpha(alpha2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawCircle(center, radius2, paint2);
  }

  @override
  bool shouldRepaint(covariant _DotWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
