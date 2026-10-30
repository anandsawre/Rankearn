import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../tests/screens/test_result_screen.dart';

/// 5 Standard Question States matching TCS iON & CBT exam interface in React QuizInterface
enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarked,
}

class QuizScreen extends StatefulWidget {
  final TestModel test;
  final List<QuestionModel> questions;
  final VoidCallback onExit;
  final void Function(int score, double accuracy)? onSubmitted;
  final UserProfile? userProfile;

  const QuizScreen({
    super.key,
    required this.test,
    required this.questions,
    required this.onExit,
    this.onSubmitted,
    this.userProfile,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;
  bool _isHindi = false;
  late int _secondsRemaining;
  Timer? _countdownTimer;
  bool _isPaused = false;
  bool _isSubmitting = false;

  // Active section filter ('All', or subject names like 'Physics', 'Chemistry', etc.)
  String _activeSection = 'All';

  // Track user selections: questionId -> selectedOptionIndex (0-3)
  final Map<String, int> _userAnswers = {};

  // Track question status: questionId -> QuestionStatus
  final Map<String, QuestionStatus> _statusMap = {};

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.test.durationMinutes * 60;

    // Initialize all questions as notVisited except the first one
    for (int i = 0; i < widget.questions.length; i++) {
      final qId = widget.questions[i].id;
      _statusMap[qId] = i == 0
          ? QuestionStatus.notAnswered
          : QuestionStatus.notVisited;
    }

    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _countdownTimer?.cancel();
        _handleTimeUp();
      }
    });
  }

  Future<void> _handleTimeUp() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Time is Up! ⏰',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your exam time has expired. Submitting your test automatically now.',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          AppButton(
            label: 'View Results',
            variant: AppButtonVariant.primary,
            size: AppButtonSize.medium,
            backgroundColor: const Color(0xFF007BFF),
            foregroundColor: Colors.white,
            borderRadius: AppRadii.borderMd,
            customTextStyle: const TextStyle(fontWeight: FontWeight.w700),
            onPressed: () => Navigator.of(dlgCtx).pop(true),
          ),
        ],
      ),
    );

    if (shouldProceed == true && mounted) {
      _submitTest();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int _getStatusCount(QuestionStatus status, [String? section]) {
    final targetSection = section ?? _activeSection;
    if (targetSection == 'All') {
      return _statusMap.values.where((s) => s == status).length;
    }
    return widget.questions.where((q) {
      if ((q.subject ?? 'General') != targetSection) return false;
      return (_statusMap[q.id] ?? QuestionStatus.notVisited) == status;
    }).length;
  }

  List<String> get _sections {
    final set = <String>{'All'};
    for (final q in widget.questions) {
      set.add(q.subject ?? 'General');
    }
    return set.toList();
  }

  void _selectOption(int optionIndex) {
    final currentQ = widget.questions[_currentIndex];
    setState(() {
      _userAnswers[currentQ.id] = optionIndex;
    });
  }

  void _clearResponse() {
    final currentQ = widget.questions[_currentIndex];
    setState(() {
      _userAnswers.remove(currentQ.id);
      _statusMap[currentQ.id] = QuestionStatus.notAnswered;
    });
  }

  void _markForReviewAndNext() {
    final currentQ = widget.questions[_currentIndex];
    final hasAnswer = _userAnswers.containsKey(currentQ.id);

    setState(() {
      _statusMap[currentQ.id] = hasAnswer
          ? QuestionStatus.answeredAndMarked
          : QuestionStatus.markedForReview;
    });

    _moveToNext();
  }

  void _saveAndNext() {
    final currentQ = widget.questions[_currentIndex];
    final hasAnswer = _userAnswers.containsKey(currentQ.id);

    setState(() {
      _statusMap[currentQ.id] = hasAnswer
          ? QuestionStatus.answered
          : QuestionStatus.notAnswered;
    });

    if (_currentIndex < widget.questions.length - 1) {
      _moveToNext();
    } else {
      _showSubmitConfirmation();
    }
  }

  void _moveToNext() {
    if (_activeSection == 'All') {
      if (_currentIndex < widget.questions.length - 1) {
        _goToQuestion(_currentIndex + 1);
      }
    } else {
      // Find next question in the active section
      final nextIdx = widget.questions.indexWhere(
        (q) => (q.subject ?? 'General') == _activeSection,
        _currentIndex + 1,
      );
      if (nextIdx != -1) {
        _goToQuestion(nextIdx);
      } else {
        // End of this section, stay or go to next
        if (_currentIndex < widget.questions.length - 1) {
          _goToQuestion(_currentIndex + 1);
        }
      }
    }
  }

  void _moveToPrevious() {
    if (_activeSection == 'All') {
      if (_currentIndex > 0) {
        _goToQuestion(_currentIndex - 1);
      }
    } else {
      // Find previous question in the active section
      for (int i = _currentIndex - 1; i >= 0; i--) {
        if ((widget.questions[i].subject ?? 'General') == _activeSection) {
          _goToQuestion(i);
          return;
        }
      }
      if (_currentIndex > 0) {
        _goToQuestion(_currentIndex - 1);
      }
    }
  }

  void _goToQuestion(int index, [String? targetSection]) {
    if (index < 0 || index >= widget.questions.length) return;
    setState(() {
      _currentIndex = index;
      final qId = widget.questions[_currentIndex].id;
      if (_statusMap[qId] == QuestionStatus.notVisited) {
        _statusMap[qId] = QuestionStatus.notAnswered;
      }
      if (targetSection != null) {
        _activeSection = targetSection;
      }
    });
  }

  void _handleSectionChange(String section) {
    setState(() => _activeSection = section);
    if (section == 'All') {
      _goToQuestion(0, 'All');
    } else {
      final firstIdx = widget.questions.indexWhere(
        (q) => (q.subject ?? 'General') == section,
      );
      if (firstIdx != -1) {
        _goToQuestion(firstIdx, section);
      }
    }
  }

  void _submitTest() {
    if (!mounted || _isSubmitting) return;
    _isSubmitting = true;
    _countdownTimer?.cancel();

    int correct = 0;
    for (final q in widget.questions) {
      if (_userAnswers[q.id] == q.correctAnswer) {
        correct++;
      }
    }
    final double accuracy = widget.questions.isNotEmpty
        ? (correct / widget.questions.length) * 100
        : 0.0;
    final int timeTaken =
        (widget.test.durationMinutes * 60) - _secondsRemaining;
    final safeTimeTaken = timeTaken > 0 ? timeTaken : 1;

    final result = TestResultModel.fromSubmission(
      test: widget.test,
      questions: widget.questions,
      userAnswers: _userAnswers,
      timeTakenSeconds: safeTimeTaken,
      profile: widget.userProfile,
    );

    // Record attempt if logged in
    if (widget.userProfile != null) {
      ContestsRepository().submitAttempt(
        testId: widget.test.id,
        userId: widget.userProfile!.id,
        answers: _userAnswers,
        startTime: DateTime.now().subtract(Duration(seconds: safeTimeTaken)),
        endTime: DateTime.now(),
        timeTakenSeconds: safeTimeTaken,
        score: result.score,
        accuracy: result.accuracy,
        isTournament: widget.test.isTournament,
      );
    }

    widget.onSubmitted?.call(correct, accuracy);

    // Navigate to TestResultScreen replacing QuizScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (resultCtx) => TestResultScreen(
          result: result,
          userProfile: widget.userProfile,
          userCoins: widget.userProfile?.coins ?? 1250,
          onBackToTests: () {
            if (Navigator.of(resultCtx).canPop()) {
              Navigator.of(resultCtx).pop();
            } else {
              widget.onExit();
            }
          },
          onPracticeAgain: () {
            Navigator.of(resultCtx).pushReplacement(
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  test: widget.test,
                  questions: widget.questions,
                  onExit: widget.onExit,
                  onSubmitted: widget.onSubmitted,
                  userProfile: widget.userProfile,
                ),
              ),
            );
          },
          onMoreTests: () {
            if (Navigator.of(resultCtx).canPop()) {
              Navigator.of(resultCtx).pop();
            } else {
              widget.onExit();
            }
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // Dialog 1: Instructions Modal
  // ==========================================================================
  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isMobile = MediaQuery.of(ctx).size.width < 480;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 440,
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Centered Circular Icon Badge
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF007BFF),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Centered Title
              const Text(
                'Exam Instructions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Centered Subtitle
              const Text(
                'Please read all examination guidelines and scoring rules carefully before proceeding.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              // 4. Scrollable Content Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Table Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Duration',
                              '${widget.test.durationMinutes} Minutes',
                              const Color(0xFF0F172A),
                            ),
                            const Divider(height: 18, color: Color(0xFFE2E8F0)),
                            _buildSummaryRow(
                              'Total Questions',
                              '${widget.questions.length}',
                              const Color(0xFF0F172A),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Marking Scheme Section
                      Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF28A745),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Marking Scheme',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Correct Answer',
                              '+1.0 Mark',
                              const Color(0xFF28A745),
                            ),
                            const Divider(height: 18, color: Color(0xFFE2E8F0)),
                            _buildSummaryRow(
                              'Wrong Answer',
                              '-${widget.test.negativeMarking} Mark',
                              const Color(0xFFDC3545),
                            ),
                            const Divider(height: 18, color: Color(0xFFE2E8F0)),
                            _buildSummaryRow(
                              'Unattempted',
                              '0.0 Mark',
                              const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // General Instructions Section
                      Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007BFF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'General Instructions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...[
                        'The countdown timer at the top right displays remaining test time.',
                        'When the timer reaches zero, the examination ends and submits automatically.',
                        'The Question Palette on the right displays the status of each question.',
                        'You can tap any question number in the palette to navigate directly.',
                        'Review all answered and marked questions before final submission.',
                      ].asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF1F5F9),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.45,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Bottom Action Button (Centralized Full-Width Blue Button)
              AppButton(
                label: 'I Have Read All Instructions',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                fullWidth: true,
                height: 48,
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
                customTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // ==========================================================================
  // Dialog 2: Pause Exam Modal
  // ==========================================================================
  void _showPauseDialog() {
    setState(() => _isPaused = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isMobile = MediaQuery.of(ctx).size.width < 480;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 440),
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.pause_circle_outline_rounded,
                  color: Color(0xFF007BFF),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'EXAM PAUSED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your exam timer is currently paused. Resume when you are ready to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Time Remaining',
                      _formatTimer(_secondsRemaining),
                      const Color(0xFF007BFF),
                    ),
                    const Divider(height: 18, color: Color(0xFFE2E8F0)),
                    _buildSummaryRow(
                      'Total Questions',
                      '${widget.questions.length}',
                      const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'RESUME EXAM',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                fullWidth: true,
                height: 48,
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
                customTextStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() => _isPaused = false);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // ==========================================================================
  // Dialog 3: Submit Confirmation Modal
  // ==========================================================================
  Future<void> _showSubmitConfirmation() async {
    final answered =
        _getStatusCount(QuestionStatus.answered, 'All') +
        _getStatusCount(QuestionStatus.answeredAndMarked, 'All');
    final total = widget.questions.length;
    final notAnswered = _getStatusCount(QuestionStatus.notAnswered, 'All');
    final marked =
        _getStatusCount(QuestionStatus.markedForReview, 'All') +
        _getStatusCount(QuestionStatus.answeredAndMarked, 'All');
    final notVisited = _getStatusCount(QuestionStatus.notVisited, 'All');

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isMobile = MediaQuery.of(ctx).size.width < 480;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 440),
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF007BFF),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Submit Test?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to submit your test?\nYou will not be able to change your answers after submission.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),

                // Summary stats table matching reference screenshot
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Total Questions',
                        '$total',
                        const Color(0xFF0F172A),
                      ),
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSummaryRow(
                        'Answered',
                        '$answered',
                        const Color(0xFF28A745),
                      ),
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSummaryRow(
                        'Not Answered',
                        '$notAnswered',
                        const Color(0xFFDC3545),
                      ),
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSummaryRow(
                        'Marked for Review',
                        '$marked',
                        const Color(0xFF6F42C1),
                      ),
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSummaryRow(
                        'Not Visited',
                        '$notVisited',
                        const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.large,
                        height: 48,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF334155),
                        borderColor: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(14),
                        customTextStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppButton(
                        label: 'Yes, Submit',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.large,
                        height: 48,
                        backgroundColor: const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        customTextStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldSubmit == true && mounted) {
      _submitTest();
    }
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Main Build Method (Responsive Desktop & Mobile Layout)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFDC3545),
              ),
              const SizedBox(height: 12),
              const Text(
                'No Questions Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'We couldn\'t find any questions for this test.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Go Back',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                borderRadius: AppRadii.borderMd,
                onPressed: widget.onExit,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Protect against transient zero / miniature layout frames during devtools toggle or browser resizing
        if (constraints.maxHeight < 200 || constraints.maxWidth < 200) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F2F5),
          );
        }

        final isDesktop = constraints.maxWidth >= 960;

        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF0F2F5),
          endDrawer: isDesktop
              ? null
              : Drawer(
                  width: 300,
                  backgroundColor: const Color(0xFFE1E4E8),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          color: const Color(0xFF2C3E50),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'QUESTION PALETTE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildQuestionPaletteContent(isDrawer: true),
                        ),
                      ],
                    ),
                  ),
                ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Bar (TCS iON Dark Slate style)
                _buildTopBar(isDesktop),

                // 2. Section Tabs Bar
                _buildSectionTabsBar(),

                // 3. Main Exam Viewport (Split 2-Column on Desktop, Full Width on Mobile)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Column: Question Content & Action Buttons
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question Subheader
                            _buildQuestionSubheader(isDesktop),

                            // Scrollable Question & Options
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 880,
                                    ),
                                    child: _buildQuestionAndOptions(),
                                  ),
                                ),
                              ),
                            ),

                            // Bottom Controls Bar
                            _buildBottomControlsBar(),
                          ],
                        ),
                      ),

                      // Right Column: Persistent Palette Sidebar (Desktop)
                      if (isDesktop)
                        Container(
                          width: 300,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE1E4E8),
                            border: Border(
                              left: BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: _buildQuestionPaletteContent(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // Section 1: Top Bar (TCS iON Dark Slate #2C3E50)
  // ==========================================================================
  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 48,
      color: const Color(0xFF2C3E50),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          // Left: "R" Logo & Test Title (immune to overflow via horizontal scroll wrapper)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'R',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.test.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Right: Pause + Timer + Language Switcher + Mobile Palette Trigger
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pause Button
              InkWell(
                onTap: _showPauseDialog,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pause_circle_outline_rounded,
                        color: Color(0xFFFACC15),
                        size: 13,
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 4),
                        const Text(
                          'PAUSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Timer Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF60A5FA),
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatTimer(_secondsRemaining),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Language Toggle (EN / HI)
              Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLangButton(
                      'EN',
                      !_isHindi,
                      () => setState(() => _isHindi = false),
                    ),
                    _buildLangButton(
                      'HI',
                      _isHindi,
                      () => setState(() => _isHindi = true),
                    ),
                  ],
                ),
              ),

              // Mobile Question Palette Trigger Button
              if (!isDesktop) ...[
                const SizedBox(width: 4),
                InkWell(
                  key: const Key('mobile_palette_button'),
                  onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2C3E50) : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Section 2: Section Tabs Bar (#E1E4E8)
  // ==========================================================================
  Widget _buildSectionTabsBar() {
    return Container(
      width: double.infinity,
      height: 44,
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Color(0xFFE1E4E8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _sections.map((sec) {
            final isActive = _activeSection == sec;

            return InkWell(
              onTap: () => _handleSectionChange(sec),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  border: Border(
                    top: BorderSide(
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    right: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1.0,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  sec.toUpperCase(),
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF475569),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================================================
  // Section 3: Question Subheader Bar (#F8F9FA)
  // ==========================================================================
  Widget _buildQuestionSubheader(bool isDesktop) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Q. ${_currentIndex + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Subtitle for test parity
                  Text(
                    'Question ${_currentIndex + 1} of ${widget.questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // +1.0 Mark Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Text(
                      '+1.0',
                      style: TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Negative Mark Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      '-${widget.test.negativeMarking}',
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // View Instructions Link (Icon only on mobile, Icon + Text on desktop)
          Tooltip(
            message: 'View Instructions',
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: _showInstructionsDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 4),
                      const Text(
                        'View Instructions',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Section 4: Question Text & Options Card
  // ==========================================================================
  Widget _buildQuestionAndOptions() {
    final currentQ = widget.questions[_currentIndex];
    final selectedOption = _userAnswers[currentQ.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Text Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQ.getDisplayText(_isHindi),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (currentQ.imageUrl != null &&
                  currentQ.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    currentQ.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Options List
        for (int i = 0; i < currentQ.options.length; i++) ...[
          _buildOptionTile(
            index: i,
            letter: String.fromCharCode(65 + i),
            text: currentQ.options[i].getDisplay(_isHindi),
            isSelected: selectedOption == i,
            onTap: () => _selectOption(i),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildOptionTile({
    required int index,
    required String letter,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF0F172A,
              ).withValues(alpha: isSelected ? 0.05 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Letter Badge
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFF1F5F9),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Option Text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Section 5: Bottom Controls Bar (#F8F9FA)
  // ==========================================================================
  Widget _buildBottomControlsBar() {
    final isLastQuestion = _currentIndex == widget.questions.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final markReviewBtn = _buildSecondaryActionButton(
          label: 'Mark Review',
          onPressed: _markForReviewAndNext,
        );
        final clearBtn = _buildSecondaryActionButton(
          label: 'Clear',
          onPressed: _clearResponse,
        );
        final prevBtn = _buildSecondaryActionButton(
          label: 'Previous',
          onPressed: _currentIndex > 0 ? _moveToPrevious : null,
        );
        final nextOrSubmitBtn = isLastQuestion
            ? AppButton(
                label: 'Submit Test',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                height: 42,
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                borderRadius: AppRadii.borderMd,
                customTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                onPressed: () {
                  final currentQ = widget.questions[_currentIndex];
                  final isAnswered = _userAnswers.containsKey(currentQ.id);
                  setState(() {
                    _statusMap[currentQ.id] = isAnswered
                        ? QuestionStatus.answered
                        : QuestionStatus.notAnswered;
                  });
                  _showSubmitConfirmation();
                },
              )
            : AppButton(
                label: 'Save & Next',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                height: 42,
                backgroundColor: const Color(0xFF28A745),
                foregroundColor: Colors.white,
                borderRadius: AppRadii.borderMd,
                customTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                onPressed: _saveAndNext,
              );

        if (isMobile) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border(
                top: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: markReviewBtn),
                    const SizedBox(width: 8),
                    Expanded(child: clearBtn),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: prevBtn),
                    const SizedBox(width: 8),
                    Expanded(child: nextOrSubmitBtn),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            border: Border(
              top: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Mark Review & Clear Buttons
              Row(
                children: [markReviewBtn, const SizedBox(width: 8), clearBtn],
              ),

              // Right: Previous & Save & Next / Submit Test
              Row(
                children: [prevBtn, const SizedBox(width: 10), nextOrSubmitBtn],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecondaryActionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return AppButton(
      label: label,
      variant: AppButtonVariant.secondary,
      size: AppButtonSize.medium,
      height: 42,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF334155),
      borderColor: const Color(0xFFCBD5E1),
      borderRadius: AppRadii.borderMd,
      customTextStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      onPressed: onPressed,
      disabled: onPressed == null,
    );
  }

  // ==========================================================================
  // Section 6: Question Palette Content (Sidebar & Drawer)
  // ==========================================================================
  Widget _buildQuestionPaletteContent({bool isDrawer = false}) {
    final candidateName = widget.userProfile?.name ?? 'Candidate';
    final candidateId = widget.userProfile?.id != null
        ? 'ID: ${widget.userProfile!.id.length > 8 ? widget.userProfile!.id.substring(0, 8).toUpperCase() : widget.userProfile!.id.toUpperCase()}'
        : 'ID: CANDIDATE';

    return Column(
      children: [
        // 1. Candidate Info Box
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                alignment: Alignment.center,
                child: widget.userProfile?.profilePhotoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          widget.userProfile!.profilePhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      candidateId,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFCBD5E1)),

        // 2. 5-State Status Summary Grid
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatusBadge(
                      const Color(0xFF28A745),
                      '${_getStatusCount(QuestionStatus.answered)}',
                      'Answered',
                      false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusBadge(
                      const Color(0xFFDC3545),
                      '${_getStatusCount(QuestionStatus.notAnswered)}',
                      'Not Answered',
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusBadge(
                      Colors.white,
                      '${_getStatusCount(QuestionStatus.notVisited)}',
                      'Not Visited',
                      false,
                      borderColor: const Color(0xFF94A3B8),
                      textColor: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusBadge(
                      const Color(0xFF6F42C1),
                      '${_getStatusCount(QuestionStatus.markedForReview)}',
                      'Marked Review',
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusBadge(
                  const Color(0xFF6F42C1),
                  '${_getStatusCount(QuestionStatus.answeredAndMarked)}',
                  'Ans & Marked Review',
                  true,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFCBD5E1)),

        // 3. Question Numbers Grid
        Expanded(
          child: Container(
            color: const Color(0xFFE1E4E8),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHOOSE A QUESTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final List<({int originalIndex, QuestionModel question})>
                        filteredQuestions = [];
                    for (int i = 0; i < widget.questions.length; i++) {
                      final q = widget.questions[i];
                      if (_activeSection == 'All' ||
                          (q.subject ?? 'General') == _activeSection) {
                        filteredQuestions.add((originalIndex: i, question: q));
                      }
                    }

                    return Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: filteredQuestions.length,
                        itemBuilder: (context, gridIndex) {
                          final item = filteredQuestions[gridIndex];
                          final index = item.originalIndex;
                          final q = item.question;

                          final status =
                              _statusMap[q.id] ?? QuestionStatus.notVisited;
                          final isCurrent = index == _currentIndex;

                          return _buildPaletteQuestionBox(
                            questionIndex: index,
                            status: status,
                            isCurrent: isCurrent,
                            onTap: () {
                              _goToQuestion(index);
                              if (isDrawer) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // 4. Sticky Bottom Submit Test Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            border: Border(
              top: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
            ),
          ),
          child: AppButton(
            label: 'SUBMIT TEST',
            variant: AppButtonVariant.primary,
            size: AppButtonSize.medium,
            height: 42,
            fullWidth: true,
            backgroundColor: const Color(0xFF007BFF),
            foregroundColor: Colors.white,
            borderRadius: AppRadii.borderMd,
            customTextStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
            onPressed: _showSubmitConfirmation,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
    Color boxColor,
    String count,
    String label,
    bool isCircleWithDot, {
    Color? borderColor,
    Color textColor = Colors.white,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: boxColor,
                shape: isCircleWithDot ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircleWithDot ? null : BorderRadius.circular(4),
                border: Border.all(color: borderColor ?? boxColor, width: 1.0),
              ),
              alignment: Alignment.center,
              child: Text(
                count,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (isCircleWithDot)
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF28A745),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaletteQuestionBox({
    required int questionIndex,
    required QuestionStatus status,
    required bool isCurrent,
    required VoidCallback onTap,
  }) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFF94A3B8);
    Color textColor = const Color(0xFF334155);
    bool isCircle = false;
    bool hasGreenDot = false;

    switch (status) {
      case QuestionStatus.answered:
        bgColor = const Color(0xFF28A745);
        borderColor = const Color(0xFF28A745);
        textColor = Colors.white;
        break;
      case QuestionStatus.notAnswered:
        bgColor = const Color(0xFFDC3545);
        borderColor = const Color(0xFFDC3545);
        textColor = Colors.white;
        break;
      case QuestionStatus.markedForReview:
        bgColor = const Color(0xFF6F42C1);
        borderColor = const Color(0xFF6F42C1);
        textColor = Colors.white;
        break;
      case QuestionStatus.answeredAndMarked:
        bgColor = const Color(0xFF6F42C1);
        borderColor = const Color(0xFF6F42C1);
        textColor = Colors.white;
        isCircle = true;
        hasGreenDot = true;
        break;
      case QuestionStatus.notVisited:
        bgColor = Colors.white;
        borderColor = const Color(0xFF94A3B8);
        textColor = const Color(0xFF334155);
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isCircle ? 20 : 6),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.circular(6),
              border: Border.all(
                color: isCurrent ? const Color(0xFF2563EB) : borderColor,
                width: isCurrent ? 2.5 : 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${questionIndex + 1}',
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasGreenDot)
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF28A745),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
