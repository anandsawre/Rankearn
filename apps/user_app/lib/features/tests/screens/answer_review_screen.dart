import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';

/// Comprehensive, production-grade Answer Review Screen
/// Supports desktop & mobile layouts, jumping to any question,
/// English/Hindi toggling, semantic option statuses, and detailed explanations.
class AnswerReviewScreen extends StatefulWidget {
  final TestResultModel result;
  final int initialQuestionIndex;

  const AnswerReviewScreen({
    super.key,
    required this.result,
    this.initialQuestionIndex = 0,
  });

  @override
  State<AnswerReviewScreen> createState() => _AnswerReviewScreenState();
}

class _AnswerReviewScreenState extends State<AnswerReviewScreen> {
  late int _currentIndex;
  bool _isHindi = false;
  String _activeFilter = 'all'; // 'all', 'correct', 'incorrect', 'unattempted'
  final ScrollController _jumperScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialQuestionIndex.clamp(
      0,
      widget.result.questionItems.length - 1,
    );
  }

  @override
  void dispose() {
    _jumperScrollController.dispose();
    super.dispose();
  }

  List<QuestionAnalysisItem> get _filteredQuestions {
    return widget.result.questionItems.where((q) {
      if (_activeFilter == 'correct') return q.isCorrect;
      if (_activeFilter == 'incorrect' || _activeFilter == 'negative') {
        return q.isIncorrect;
      }
      if (_activeFilter == 'unattempted') return !q.isAttempted;
      return true;
    }).toList();
  }

  void _goToQuestion(int index) {
    if (index >= 0 && index < widget.result.questionItems.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;
    final currentItem = widget.result.questionItems.isNotEmpty
        ? widget.result.questionItems[_currentIndex]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF10194F)),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Result',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Answer Review',
              style: TextStyle(
                color: Color(0xFF10194F),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${widget.result.testTitle} • ${widget.result.testSubtitle}',
              style: const TextStyle(
                color: Color(0xFF586B9B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher (EN / HI)
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F8FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2ECFA)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() => _isHindi = false),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: !_isHindi
                            ? const Color(0xFF00B96B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'EN',
                        style: TextStyle(
                          color: !_isHindi
                              ? Colors.white
                              : const Color(0xFF586B9B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _isHindi = true),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isHindi
                            ? const Color(0xFF00B96B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'HI',
                        style: TextStyle(
                          color: _isHindi
                              ? Colors.white
                              : const Color(0xFF586B9B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2ECFA), height: 1.0),
        ),
      ),
      body: currentItem == null
          ? const Center(child: Text('No questions available to review.'))
          : SafeArea(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Column: Persistent Question Palette Sidebar (Desktop)
                        Container(
                          width: 320,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: _buildDesktopReviewPalette(),
                        ),

                        // Right Column: Scrollable Question Review & Bottom Controls
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 24,
                                  ),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 880,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildQuestionCard(currentItem),
                                          const SizedBox(height: 16),
                                          _buildOptionsList(currentItem),
                                          const SizedBox(height: 16),
                                          _buildExplanationCard(currentItem),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _buildBottomNavigationControls(),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile: Horizontal Question Number Strip / Jumper
                        _buildQuestionJumperBar(),

                        // Main Question & Options Body
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildQuestionCard(currentItem),
                                const SizedBox(height: 16),
                                _buildOptionsList(currentItem),
                                const SizedBox(height: 16),
                                _buildExplanationCard(currentItem),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Navigation Controls
                        _buildBottomNavigationControls(),
                      ],
                    ),
            ),
    );
  }

  // ==========================================================================
  // Desktop Question Palette Sidebar
  // ==========================================================================
  Widget _buildDesktopReviewPalette() {
    return Column(
      children: [
        // 1. Performance Summary Header
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'SUMMARY',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      'Score: ${widget.result.score % 1 == 0 ? widget.result.score.toInt() : widget.result.score.toStringAsFixed(1)}/${widget.result.maxScore.toInt()}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Badges Grid (Clickable)
              Row(
                children: [
                  Expanded(
                    child: _buildPaletteFilterBadge(
                      'all',
                      const Color(0xFF2563EB),
                      '${widget.result.questionItems.length}',
                      'All',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaletteFilterBadge(
                      'correct',
                      const Color(0xFF16A34A),
                      '${widget.result.correctCount}',
                      'Correct',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaletteFilterBadge(
                      'incorrect',
                      const Color(0xFFDC2626),
                      '${widget.result.incorrectCount}',
                      'Incorrect',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaletteFilterBadge(
                      'unattempted',
                      const Color(0xFF64748B),
                      '${widget.result.unattemptedCount}',
                      'Unattempted',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaletteFilterBadge(
                      'negative',
                      const Color(0xFFEA580C),
                      widget.result.formattedNegativeMarks,
                      'Negative',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaletteFilterBadge(
                      'final_score',
                      const Color(0xFF7C3AED),
                      widget.result.formattedFinalScore,
                      'Final Score',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFCBD5E1)),

        // 2. Question Numbers Grid
        Expanded(
          child: Container(
            color: const Color(0xFFE1E4E8),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    if (_activeFilter != 'all')
                      InkWell(
                        onTap: () => setState(() => _activeFilter = 'all'),
                        child: const Text(
                          'Show All',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final item = _filteredQuestions[index];
                      final isSelected =
                          item.questionNumber - 1 == _currentIndex;

                      Color bg;
                      Color text;
                      Color borderColor;

                      if (!item.isAttempted) {
                        bg = Colors.white;
                        text = const Color(0xFF475569);
                        borderColor = const Color(0xFF94A3B8);
                      } else if (item.isCorrect) {
                        bg = const Color(0xFF28A745);
                        text = Colors.white;
                        borderColor = const Color(0xFF28A745);
                      } else {
                        bg = const Color(0xFFDC3545);
                        text = Colors.white;
                        borderColor = const Color(0xFFDC3545);
                      }

                      return InkWell(
                        onTap: () => _goToQuestion(item.questionNumber - 1),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : borderColor,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${item.questionNumber}',
                            style: TextStyle(
                              color: text,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Bottom Sticky Action Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            border: Border(
              top: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
            ),
          ),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10194F),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'BACK TO RESULT',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaletteFilterBadge(
    String filterKey,
    Color color,
    String count,
    String label,
  ) {
    final isSelected = _activeFilter == filterKey;

    return InkWell(
      onTap: () => setState(() => _activeFilter = filterKey),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : const Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionJumperBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip(
                  'all',
                  'All (${widget.result.questionItems.length})',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'correct',
                  'Correct (${widget.result.correctCount})',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'incorrect',
                  'Incorrect (${widget.result.incorrectCount})',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'unattempted',
                  'Unattempted (${widget.result.unattemptedCount})',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'negative',
                  'Negative (${widget.result.formattedNegativeMarks})',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'final_score',
                  'Score (${widget.result.formattedFinalScore}/${widget.result.maxScore.toInt()})',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Number Buttons
          SizedBox(
            height: 38,
            child: ListView.separated(
              controller: _jumperScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredQuestions.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final item = _filteredQuestions[index];
                final isSelected = item.questionNumber - 1 == _currentIndex;

                Color bg;
                Color text;
                Color border = isSelected
                    ? const Color(0xFF10194F)
                    : Colors.transparent;

                if (!item.isAttempted) {
                  bg = const Color(0xFFEDF3FB);
                  text = const Color(0xFF586B9B);
                } else if (item.isCorrect) {
                  bg = const Color(0xFFD6F5E8);
                  text = const Color(0xFF008C52);
                } else {
                  bg = const Color(0xFFFEDCDF);
                  text = const Color(0xFFE5252A);
                }

                return InkWell(
                  onTap: () => _goToQuestion(item.questionNumber - 1),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: border,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.questionNumber}',
                      style: TextStyle(
                        color: text,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
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

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeFilter == key;

    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B96B) : const Color(0xFFF2F8FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF586B9B),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionAnalysisItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECFA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question number, Subject pill, Status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10194F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Q${item.questionNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.question.subject != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.question.subject!,
                        style: const TextStyle(
                          color: Color(0xFF2587F8),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              _buildQuestionStatusPill(item),
            ],
          ),
          const SizedBox(height: 16),

          // Question Text
          Text(
            item.question.getDisplayText(_isHindi),
            style: const TextStyle(
              color: Color(0xFF10194F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStatusPill(QuestionAnalysisItem item) {
    if (!item.isAttempted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: const Text(
          '– Not Attempted',
          style: TextStyle(
            color: Color(0xFF475569),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    } else if (item.isCorrect) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8FAF2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00B96B)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF00B96B),
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              'Correct (+1.0)',
              style: TextStyle(
                color: Color(0xFF008C52),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEECEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF52245)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.cancel_rounded, color: Color(0xFFF52245), size: 14),
            SizedBox(width: 4),
            Text(
              'Incorrect (-0.33)',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildOptionsList(QuestionAnalysisItem item) {
    const letters = ['A', 'B', 'C', 'D'];

    return Column(
      children: List.generate(item.question.options.length, (optIndex) {
        final opt = item.question.options[optIndex];
        final isCorrectOpt = optIndex == item.correctOptionIndex;
        final isUserSelected = optIndex == item.selectedOptionIndex;

        Color borderColor = const Color(0xFFE2ECFA);
        Color bgColor = Colors.white;
        Widget? trailingBadge;

        if (isCorrectOpt) {
          borderColor = const Color(0xFF00B96B);
          bgColor = const Color(0xFFE8FAF2);
          trailingBadge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00B96B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, color: Colors.white, size: 12),
                SizedBox(width: 3),
                Text(
                  'Correct Answer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        } else if (isUserSelected && !isCorrectOpt) {
          borderColor = const Color(0xFFF52245);
          bgColor = const Color(0xFFFEECEE);
          trailingBadge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF52245),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close_rounded, color: Colors.white, size: 12),
                SizedBox(width: 3),
                Text(
                  'Your Answer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCorrectOpt
                      ? const Color(0xFF00B96B)
                      : (isUserSelected
                            ? const Color(0xFFF52245)
                            : const Color(0xFFF2F8FF)),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  letters[optIndex],
                  style: TextStyle(
                    color: (isCorrectOpt || isUserSelected)
                        ? Colors.white
                        : const Color(0xFF586B9B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opt.getDisplay(_isHindi),
                  style: TextStyle(
                    color: const Color(0xFF10194F),
                    fontSize: 14,
                    fontWeight: isCorrectOpt || isUserSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
              ?trailingBadge,
            ],
          ),
        );
      }),
    );
  }

  Widget _buildExplanationCard(QuestionAnalysisItem item) {
    final explanation =
        item.question.getDisplayExplanation(_isHindi) ??
        'The correct answer is Option ${_getOptionLetter(item.correctOptionIndex)}. Please review fundamental concepts of ${item.question.subject ?? 'this topic'}.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_rounded, color: Color(0xFF2587F8), size: 20),
              SizedBox(width: 8),
              Text(
                'Explanation',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationControls() {
    final canGoPrev = _currentIndex > 0;
    final canGoNext = _currentIndex < widget.result.questionItems.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2ECFA))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: canGoPrev
                ? () => _goToQuestion(_currentIndex - 1)
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10194F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.chevron_left_rounded, size: 20),
                Text('Previous'),
              ],
            ),
          ),
          Text(
            '${_currentIndex + 1} of ${widget.result.questionItems.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF586B9B),
              fontSize: 13,
            ),
          ),
          ElevatedButton(
            onPressed: canGoNext
                ? () => _goToQuestion(_currentIndex + 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B96B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Text('Next'),
                Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getOptionLetter(int index) {
    const letters = ['A', 'B', 'C', 'D'];
    return (index >= 0 && index < letters.length) ? letters[index] : 'A';
  }
}
