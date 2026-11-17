import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'exam_tests_screen.dart';

/// Dedicated Screen: Explore All Target Exams
/// Opened when student taps "All Exams" card or "View All Exams" from Test Series Tab.
/// Tapping any Exam Card opens the dedicated ExamTestsScreen (Mock, Sectional, PYQ, Daily Tests).
class AllExamsScreen extends StatefulWidget {
  final List<ExamCategoryModel> examCategories;
  final List<TestModel> allTests;
  final List<CategoryModel> allCategories;
  final int userCoins;
  final void Function(TestModel test) onStartTest;

  const AllExamsScreen({
    super.key,
    required this.examCategories,
    required this.allTests,
    required this.allCategories,
    required this.userCoins,
    required this.onStartTest,
  });

  @override
  State<AllExamsScreen> createState() => _AllExamsScreenState();
}

class _AllExamsScreenState extends State<AllExamsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = [
    'all',
    'railway',
    'ssc',
    'bpsc',
    'banking',
    'teaching',
    'defence',
  ];

  static const Map<String, String> _filterLabels = {
    'all': 'All Exams',
    'railway': 'Railway',
    'ssc': 'SSC',
    'bpsc': 'State PSC',
    'banking': 'Banking',
    'teaching': 'Teaching',
    'defence': 'Defence',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExamCategoryModel> get _filteredExams {
    return widget.examCategories.where((exam) {
      final nameLower = exam.name.toLowerCase();
      final idLower = exam.id.toLowerCase();
      final queryLower = _searchQuery.trim().toLowerCase();

      // Search match
      final matchesSearch = queryLower.isEmpty ||
          nameLower.contains(queryLower) ||
          idLower.contains(queryLower);

      if (!matchesSearch) return false;

      // Filter category match
      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'railway') {
        return nameLower.contains('railway') ||
            nameLower.contains('rrb') ||
            idLower.contains('railway') ||
            idLower.contains('rrb');
      }
      if (_selectedFilter == 'ssc') {
        return nameLower.contains('ssc') || idLower.contains('ssc');
      }
      if (_selectedFilter == 'bpsc') {
        return nameLower.contains('bpsc') ||
            nameLower.contains('pcs') ||
            nameLower.contains('state') ||
            idLower.contains('bpsc');
      }
      if (_selectedFilter == 'banking') {
        return nameLower.contains('bank') ||
            nameLower.contains('ibps') ||
            nameLower.contains('sbi') ||
            idLower.contains('bank');
      }
      if (_selectedFilter == 'teaching') {
        return nameLower.contains('teach') ||
            nameLower.contains('tet') ||
            nameLower.contains('ctet') ||
            idLower.contains('teach');
      }
      if (_selectedFilter == 'defence') {
        return nameLower.contains('defence') ||
            nameLower.contains('nda') ||
            nameLower.contains('cds') ||
            nameLower.contains('army');
      }

      return true;
    }).toList();
  }

  void _openExam(ExamCategoryModel exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamTestsScreen(
          exam: exam,
          userCoins: widget.userCoins,
          onStartTest: widget.onStartTest,
          allTests: widget.allTests,
          allCategories: widget.allCategories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExams;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
          children: [
            const Text(
              'Target Exams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 0.2,
              ),
            ),
            Text(
              '${widget.examCategories.length} Categories Available',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
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
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 960;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AppSpacing.pagePaddingDesktop : AppSpacing.cardPadding,
              vertical: isDesktop ? AppSpacing.xl : AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Bar
                _buildSearchBar(),
                const SizedBox(height: 14),

                // Category Filter Pills
                _buildFilterChips(),
                const SizedBox(height: 20),

                // Results Counter & Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          color: AppColors.brandGreen,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Available Target Exams (${filtered.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    if (_searchQuery.isNotEmpty || _selectedFilter != 'all')
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedFilter = 'all';
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.close_rounded, size: 14),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Grid of Exam Cards
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  _buildExamsGrid(
                    exams: filtered,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search exams (e.g. Railway, BPSC, SSC, Banking)...',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filterKey) {
          final isSelected = _selectedFilter == filterKey;
          final label = _filterLabels[filterKey] ?? filterKey;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = filterKey),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandGreen : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.brandGreen : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.brandGreen.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Color(0x050F172A),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExamsGrid({
    required List<ExamCategoryModel> exams,
    required bool isDesktop,
    required bool isTablet,
  }) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final childAspectRatio = isDesktop ? 1.05 : (isTablet ? 0.95 : 0.88);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exams.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _buildExamCard(exam: exam, index: index);
      },
    );
  }

  Widget _buildExamCard({
    required ExamCategoryModel exam,
    required int index,
  }) {
    final palette = _getExamPalette(index);
    final iconData = _resolveExamVectorIcon(exam.name, exam.id);

    // Compute actual test counts matching this exam
    final examQuery = exam.id.toLowerCase();
    final matchingTests = widget.allTests.where((t) {
      if (examQuery == 'all') return true;
      final matchesExamId = t.examCategoryId != null &&
          (t.examCategoryId!.toLowerCase() == examQuery ||
              t.examCategoryId!.toLowerCase().contains(examQuery) ||
              examQuery.contains(t.examCategoryId!.toLowerCase()));
      final matchesTitle = t.title.toLowerCase().contains(examQuery);
      return matchesExamId || matchesTitle;
    }).toList();

    final actualMocks = matchingTests.where((t) => t.testMode == 'mock').length;
    final displayMocks = actualMocks > 0 ? actualMocks : exam.totalMocks;

    final actualSec = matchingTests
        .where((t) =>
            t.testMode == 'chapter' ||
            t.testMode == 'topic' ||
            t.testMode == 'sectional')
        .length;
    final displaySec = actualSec > 0 ? actualSec : exam.totalSectional;

    return InkWell(
      onTap: () => _openExam(exam),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.bg, palette.bgEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: palette.accent.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: palette.accent.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      size: 22,
                      color: palette.accent,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${displayMocks + displaySec} Tests',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: palette.accent,
                    ),
                  ),
                ),
              ],
            ),

            // Middle: Exam Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exam.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // Badges row
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildPillBadge(
                      label: '$displayMocks Mocks',
                      color: const Color(0xFF059669),
                      bg: const Color(0xFFECFDF5),
                    ),
                    _buildPillBadge(
                      label: '$displaySec Sectional',
                      color: const Color(0xFF2563EB),
                      bg: const Color(0xFFEFF6FF),
                    ),
                  ],
                ),
              ],
            ),

            // Bottom CTA
            Row(
              children: [
                Text(
                  'Explore Series',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: palette.accent,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: palette.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No target exams matching "$_searchQuery"'
                  : 'No exams found in this category',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching for Railway, BPSC, SSC or Banking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _ExamCategoryStyle _getExamPalette(int index) {
    const palettes = [
      _ExamCategoryStyle(
        bg: Color(0xFFF5F7FF),
        bgEnd: Color(0xFFE0E7FF),
        border: Color(0xFFC7D2FE),
        accent: Color(0xFF4F46E5),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFF0FDF4),
        bgEnd: Color(0xFFD1FAE5),
        border: Color(0xFFA7F3D0),
        accent: Color(0xFF059669),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFFFFDF5),
        bgEnd: Color(0xFFFEF3C7),
        border: Color(0xFFFDE68A),
        accent: Color(0xFFD97706),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFFAF5FF),
        bgEnd: Color(0xFFEDE9FE),
        border: Color(0xFFDDD6FE),
        accent: Color(0xFF7C3AED),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFF0F9FF),
        bgEnd: Color(0xFFE0F2FE),
        border: Color(0xFFBAE6FD),
        accent: Color(0xFF0284C7),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFFFF1F2),
        bgEnd: Color(0xFFFFE4E6),
        border: Color(0xFFFECDD3),
        accent: Color(0xFFE11D48),
      ),
    ];
    return palettes[index % palettes.length];
  }

  static IconData _resolveExamVectorIcon(String name, String id) {
    final lower = ('$name $id').toLowerCase();
    if (lower.contains('railway') || lower.contains('rrb') || lower.contains('technician') || lower.contains('alp')) {
      return Icons.train_rounded;
    }
    if (lower.contains('bpsc') || lower.contains('state pcs') || lower.contains('civil') || lower.contains('pcs')) {
      return Icons.account_balance_rounded;
    }
    if (lower.contains('upsc') || lower.contains('ias') || lower.contains('ips')) {
      return Icons.military_tech_rounded;
    }
    if (lower.contains('ssc') || lower.contains('cgl') || lower.contains('chsl') || lower.contains('mts')) {
      return Icons.verified_user_rounded;
    }
    if (lower.contains('bank') || lower.contains('ibps') || lower.contains('sbi') || lower.contains('po')) {
      return Icons.savings_rounded;
    }
    if (lower.contains('ctet') || lower.contains('teach') || lower.contains('tet') || lower.contains('prt')) {
      return Icons.school_rounded;
    }
    if (lower.contains('defence') || lower.contains('nda') || lower.contains('cds') || lower.contains('army')) {
      return Icons.shield_rounded;
    }
    return Icons.auto_stories_rounded;
  }
}

class _ExamCategoryStyle {
  final Color bg;
  final Color bgEnd;
  final Color border;
  final Color accent;

  const _ExamCategoryStyle({
    required this.bg,
    required this.bgEnd,
    required this.border,
    required this.accent,
  });
}
