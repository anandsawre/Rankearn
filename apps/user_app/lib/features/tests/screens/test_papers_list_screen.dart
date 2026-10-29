import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// Dedicated Screen displaying the full list of test papers for a chosen mode
/// (e.g. Mock Tests, Sectional Tests, Previous Year Papers) where the user can attempt them.
class TestPapersListScreen extends StatefulWidget {
  final ExamCategoryModel exam;
  final String modeKey; // 'mock' | 'sectional' | 'previous-year' | 'daily' | 'my-tests' | 'all'
  final String modeTitle;
  final String modeSubtitle;
  final IconData modeIcon;
  final Color accentColor;
  final List<TestModel> tests;
  final List<CategoryModel> allCategories;
  final int userCoins;
  final void Function(TestModel test) onStartTest;

  const TestPapersListScreen({
    super.key,
    required this.exam,
    required this.modeKey,
    required this.modeTitle,
    required this.modeSubtitle,
    required this.modeIcon,
    required this.accentColor,
    required this.tests,
    required this.allCategories,
    required this.userCoins,
    required this.onStartTest,
  });

  @override
  State<TestPapersListScreen> createState() => _TestPapersListScreenState();
}

class _TestPapersListScreenState extends State<TestPapersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSubject;
  CategoryModel? _selectedCategory;
  String? _selectedTopic;

  List<
    ({String title, String questionCount, IconData icon, Color color, Color bg})
  > _subjects = [];

  @override
  void initState() {
    super.initState();
    if (widget.modeKey == 'sectional' || widget.modeKey == 'all') {
      _loadExamSubjects();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExamSubjects() {
    final examId = widget.exam.id.toLowerCase();
    final filtered = widget.allCategories.where((c) {
      if (examId == 'all') return true;
      return c.examCategoryId != null &&
          c.examCategoryId!.toLowerCase() == examId;
    }).toList();

    _subjects = filtered.map((c) {
      final accent = _resolveCategoryColor(c.iconColor);
      final countText = c.totalQuestions > 0
          ? '${c.totalQuestions}+ Qs'
          : (c.topics.isNotEmpty
                ? '${c.topics.length} Chapters'
                : 'Practice Qs');
      return (
        title: c.name,
        questionCount: countText,
        icon: _resolveCategoryIcon(c.iconName),
        color: accent,
        bg: accent.withAlpha(25),
      );
    }).toList();
  }

  IconData _resolveCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'science':
        return Icons.science_rounded;
      case 'calculate':
        return Icons.calculate_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'newspaper':
        return Icons.newspaper_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'school':
        return Icons.school_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color _resolveCategoryColor(
    String hex, [
    Color fallback = const Color(0xFF2587F8),
  ]) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  List<TestModel> get _filteredTests {
    return widget.tests.where((test) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty &&
          !test.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // 2. Subject filter (if sectional mode)
      if (_selectedCategory != null) {
        final catName = _selectedCategory!.name.toLowerCase();
        final catId = _selectedCategory!.id.toLowerCase();
        final matchesCat =
            (test.categoryId != null &&
                (test.categoryId!.toLowerCase() == catId ||
                    test.categoryId!.toLowerCase() == catName ||
                    test.categoryId!.toLowerCase().contains(catName) ||
                    catName.contains(test.categoryId!.toLowerCase()))) ||
            test.title.toLowerCase().contains(catName);
        if (!matchesCat) return false;
      } else if (_selectedSubject != null && _selectedSubject != 'All') {
        final subName = _selectedSubject!.replaceAll('\n', ' ').toLowerCase();
        if (!test.title.toLowerCase().contains(subName) &&
            (test.categoryId == null ||
                (!test.categoryId!.toLowerCase().contains(subName) &&
                    !subName.contains(test.categoryId!.toLowerCase())))) {
          return false;
        }
      }

      // 3. Topic filter
      if (_selectedTopic != null && _selectedTopic != 'All') {
        final topicQuery = _selectedTopic!.toLowerCase();
        if (!test.title.toLowerCase().contains(topicQuery) &&
            (test.categoryId == null ||
                !test.categoryId!.toLowerCase().contains(topicQuery))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredTests;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.exam.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              '${widget.modeTitle} • ${list.length} Tests',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: widget.accentColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
          final isMobile = constraints.maxWidth < 600;

          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 24,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional Modern Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _searchQuery.isNotEmpty
                            ? widget.accentColor
                            : const Color(0xFFE2E8F0),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _searchQuery.isNotEmpty
                              ? widget.accentColor.withAlpha(25)
                              : const Color(0x080F172A),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left Accent Icon Badge
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(left: 10, right: 8),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withAlpha(22),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.search_rounded,
                              color: widget.accentColor,
                              size: 18,
                            ),
                          ),
                        ),

                        // Search Text Input
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Search test papers by title, topic...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                        // Clear Button or Filter Badge
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            splashRadius: 18,
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 12,
                                  color: Color(0xFF64748B),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Filter',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Subject selection (if Sectional mode)
                  if ((widget.modeKey == 'sectional' || widget.modeKey == 'all') &&
                      _subjects.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter by Subject',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_selectedSubject != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSubject = null;
                                _selectedCategory = null;
                                _selectedTopic = null;
                              });
                            },
                            child: const Text(
                              'Clear Subject Filter',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2587F8),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          for (final sub in _subjects) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(sub.title),
                                selected: _selectedSubject == sub.title,
                                selectedColor: widget.accentColor,
                                labelStyle: TextStyle(
                                  color: _selectedSubject == sub.title
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (sel) {
                                  setState(() {
                                    if (sel) {
                                      _selectedSubject = sub.title;
                                      _selectedCategory = widget.allCategories
                                          .cast<CategoryModel?>()
                                          .firstWhere(
                                            (c) =>
                                                c != null &&
                                                c.name.toLowerCase() ==
                                                    sub.title.toLowerCase(),
                                            orElse: () => null,
                                          );
                                      _selectedTopic = null;
                                    } else {
                                      _selectedSubject = null;
                                      _selectedCategory = null;
                                      _selectedTopic = null;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Header Row with count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Papers (${list.length})',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedSubject != null)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedSubject = null;
                              _selectedCategory = null;
                              _selectedTopic = null;
                            });
                          },
                          icon: const Icon(Icons.clear_rounded, size: 14),
                          label: const Text('Reset Filter', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Test Cards List
                  if (list.isEmpty)
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 44,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tests available in ${widget.modeTitle} yet',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'New papers will be uploaded soon. Please check back later!',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    for (final test in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildAttemptTestCard(test, isMobile: isMobile),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttemptTestCard(TestModel test, {required bool isMobile}) {
    final isFree = !test.isPremium && test.unlockPriceCoins <= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Right Vector Illustration Background (NO image asset - pure CustomPaint vector)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: isMobile ? 150 : 280,
            child: IgnorePointer(
              child: CustomPaint(
                painter: isFree
                    ? FreeTestCardDecorationPainter(isMobile: isMobile)
                    : CoinsTestCardDecorationPainter(isMobile: isMobile),
              ),
            ),
          ),

          // 2. Card Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 18,
              vertical: isMobile ? 14 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Badges (bounded by Expanded so Duration badge NEVER overflows on mobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Category pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.menu_book_rounded,
                                  size: 13,
                                  color: Color(0xFF2587F8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  test.categoryId ?? widget.exam.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2587F8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Free or Coins pill
                          if (isFree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.card_giftcard_rounded,
                                    size: 13,
                                    color: Color(0xFF00B67A),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '100% Free',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF00B67A),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${test.unlockPriceCoins} Coins',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Duration pill (right)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFF475569),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${test.durationMinutes} mins',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  test.title,
                  style: TextStyle(
                    fontSize: isMobile ? 17 : 19,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle metadata row (Atomic rows inside Wrap to never split icon from label)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 13.5,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${test.totalQuestions} Questions',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_graph_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '-${test.negativeMarking} Negative',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 13.5,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pattern: ${test.testMode.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom feature text & "Attempt Test" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isFree ? Icons.bolt_rounded : Icons.lock_rounded,
                            size: isFree ? 18 : 16,
                            color: isFree
                                ? const Color(0xFF00B67A)
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              isFree
                                  ? (isMobile ? 'Free Mock Test' : 'Free Mock Test • Instant Result & Analysis')
                                  : (isMobile ? 'Requires ${test.unlockPriceCoins} Coins' : 'Requires ${test.unlockPriceCoins} Coins to Unlock'),
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.w800,
                                color: isFree
                                    ? const Color(0xFF00B67A)
                                    : const Color(0xFFD97706),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Solid Green Button "▶ Attempt Test"
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B67A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 15 : 22,
                          vertical: isMobile ? 9 : 12,
                        ),
                      ),
                      onPressed: () {
                        if (!isFree) {
                          _showPurchaseDialog(test);
                        } else {
                          widget.onStartTest(test);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: isMobile ? 17 : 19,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Attempt Test',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
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

  void _showPurchaseDialog(TestModel test) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_open_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Unlock Test Series', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Unlock "${test.title}" for ${test.unlockPriceCoins} coins?\nYour balance: ${widget.userCoins} coins',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Unlock & Start',
            size: AppButtonSize.small,
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            borderRadius: AppRadii.borderMd,
            onPressed: () {
              Navigator.pop(ctx);
              widget.onStartTest(test);
            },
          ),
        ],
      ),
    );
  }
}



