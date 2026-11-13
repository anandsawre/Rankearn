import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// Interactive, Textured Purple Gradient Live Poll Card for Candidates
class LivePollCard extends StatefulWidget {
  final UserProfile profile;

  const LivePollCard({
    super.key,
    required this.profile,
  });

  @override
  State<LivePollCard> createState() => _LivePollCardState();
}

class _LivePollCardState extends State<LivePollCard> {
  PollModel? _activePoll;
  int? _votedOption;
  bool _isVoting = false;
  int _remainingSeconds = 0;

  StreamSubscription<PollModel?>? _pollSub;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
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
    final leader = poll.leadingOption;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: AppRadii.pollCanvas,
        gradient: AppColors.pollCanvasGradient,
        boxShadow: AppShadows.pollCanvas,
        border: Border.all(
          color: Colors.white.withAlpha(35),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Wave Texture Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _PurpleWavePainter(),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row: LIVE Badge + Timer Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LIVE POLL Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isTimeUp ? Colors.white.withAlpha(25) : AppColors.error,
                        borderRadius: AppRadii.borderPill,
                        boxShadow: isTimeUp
                            ? null
                            : [
                                BoxShadow(
                                  color: AppColors.error.withAlpha(120),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: isTimeUp ? Colors.white.withAlpha(180) : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isTimeUp ? 'POLL ENDED' : 'LIVE POLL',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Countdown Timer Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: AppRadii.borderPill,
                        border: Border.all(color: Colors.white.withAlpha(45)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            _formatTimer(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Question Text (Crisp White Bold Typography)
                Text(
                  poll.question,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 16),

                // Options List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: poll.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = poll.options[index];
                    final pct = poll.getPercentage(opt).round();
                    final isUserVote = _votedOption == index;
                    final isLeading = totalVotes > 0 && opt == leader;

                    if (hasVoted) {
                      // VOTED STATE: Glassmorphic progress bar with percentage and badges
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isLeading
                              ? AppColors.pollLeadingGreen
                              : (isUserVote ? Colors.white.withAlpha(35) : Colors.white.withAlpha(20)),
                          borderRadius: AppRadii.pollOption,
                          border: Border.all(
                            color: isLeading
                                ? AppColors.pollLeadingGreenBorder
                                : (isUserVote ? Colors.white : Colors.white.withAlpha(35)),
                            width: (isLeading || isUserVote) ? 1.5 : 1.0,
                          ),
                          boxShadow: isLeading
                              ? [
                                  BoxShadow(
                                    color: AppColors.pollLeadingGreen.withAlpha(100),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Progress bar indicator for non-leading options
                            if (!isLeading && pct > 0)
                              FractionallySizedBox(
                                widthFactor: (pct / 100.0).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(25),
                                  ),
                                ),
                              ),

                            // Content Row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  // Letter Badge
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: isLeading ? Colors.white.withAlpha(70) : Colors.white.withAlpha(35),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      opt.label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
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
                                        fontWeight: (isLeading || isUserVote) ? FontWeight.w800 : FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Your Vote Badge
                                  if (isUserVote) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: AppRadii.borderPill,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_rounded,
                                            size: 13,
                                            color: isLeading ? AppColors.pollLeadingGreen : AppColors.brandPurple,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Your Vote',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: isLeading ? AppColors.pollLeadingGreen : AppColors.brandPurple,
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
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // NOT VOTED STATE: Glassmorphic interactive vote buttons
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (_isVoting || isTimeUp) ? null : () => _castVote(index),
                        borderRadius: AppRadii.pollOption,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(22),
                            borderRadius: AppRadii.pollOption,
                            border: Border.all(
                              color: Colors.white.withAlpha(35),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Letter Badge
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(35),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withAlpha(50)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  opt.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
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
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Interactive arrow icon
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: Colors.white.withAlpha(160),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Footer Row: Total votes count + Live indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_alt_rounded, size: 14, color: Colors.white.withAlpha(200)),
                        const SizedBox(width: 6),
                        Text(
                          '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'} recorded',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(210),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      hasVoted ? '✓ Vote submitted' : 'Tap any option to vote',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: hasVoted ? AppColors.pollLeadingGreen : Colors.white.withAlpha(220),
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

/// Custom painter for the cosmic purple gradient wave texture background
class _PurpleWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.pollCanvasWave1.withAlpha(35)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.55,
      size.width * 0.65,
      size.height * 0.85,
    );
    path1.quadraticBezierTo(
      size.width * 0.85,
      size.height * 1.0,
      size.width,
      size.height * 0.75,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = AppColors.pollCanvasWave2.withAlpha(25)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.95,
      size.width,
      size.height * 0.65,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
