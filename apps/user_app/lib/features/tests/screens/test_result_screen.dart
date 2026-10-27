import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../widgets/test_result_widgets.dart';
import 'answer_review_screen.dart';

/// Test Result Screen - Responsive Desktop & Mobile UI
/// Direct pixel-faithful match with both Desktop and Mobile reference images.
/// Features full-width responsive desktop layout (1366px, 1440px, 1920px+),
/// single-column mobile layout, celebration hero with 3D mascot & confetti,
/// 4 summary metrics, 5 answer stats, 4 interactive analysis tabs,
/// 10-column question grid with status filters, subject performance table,
/// intelligent performance insights, and complete working action flows.
class TestResultScreen extends StatefulWidget {
  final TestResultModel result;
  final UserProfile? userProfile;
  final int userCoins;
  final VoidCallback? onBackToTests;
  final VoidCallback? onPracticeAgain;
  final VoidCallback? onMoreTests;
  final ValueChanged<UserNavTab>? onNavTabSelected;

  const TestResultScreen({
    super.key,
    required this.result,
    this.userProfile,
    this.userCoins = 1250,
    this.onBackToTests,
    this.onPracticeAgain,
    this.onMoreTests,
    this.onNavTabSelected,
  });

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  ResultAnalysisTab _activeTab = ResultAnalysisTab.questions;

  void _openAnswerReview([int questionIndex = 0]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnswerReviewScreen(
          result: widget.result,
          initialQuestionIndex: questionIndex,
        ),
      ),
    );
  }

  void _handleBack() {
    if (widget.onBackToTests != null) {
      widget.onBackToTests!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 1000;
        final isTablet = screenWidth >= 650 && screenWidth < 1000;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F8FF),
          appBar: TestResultHeader(
            coins: widget.userCoins,
            studentName: widget.userProfile?.name ?? widget.result.studentName,
            studentPhotoUrl:
                widget.userProfile?.profilePhotoUrl ??
                widget.result.studentPhotoUrl,
            unreadNotifications: 3,
            onBack: _handleBack,
            onNavTabSelected: widget.onNavTabSelected,
            onAddCoins: () => widget.onNavTabSelected?.call(UserNavTab.wallet),
            onProfileTap: () =>
                widget.onNavTabSelected?.call(UserNavTab.profile),
          ),
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 28.0 : (isTablet ? 20.0 : 16.0),
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Desktop "Back to Tests" breadcrumb button
                    if (isDesktop) ...[
                      _buildDesktopBackBreadcrumb(),
                      const SizedBox(height: 12),
                    ],

                    // 1. Result Hero Banner
                    ResultHeroBanner(
                      result: widget.result,
                      onBackToTests: _handleBack,
                    ),
                    const SizedBox(height: 16),

                    // 2. Answer Statistics Cards (Correct, Incorrect, Unattempted, Total, Score Comparison)
                    _buildAnswerStatisticsSection(isDesktop, isTablet),
                    const SizedBox(height: 16),

                    // 3. Interactive Analysis Navigation Tabs
                    ResultAnalysisTabs(
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                    ),
                    const SizedBox(height: 16),

                    // 4. Main Analysis Content Area
                    if (isDesktop)
                      _buildDesktopMainAnalysisGrid()
                    else
                      _buildMobileMainAnalysisStack(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopBackBreadcrumb() {
    return InkWell(
      onTap: _handleBack,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF10194F)),
            SizedBox(width: 6),
            Text(
              'Back to Tests',
              style: TextStyle(
                color: Color(0xFF10194F),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Section 2: Answer Statistics Row
  // ==========================================================================
  Widget _buildAnswerStatisticsSection(bool isDesktop, bool isTablet) {
    final total = widget.result.totalQuestions;
    final correct = widget.result.correctCount;
    final incorrect = widget.result.incorrectCount;
    final unattempted = widget.result.unattemptedCount;

    final correctPct = total > 0 ? (correct / total) * 100 : 0.0;
    final incorrectPct = total > 0 ? (incorrect / total) * 100 : 0.0;
    final unattemptedPct = total > 0 ? (unattempted / total) * 100 : 0.0;

    if (isDesktop) {
      // 5 Cards across the full width
      return Row(
        children: [
          Expanded(
            child: AnswerStatisticsCard(
              icon: Icons.check_circle_rounded,
              iconColor: const Color(0xFF00B96B),
              iconBgColor: const Color(0xFFE8FAF2),
              label: 'Correct Answers',
              count: correct,
              percentage: correctPct,
              percentageColor: const Color(0xFF008C52),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnswerStatisticsCard(
              icon: Icons.cancel_rounded,
              iconColor: const Color(0xFFF52245),
              iconBgColor: const Color(0xFFFEECEE),
              label: 'Incorrect Answers',
              count: incorrect,
              percentage: incorrectPct,
              percentageColor: const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnswerStatisticsCard(
              icon: Icons.remove_circle_rounded,
              iconColor: const Color(0xFF586B9B),
              iconBgColor: const Color(0xFFEDF3FB),
              label: 'Not Attempted',
              count: unattempted,
              percentage: unattemptedPct,
              percentageColor: const Color(0xFF586B9B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnswerStatisticsCard(
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFFFC928),
              iconBgColor: const Color(0xFFFFF9E6),
              label: 'Total Questions',
              count: total,
              percentage: 100,
              percentageColor: const Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ScoreComparisonCard(
              userScore: widget.result.score,
              maxScore: widget.result.maxScore,
              classAverageScore: widget.result.classAverageScore,
            ),
          ),
        ],
      );
    }

    // Mobile / Tablet Grid (4 cards in row or 2x2)
    return LayoutBuilder(
      builder: (context, constraints) {
        final use2x2 = constraints.maxWidth < 480;
        final cardWidth = use2x2
            ? (constraints.maxWidth - 10) / 2
            : (constraints.maxWidth - (10 * 3)) / 4;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: cardWidth,
              child: AnswerStatisticsCard(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF00B96B),
                iconBgColor: const Color(0xFFE8FAF2),
                label: 'Correct',
                count: correct,
                percentage: correctPct,
                percentageColor: const Color(0xFF008C52),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AnswerStatisticsCard(
                icon: Icons.cancel_rounded,
                iconColor: const Color(0xFFF52245),
                iconBgColor: const Color(0xFFFEECEE),
                label: 'Incorrect',
                count: incorrect,
                percentage: incorrectPct,
                percentageColor: const Color(0xFFDC2626),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AnswerStatisticsCard(
                icon: Icons.remove_circle_rounded,
                iconColor: const Color(0xFF586B9B),
                iconBgColor: const Color(0xFFEDF3FB),
                label: 'Not Attempted',
                count: unattempted,
                percentage: unattemptedPct,
                percentageColor: const Color(0xFF586B9B),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AnswerStatisticsCard(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFC928),
                iconBgColor: const Color(0xFFFFF9E6),
                label: 'Total Qs',
                count: total,
                percentage: 100,
                percentageColor: const Color(0xFFD97706),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // Section 4: Desktop 3-Column Responsive Analysis Grid
  // ==========================================================================
  Widget _buildDesktopMainAnalysisGrid() {
    // When specific tabs are chosen, we still keep the balanced 3-column layout
    // but highlight or adapt the middle/right content!
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Question-wise Analysis (Numbered Grid 1 to 50)
        Expanded(
          flex: 4,
          child: QuestionAnalysisGrid(
            questions: widget.result.questionItems,
            onQuestionTap: (index) => _openAnswerReview(index),
          ),
        ),
        const SizedBox(width: 16),

        // Middle Column: Subject-wise Performance (or Tab-Specific Deep Dive)
        Expanded(flex: 4, child: _buildMiddleAnalysisColumn()),
        const SizedBox(width: 16),

        // Right Column: Performance Insights & Next Steps Action Cards
        Expanded(
          flex: 3,
          child: Column(
            children: [
              PerformanceInsightCard(insights: widget.result.insights),
              const SizedBox(height: 16),
              _buildDesktopNextStepsCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiddleAnalysisColumn() {
    switch (_activeTab) {
      case ResultAnalysisTab.questions:
      case ResultAnalysisTab.subjects:
        return SubjectPerformanceCard(
          subjects: widget.result.subjectPerformances,
          onSubjectTap: (subj) => _openAnswerReview(0),
        );
      case ResultAnalysisTab.time:
        return _buildTimeAnalysisCard();
      case ResultAnalysisTab.rankRewards:
        return _buildRankAndRewardsCard();
    }
  }

  Widget _buildDesktopNextStepsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.track_changes_rounded,
                color: Color(0xFFF52245),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Next Steps',
                style: TextStyle(
                  color: Color(0xFF10194F),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Primary: Review Answers
          ResultActionButtons(
            onReviewAnswers: () => _openAnswerReview(0),
            onPracticeAgain: widget.onPracticeAgain ?? _handleBack,
            onMoreTests: widget.onMoreTests ?? _handleBack,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Section 4: Mobile Single-Column Stack
  // ==========================================================================
  Widget _buildMobileMainAnalysisStack() {
    return Column(
      children: [
        // Tab-dependent primary view
        if (_activeTab == ResultAnalysisTab.questions) ...[
          QuestionAnalysisGrid(
            questions: widget.result.questionItems,
            onQuestionTap: (index) => _openAnswerReview(index),
          ),
          const SizedBox(height: 16),
          SubjectPerformanceCard(
            subjects: widget.result.subjectPerformances,
            onSubjectTap: (subj) => _openAnswerReview(0),
          ),
        ] else if (_activeTab == ResultAnalysisTab.subjects) ...[
          SubjectPerformanceCard(
            subjects: widget.result.subjectPerformances,
            onSubjectTap: (subj) => _openAnswerReview(0),
          ),
        ] else if (_activeTab == ResultAnalysisTab.time) ...[
          _buildTimeAnalysisCard(),
        ] else if (_activeTab == ResultAnalysisTab.rankRewards) ...[
          _buildRankAndRewardsCard(),
        ],

        const SizedBox(height: 16),

        // Performance Insights Card
        PerformanceInsightCard(insights: widget.result.insights),
        const SizedBox(height: 16),

        // Action Buttons
        ResultActionButtons(
          onReviewAnswers: () => _openAnswerReview(0),
          onPracticeAgain: widget.onPracticeAgain ?? _handleBack,
          onMoreTests: widget.onMoreTests ?? _handleBack,
        ),
      ],
    );
  }

  // ==========================================================================
  // Custom Tab Cards: Time Analysis & Rank/Rewards
  // ==========================================================================
  Widget _buildTimeAnalysisCard() {
    final avgTimePerQ = widget.result.totalQuestions > 0
        ? (widget.result.timeTakenSeconds / widget.result.totalQuestions)
              .round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF2587F8),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Time Management Analysis',
                  style: TextStyle(
                    color: Color(0xFF10194F),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildStatRow(
            'Total Exam Duration',
            '${widget.result.totalDurationSeconds ~/ 60} mins',
          ),
          const Divider(height: 16, color: Color(0xFFE2ECFA)),
          _buildStatRow('Your Total Time', widget.result.formattedTimeTaken),
          const Divider(height: 16, color: Color(0xFFE2ECFA)),
          _buildStatRow('Average Time / Question', '${avgTimePerQ}s'),
          const Divider(height: 16, color: Color(0xFFE2ECFA)),
          _buildStatRow('Pacing Rating', 'Fast & Accurate (Top 5%)'),
        ],
      ),
    );
  }

  Widget _buildRankAndRewardsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFC928),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Rank & Reward Standing',
                  style: TextStyle(
                    color: Color(0xFF10194F),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildStatRow('Leaderboard Rank', widget.result.formattedRank),
          const Divider(height: 16, color: Color(0xFFE2ECFA)),
          _buildStatRow('Percentile Standing', 'Top 1.2% Aspirants'),
          const Divider(height: 16, color: Color(0xFFE2ECFA)),
          _buildStatRow(
            'Class Average Score',
            '${widget.result.classAverageScore.toInt()} / ${widget.result.maxScore.toInt()}',
          ),
          const Divider(height: 16, color: Color(0xFFE2ECFA)),
          _buildStatRow(
            'Coins Earned For Test',
            '+${widget.result.coinsEarned} Coins',
            valueColor: const Color(0xFF00B96B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF586B9B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF10194F),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
