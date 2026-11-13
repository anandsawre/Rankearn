import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_layer/data_layer.dart';

/// Professional, Atmospheric Textured Purple Gradient Live Poll Card
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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C0B57), // Deep atmospheric royal purple
            Color(0xFF1D063A), // Dark cosmic violet
            Color(0xFF130327), // Rich velvet background
          ],
        ),
        border: Border.all(
          color: const Color(0x33A78BFA), // Subtle glowing violet border
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D063A).withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ambient Organic Wave Texture
          Positioned.fill(
            child: CustomPaint(
              painter: _SubtleAmbientWavePainter(),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header: Status Pill & Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LIVE Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isTimeUp ? const Color(0x22FFFFFF) : const Color(0x33EF4444),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isTimeUp ? const Color(0x33FFFFFF) : const Color(0x66EF4444),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isTimeUp ? const Color(0x88FFFFFF) : const Color(0xFFEF4444),
                              boxShadow: isTimeUp
                                  ? null
                                  : [
                                      const BoxShadow(
                                        color: Color(0xFFEF4444),
                                        blurRadius: 6,
                                      ),
                                    ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isTimeUp ? 'POLL CLOSED' : 'LIVE POLL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isTimeUp ? Colors.white70 : const Color(0xFFFCA5A5),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timer Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x2AFFFFFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFC4B5FD)),
                          const SizedBox(width: 5),
                          Text(
                            _formatTimer(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Question Text
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

                // 3. Options List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: poll.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = poll.options[index];
                    final pct = poll.getPercentage(opt).round();
                    final isUserVote = _votedOption == index;

                    if (hasVoted) {
                      // VOTED STATE: Modern Progress Bar with Elegant Translucent Fill
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0x12FFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUserVote
                                ? const Color(0xFF10B981)
                                : const Color(0x1FFFFFFF),
                            width: isUserVote ? 1.5 : 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Sleek Animated Progress Bar Fill
                            if (pct > 0)
                              FractionallySizedBox(
                                widthFactor: (pct / 100.0).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isUserVote
                                          ? [
                                              const Color(0x3310B981),
                                              const Color(0x5510B981),
                                            ]
                                          : [
                                              const Color(0x18FFFFFF),
                                              const Color(0x28FFFFFF),
                                            ],
                                    ),
                                    border: isUserVote
                                        ? const Border(
                                            right: BorderSide(
                                              color: Color(0xFF10B981),
                                              width: 2.0,
                                            ),
                                          )
                                        : null,
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
                                      color: isUserVote
                                          ? const Color(0xFF10B981)
                                          : const Color(0x26FFFFFF),
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

                                  // Option Text
                                  Expanded(
                                    child: Text(
                                      opt.text,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: isUserVote ? FontWeight.w700 : FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Your Vote Pill
                                  if (isUserVote) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0x2610B981),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0x6610B981)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_rounded,
                                            size: 12,
                                            color: Color(0xFF34D399),
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Your Vote',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF34D399),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],

                                  // Percentage
                                  Text(
                                    '$pct%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isUserVote ? const Color(0xFF34D399) : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // NOT VOTED STATE: Clean, Interactive Glass Cards
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (_isVoting || isTimeUp) ? null : () => _castVote(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0x12FFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x1FFFFFFF),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Letter Badge
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0x26FFFFFF),
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

                              // Option text
                              Expanded(
                                child: Text(
                                  opt.text,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Interactive arrow icon
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: Color(0x66FFFFFF),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 4. Subtle Divider & Footer
                Container(
                  height: 1,
                  color: const Color(0x14FFFFFF),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.how_to_vote_outlined,
                          size: 15,
                          color: Color(0xFFA78BFA),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'} recorded',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC4B5FD),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      hasVoted ? '✓ Vote submitted' : 'Tap any option to vote',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: hasVoted ? const Color(0xFF34D399) : const Color(0xFFA78BFA),
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

/// Subtle atmospheric waves with soft, organic curves
class _SubtleAmbientWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft Violet Ambient Glow at Top Right
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C3AED).withAlpha(50),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.9, size.height * 0.1),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), size.width * 0.5, glowPaint);

    // 2. Wave 1
    final wave1 = Paint()
      ..color = const Color(0xFF8B5CF6).withAlpha(16)
      ..style = PaintingStyle.fill;

    final p1 = Path();
    p1.moveTo(0, size.height * 0.65);
    p1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.45,
      size.width * 0.65,
      size.height * 0.75,
    );
    p1.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.9,
      size.width,
      size.height * 0.7,
    );
    p1.lineTo(size.width, size.height);
    p1.lineTo(0, size.height);
    p1.close();
    canvas.drawPath(p1, wave1);

    // 3. Wave 2
    final wave2 = Paint()
      ..color = const Color(0xFF6D28D9).withAlpha(14)
      ..style = PaintingStyle.fill;

    final p2 = Path();
    p2.moveTo(0, size.height * 0.82);
    p2.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.95,
      size.width,
      size.height * 0.78,
    );
    p2.lineTo(size.width, size.height);
    p2.lineTo(0, size.height);
    p2.close();
    canvas.drawPath(p2, wave2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
