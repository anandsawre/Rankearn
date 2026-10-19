import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

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

  const QuizScreen({
    super.key,
    required this.test,
    required this.questions,
    required this.onExit,
    this.onSubmitted,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _isHindi = false;
  late int _secondsRemaining;
  Timer? _countdownTimer;

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
      _statusMap[qId] = i == 0 ? QuestionStatus.notAnswered : QuestionStatus.notVisited;
    }

    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _countdownTimer?.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time is Up! ⏰'),
        content: const Text('Your exam time has expired. Submitting your test automatically now.'),
        actions: [
          AppButton(
            label: 'View Results',
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
          ),
        ],
      ),
    );
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

  int _getStatusCount(QuestionStatus status) {
    return _statusMap.values.where((s) => s == status).length;
  }

  void _selectOption(int optionIndex) {
    final currentQ = widget.questions[_currentIndex];
    setState(() {
      _userAnswers[currentQ.id] = optionIndex;
      if (_statusMap[currentQ.id] == QuestionStatus.markedForReview) {
        _statusMap[currentQ.id] = QuestionStatus.answeredAndMarked;
      } else {
        _statusMap[currentQ.id] = QuestionStatus.answered;
      }
    });
  }

  void _clearResponse() {
    final currentQ = widget.questions[_currentIndex];
    setState(() {
      _userAnswers.remove(currentQ.id);
      _statusMap[currentQ.id] = QuestionStatus.notAnswered;
    });
  }

  void _toggleMarkForReview() {
    final currentQ = widget.questions[_currentIndex];
    final hasAnswer = _userAnswers.containsKey(currentQ.id);

    setState(() {
      if (hasAnswer) {
        if (_statusMap[currentQ.id] == QuestionStatus.answeredAndMarked) {
          _statusMap[currentQ.id] = QuestionStatus.answered;
        } else {
          _statusMap[currentQ.id] = QuestionStatus.answeredAndMarked;
        }
      } else {
        if (_statusMap[currentQ.id] == QuestionStatus.markedForReview) {
          _statusMap[currentQ.id] = QuestionStatus.notAnswered;
        } else {
          _statusMap[currentQ.id] = QuestionStatus.markedForReview;
        }
      }
    });
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= widget.questions.length) return;
    setState(() {
      _currentIndex = index;
      final qId = widget.questions[_currentIndex].id;
      if (_statusMap[qId] == QuestionStatus.notVisited) {
        _statusMap[qId] = QuestionStatus.notAnswered;
      }
    });
  }

  void _saveAndNext() {
    if (_currentIndex < widget.questions.length - 1) {
      _goToQuestion(_currentIndex + 1);
    } else {
      _showSubmitConfirmation();
    }
  }

  void _showSubmitConfirmation() {
    final answered = _userAnswers.length;
    final total = widget.questions.length;
    final unanswered = total - answered;
    final marked = _statusMap.values.where((s) => s == QuestionStatus.markedForReview || s == QuestionStatus.answeredAndMarked).length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
        title: Row(
          children: [
            const Icon(Icons.assignment_turned_in, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            const Text('Submit Examination?', style: AppTypography.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to finalize and submit your test?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Total Questions', '$total', AppColors.textPrimary),
                  const Divider(height: 12),
                  _buildSummaryRow('Answered', '$answered', AppColors.brandPrimary),
                  const Divider(height: 12),
                  _buildSummaryRow('Unanswered', '$unanswered', AppColors.errorRose),
                  const Divider(height: 12),
                  _buildSummaryRow('Marked for Review', '$marked', Colors.purple),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Review Answers',
            variant: AppButtonVariant.outlined,
            size: AppButtonSize.small,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          AppButton(
            label: 'Submit Now',
            size: AppButtonSize.small,
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitTest();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  void _submitTest() {
    _countdownTimer?.cancel();
    int correct = 0;
    for (final q in widget.questions) {
      if (_userAnswers[q.id] == q.correctAnswer) {
        correct++;
      }
    }
    final double accuracy = widget.questions.isNotEmpty ? (correct / widget.questions.length) * 100 : 0.0;
    widget.onSubmitted?.call(correct, accuracy);
    widget.onExit();
  }

  void _openPaletteDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => _buildPaletteContent(scrollController),
      ),
    );
  }

  Widget _buildPaletteContent(ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Question Palette', style: AppTypography.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Palette Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendChip(AppColors.brandPrimary, 'Answered (${_getStatusCount(QuestionStatus.answered)})'),
              _buildLegendChip(AppColors.errorRose, 'Not Answered (${_getStatusCount(QuestionStatus.notAnswered)})'),
              _buildLegendChip(Colors.purple, 'Review (${_getStatusCount(QuestionStatus.markedForReview)})'),
              _buildLegendChip(AppColors.border, 'Not Visited (${_getStatusCount(QuestionStatus.notVisited)})', textColor: AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 20),

          // Grid of Questions
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final q = widget.questions[index];
                final status = _statusMap[q.id] ?? QuestionStatus.notVisited;
                final isCurrent = index == _currentIndex;

                Color bg = Colors.grey.shade200;
                Color textCol = Colors.black87;

                switch (status) {
                  case QuestionStatus.answered:
                    bg = AppColors.brandPrimary;
                    textCol = Colors.white;
                    break;
                  case QuestionStatus.notAnswered:
                    bg = AppColors.errorRose;
                    textCol = Colors.white;
                    break;
                  case QuestionStatus.markedForReview:
                  case QuestionStatus.answeredAndMarked:
                    bg = Colors.purple;
                    textCol = Colors.white;
                    break;
                  case QuestionStatus.notVisited:
                    bg = Colors.grey.shade200;
                    textCol = Colors.black54;
                    break;
                }

                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _goToQuestion(index);
                  },
                  borderRadius: AppRadii.borderMd,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: AppRadii.borderMd,
                      border: isCurrent ? Border.all(color: Colors.amber, width: 3) : null,
                      boxShadow: isCurrent ? AppShadows.emeraldGlow : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendChip(Color color, String text, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.borderPill,
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No questions available in this test.'),
              const SizedBox(height: 16),
              AppButton(label: 'Go Back', onPressed: widget.onExit),
            ],
          ),
        ),
      );
    }

    final currentQ = widget.questions[_currentIndex];
    final selectedOption = _userAnswers[currentQ.id];
    final isMarked = _statusMap[currentQ.id] == QuestionStatus.markedForReview ||
        _statusMap[currentQ.id] == QuestionStatus.answeredAndMarked;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brandPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _showSubmitConfirmation,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.test.title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.coinGold, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(_secondsRemaining),
                  style: const TextStyle(color: AppColors.coinGold, fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher (EN / HI)
          InkWell(
            onTap: () => setState(() => _isHindi = !_isHindi),
            borderRadius: AppRadii.borderPill,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: AppRadii.borderPill,
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _isHindi ? 'हिन्दी' : 'English',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Palette Button
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            tooltip: 'Question Palette',
            onPressed: _openPaletteDrawer,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Question Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.questions.length,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
              minHeight: 4,
            ),

            // Question & Options Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Header Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.questions.length}',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.brandPrimaryDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadii.borderPill,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '+1.0 / -${widget.test.negativeMarking} Marks',
                            style: AppTypography.microTag,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Question Text Box
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        currentQ.getDisplayText(_isHindi),
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options List
                    const Text('Select an Option:', style: AppTypography.titleSmall),
                    const SizedBox(height: 10),

                    for (int i = 0; i < currentQ.options.length; i++)
                      _buildOptionTile(
                        optionIndex: i,
                        optionLetter: String.fromCharCode(65 + i),
                        text: currentQ.options[i].getDisplay(_isHindi),
                        isSelected: selectedOption == i,
                        onTap: () => _selectOption(i),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation & Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  // Mark for Review Button
                  IconButton(
                    icon: Icon(
                      isMarked ? Icons.flag : Icons.outlined_flag,
                      color: isMarked ? Colors.purple : AppColors.textMuted,
                    ),
                    tooltip: 'Mark for Review',
                    onPressed: _toggleMarkForReview,
                  ),

                  // Clear Response
                  if (selectedOption != null)
                    TextButton(
                      onPressed: _clearResponse,
                      child: const Text('Clear', style: TextStyle(color: AppColors.errorRose, fontSize: 13)),
                    ),

                  const Spacer(),

                  // Previous Button
                  if (_currentIndex > 0) ...[
                    AppButton(
                      label: 'Previous',
                      variant: AppButtonVariant.outlined,
                      size: AppButtonSize.small,
                      onPressed: () => _goToQuestion(_currentIndex - 1),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Save & Next Button
                  AppButton(
                    label: _currentIndex == widget.questions.length - 1 ? 'Finish Test' : 'Save & Next →',
                    size: AppButtonSize.small,
                    onPressed: _saveAndNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required int optionIndex,
    required String optionLetter,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderMd,
        child: AnimatedContainer(
          duration: AppMotion.shortDuration,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandPrimaryLight : Colors.white,
            borderRadius: AppRadii.borderMd,
            border: Border.all(
              color: isSelected ? AppColors.brandPrimary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? AppShadows.emeraldGlow : null,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandPrimary : Colors.grey.shade100,
                  borderRadius: AppRadii.borderPill,
                  border: Border.all(
                    color: isSelected ? AppColors.brandPrimary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? AppColors.brandPrimaryDark : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
