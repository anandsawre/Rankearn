import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'test_papers_list_screen.dart';

/// Dedicated Exam Screen: Opens when student taps any Target Exam (e.g. Ctest, BPSC, SSC, Railway).
/// Displays Test Format & Mode cards with equal heights and full-width layout.
/// Tapping any card opens a dedicated TestPapersListScreen where all matching papers can be attempted.
class ExamTestsScreen extends StatefulWidget {
  final ExamCategoryModel exam;
  final int userCoins;
  final void Function(TestModel test) onStartTest;
  final List<TestModel> allTests;
  final List<CategoryModel> allCategories;

  const ExamTestsScreen({
    super.key,
    required this.exam,
    required this.userCoins,
    required this.onStartTest,
    required this.allTests,
    required this.allCategories,
  });

  @override
  State<ExamTestsScreen> createState() => _ExamTestsScreenState();
}

class _ExamTestsScreenState extends State<ExamTestsScreen> {
  List<TestModel> get _examTests {
    final examQuery = widget.exam.id.toLowerCase();
    return widget.allTests.where((t) {
      if (examQuery == 'all') return true;
      final matchesExamId = t.examCategoryId != null &&
          (t.examCategoryId!.toLowerCase() == examQuery ||
              t.examCategoryId!.toLowerCase().contains(examQuery) ||
              examQuery.contains(t.examCategoryId!.toLowerCase()));
      final matchesTitle = t.title.toLowerCase().contains(examQuery);
      final matchesCategory =
          t.categoryId != null &&
          t.categoryId!.toLowerCase().contains(examQuery);

      final testCat = widget.allCategories.cast<CategoryModel?>().firstWhere(
        (c) =>
            c != null &&
            (c.id == t.categoryId ||
                c.name.toLowerCase() == t.categoryId?.toLowerCase()),
        orElse: () => null,
      );
      final matchesExamCat =
          testCat != null &&
          testCat.examCategoryId != null &&
          testCat.examCategoryId!.toLowerCase() == examQuery;

      return matchesExamId || matchesTitle || matchesCategory || matchesExamCat;
    }).toList();
  }

  void _openModeTests({
    required String modeKey,
    required String modeTitle,
    required String modeSubtitle,
    required IconData modeIcon,
    required Color accentColor,
    required List<TestModel> tests,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestPapersListScreen(
          exam: widget.exam,
          modeKey: modeKey,
          modeTitle: modeTitle,
          modeSubtitle: modeSubtitle,
          modeIcon: modeIcon,
          accentColor: accentColor,
          tests: tests,
          allCategories: widget.allCategories,
          userCoins: widget.userCoins,
          onStartTest: widget.onStartTest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1E293B),
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.exam.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10F59E0B),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '₹',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${widget.userCoins}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.2),
          child: Container(color: const Color(0xFFF1F5F9), height: 1.2),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 960;

          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 16,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Test Format & Mode Selector Cards
                  _buildTestModeCards(isDesktop: isDesktop),
                  const SizedBox(height: 28),

                  // 3. Exam Highlights & Preparation Features
                  _buildExamHighlights(isDesktop: isDesktop),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Test-Type Mode Selector Cards ---
  Widget _buildTestModeCards({required bool isDesktop}) {
    final examTests = _examTests;

    final actualMock = examTests.where((t) => t.testMode == 'mock').length;
    final mockCount = actualMock > 0
        ? actualMock
        : (widget.exam.totalMocks > 0 ? widget.exam.totalMocks : 0);

    final actualSec = examTests
        .where((t) =>
            t.testMode == 'chapter' ||
            t.testMode == 'topic' ||
            t.testMode == 'sectional')
        .length;
    final secCount = actualSec > 0
        ? actualSec
        : (widget.exam.totalSectional > 0 ? widget.exam.totalSectional : 0);

    final pyqCount =
        examTests.where((t) => t.testMode == 'previous-year').length;

    final actualDaily = examTests.where((t) => t.testMode == 'daily').length;
    final dailyCount = actualDaily > 0 ? actualDaily : 1;

    final cardMock = _buildFeaturedModeCard(
      title: 'MOCK TESTS',
      subtitle: 'FULL LENGTH PAPERS',
      description:
          'Full length mock tests based on latest actual exam patterns with detailed solutions and ranking.',
      icon: Icons.description_outlined,
      accentColor: const Color(0xFF00B67A),
      stat1Text: '$mockCount TESTS AVAILABLE',
      stat1Icon: Icons.check_circle_outline_rounded,
      stat2Text: 'PREMIUM & FREE OPTIONS',
      buttonLabel: 'EXPLORE MOCK TESTS',
      onTap: () {
        final filtered = examTests.where((t) => t.testMode == 'mock').toList();
        _openModeTests(
          modeKey: 'mock',
          modeTitle: 'MOCK TESTS',
          modeSubtitle: 'FULL LENGTH PAPERS',
          modeIcon: Icons.description_outlined,
          accentColor: const Color(0xFF00B67A),
          tests: filtered,
        );
      },
    );

    final cardSectional = _buildFeaturedModeCard(
      title: 'SECTIONAL TESTS',
      subtitle: 'SUBJECT & TOPIC WISE',
      description:
          'Subject and Topic-wise practice tests to master specific areas and build a strong foundation.',
      icon: Icons.menu_book_outlined,
      accentColor: const Color(0xFF2563EB),
      stat1Text: '$secCount TESTS AVAILABLE',
      stat1Icon: Icons.layers_outlined,
      stat2Text: 'PREMIUM & FREE OPTIONS',
      buttonLabel: 'EXPLORE SECTIONAL TESTS',
      onTap: () {
        final filtered = examTests
            .where((t) =>
                t.testMode == 'chapter' ||
                t.testMode == 'topic' ||
                t.testMode == 'sectional')
            .toList();
        _openModeTests(
          modeKey: 'sectional',
          modeTitle: 'SECTIONAL TESTS',
          modeSubtitle: 'SUBJECT & TOPIC WISE',
          modeIcon: Icons.menu_book_outlined,
          accentColor: const Color(0xFF2563EB),
          tests: filtered,
        );
      },
    );

    final cardPyq = _buildFeaturedModeCard(
      title: 'PREVIOUS YEAR',
      subtitle: 'ACTUAL EXAM PAPERS',
      description:
          'Practice with original previous year question papers to understand the real exam difficulty and pattern.',
      icon: Icons.access_time_rounded,
      accentColor: const Color(0xFF9333EA),
      stat1Text: '$pyqCount PAPERS AVAILABLE',
      stat1Icon: Icons.access_time_rounded,
      stat2Text: 'VERIFIED SOLUTIONS',
      buttonLabel: 'EXPLORE PYQ TESTS',
      onTap: () {
        final filtered =
            examTests.where((t) => t.testMode == 'previous-year').toList();
        _openModeTests(
          modeKey: 'previous-year',
          modeTitle: 'PREVIOUS YEAR',
          modeSubtitle: 'ACTUAL EXAM PAPERS',
          modeIcon: Icons.access_time_rounded,
          accentColor: const Color(0xFF9333EA),
          tests: filtered,
        );
      },
    );

    final cardDaily = _buildFeaturedModeCard(
      title: 'DAILY TEST',
      subtitle: 'DAILY SPEED BOOST',
      description:
          'Daily fresh practice questions to maintain consistency, improve speed, and boost your rank.',
      icon: Icons.local_fire_department_rounded,
      accentColor: const Color(0xFFF97316),
      stat1Text: '$dailyCount TESTS TODAY',
      stat1Icon: Icons.local_fire_department_rounded,
      stat2Text: 'EARN COINS & STREAK',
      buttonLabel: 'EXPLORE DAILY TESTS',
      onTap: () {
        final filtered = examTests.where((t) => t.testMode == 'daily').toList();
        _openModeTests(
          modeKey: 'daily',
          modeTitle: 'DAILY TEST',
          modeSubtitle: 'DAILY SPEED BOOST',
          modeIcon: Icons.local_fire_department_rounded,
          accentColor: const Color(0xFFF97316),
          tests: filtered,
        );
      },
    );

    final cardMyTests = _buildFeaturedModeCard(
      title: 'MY TESTS',
      subtitle: 'ATTEMPTED & SAVED',
      description:
          'Review your attempted test papers, detailed answer analysis, and bookmarked questions.',
      icon: Icons.bookmark_border_rounded,
      accentColor: const Color(0xFF0EA5E9),
      stat1Text: 'PERSONAL ATTEMPTS',
      stat1Icon: Icons.history_rounded,
      stat2Text: 'DETAILED ACCURACY REPORT',
      buttonLabel: 'VIEW MY TESTS',
      onTap: () {
        final filtered = examTests
            .where((t) =>
                !t.isProOnly || widget.userCoins >= t.unlockPriceCoins)
            .toList();
        _openModeTests(
          modeKey: 'my-tests',
          modeTitle: 'MY TESTS',
          modeSubtitle: 'ATTEMPTED & SAVED',
          modeIcon: Icons.bookmark_border_rounded,
          accentColor: const Color(0xFF0EA5E9),
          tests: filtered,
        );
      },
    );

    final cardAll = _buildFeaturedModeCard(
      title: 'ALL TESTS',
      subtitle: 'COMPLETE CATALOG',
      description:
          'Explore the complete repository of mock papers, sectional practice, and official question sets together.',
      icon: Icons.grid_view_rounded,
      accentColor: const Color(0xFF6366F1),
      stat1Text: '${examTests.length} TOTAL TESTS',
      stat1Icon: Icons.grid_view_rounded,
      stat2Text: 'FULL SYLLABUS ACCESS',
      buttonLabel: 'EXPLORE ALL TESTS',
      onTap: () {
        _openModeTests(
          modeKey: 'all',
          modeTitle: 'ALL TESTS',
          modeSubtitle: 'COMPLETE CATALOG',
          modeIcon: Icons.grid_view_rounded,
          accentColor: const Color(0xFF6366F1),
          tests: examTests,
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.tune_rounded, color: Color(0xFF10B981), size: 19),
                SizedBox(width: 8),
                Text(
                  'Test Format & Mode',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _openModeTests(
                modeKey: 'all',
                modeTitle: 'ALL TESTS',
                modeSubtitle: 'COMPLETE CATALOG',
                modeIcon: Icons.grid_view_rounded,
                accentColor: const Color(0xFF6366F1),
                tests: examTests,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.grid_view_rounded,
                        size: 13, color: Color(0xFF2587F8)),
                    SizedBox(width: 5),
                    Text(
                      'View All Tests',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2587F8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, height: 340, child: cardMock),
              const SizedBox(width: 16),
              SizedBox(width: 330, height: 340, child: cardSectional),
              const SizedBox(width: 16),
              SizedBox(width: 330, height: 340, child: cardPyq),
              const SizedBox(width: 16),
              SizedBox(width: 330, height: 340, child: cardDaily),
              const SizedBox(width: 16),
              SizedBox(width: 330, height: 340, child: cardMyTests),
              const SizedBox(width: 16),
              SizedBox(width: 330, height: 340, child: cardAll),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedModeCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color accentColor,
    required String stat1Text,
    required IconData stat1Icon,
    required String stat2Text,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Top-Left Corner Decorative Ribbon Wave
            Positioned(
              top: 0,
              left: 0,
              child: CustomPaint(
                size: const Size(88, 88),
                painter: CornerRibbonPainter(color: accentColor),
              ),
            ),

            // Main Card Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar Icon + Title + Subtitle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFF1F5F9), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(icon, color: accentColor, size: 23),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Description with fixed height for equal vertical rhythm
                  SizedBox(
                    height: 40,
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                  const SizedBox(height: 12),

                  // Stat Row 1
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(stat1Icon, color: accentColor, size: 12),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          stat1Text,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Stat Row 2
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.lock_outline_rounded,
                              color: Color(0xFFF59E0B), size: 12),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          stat2Text,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: onTap,
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Exam Preparation Highlights ---
  Widget _buildExamHighlights({required bool isDesktop}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text(
                'How to Prepare Effectively',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              _buildHighlightTile(
                title: 'Start with Mock Tests',
                desc: 'Simulate real exam timings, negative marking, and evaluate your percentile.',
                icon: Icons.timer_outlined,
                color: const Color(0xFF10B981),
              ),
              _buildHighlightTile(
                title: 'Master Weak Sections',
                desc: 'Take Sectional Tests to drill deep into specific subjects and concepts.',
                icon: Icons.auto_stories_outlined,
                color: const Color(0xFF2563EB),
              ),
              _buildHighlightTile(
                title: 'Solve Official PYQs',
                desc: 'Get familiar with previous year question papers and repeated question patterns.',
                icon: Icons.history_edu_rounded,
                color: const Color(0xFF9333EA),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightTile({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the corner ribbon
class CornerRibbonPainter extends CustomPainter {
  final Color color;

  CornerRibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.35,
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..style = PaintingStyle.fill;

    final highlightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.2,
        0,
        size.height * 0.45,
      )
      ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CornerRibbonPainter oldDelegate) =>
      oldDelegate.color != color;
}
