import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';

class QuestionsTableCard extends StatefulWidget {
  final List<QuestionItem> items;
  final int totalCount;
  final String selectedTestSeries;
  final String selectedSubject;
  final String selectedType;
  final String selectedDifficulty;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
  final ValueChanged<String> onTestSeriesChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onDifficultyChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<QuestionItem> onView;
  final ValueChanged<QuestionItem> onEdit;
  final ValueChanged<QuestionItem> onDuplicate;
  final ValueChanged<QuestionItem> onDelete;
  final ValueChanged<QuestionItem> onToggleStatus;
  final ValueChanged<List<String>>? onSelectionChanged;
  final VoidCallback? onOpenFilters;

  const QuestionsTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.selectedTestSeries,
    required this.selectedSubject,
    required this.selectedType,
    required this.selectedDifficulty,
    required this.searchQuery,
    required this.currentPage,
    required this.totalPages,
    required this.onTestSeriesChanged,
    required this.onSubjectChanged,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
    required this.onSearchChanged,
    required this.onPageChanged,
    required this.onView,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onToggleStatus,
    this.onSelectionChanged,
    this.onOpenFilters,
  });

  @override
  State<QuestionsTableCard> createState() => _QuestionsTableCardState();
}

class _QuestionsTableCardState extends State<QuestionsTableCard> {
  late TextEditingController _searchController;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant QuestionsTableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _allCurrentSelected =>
      widget.items.isNotEmpty && widget.items.every((i) => _selectedIds.contains(i.id));

  void _toggleSelectAll(bool? val) {
    setState(() {
      if (val == true) {
        for (final item in widget.items) {
          _selectedIds.add(item.id);
        }
      } else {
        for (final item in widget.items) {
          _selectedIds.remove(item.id);
        }
      }
    });
    widget.onSelectionChanged?.call(_selectedIds.toList());
  }

  void _toggleSelectItem(String id, bool? val) {
    setState(() {
      if (val == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
    widget.onSelectionChanged?.call(_selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Table Top Controls Bar (Responsive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Builder(
              builder: (context) {
                final isNarrow = MediaQuery.sizeOf(context).width < 950;

                final controlsList = [
                  // Dropdown 1: All Test Series
                  _buildDropdown(
                    value: widget.selectedTestSeries,
                    items: const [
                      'All Test Series',
                      'RRB Technician Grade 3',
                      'Current Affairs Practice Series',
                      'Railway Maths Practice Series',
                      'Chemistry Practice Series',
                      'Biology Marathon Series',
                      'Reasoning Special Series',
                      'Current Affairs Monthly Series',
                    ],
                    onChanged: widget.onTestSeriesChanged,
                  ),
                  const SizedBox(width: 6),

                  // Dropdown 2: All Subjects
                  _buildDropdown(
                    value: widget.selectedSubject,
                    items: const [
                      'All Subjects',
                      'Physics',
                      'General Awareness',
                      'Mathematics',
                      'Chemistry',
                      'Biology',
                      'Reasoning',
                      'Polity',
                    ],
                    onChanged: widget.onSubjectChanged,
                  ),
                  const SizedBox(width: 6),

                  // Dropdown 3: All Types
                  _buildDropdown(
                    value: widget.selectedType,
                    items: const [
                      'All Types',
                      'MCQ',
                      'True/False',
                      'Fill in the Blanks',
                      'Match the Following',
                      'Assertion & Reason',
                      'Subjective',
                    ],
                    onChanged: widget.onTypeChanged,
                  ),
                  const SizedBox(width: 6),

                  // Dropdown 4: All Difficulty
                  _buildDropdown(
                    value: widget.selectedDifficulty,
                    items: const [
                      'All Difficulty',
                      'Easy',
                      'Medium',
                      'Hard',
                      'Expert',
                    ],
                    onChanged: widget.onDifficultyChanged,
                  ),
                  const SizedBox(width: 6),

                  // Search Field
                  SizedBox(
                    width: 160,
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                      style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search questions...',
                        hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 26),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.borderSm,
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadii.borderSm,
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadii.borderSm,
                          borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Filters Button
                  _buildFiltersButton(context),
                ];

                final titleRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.description_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Questions List (${_formatNumber(widget.totalCount)})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleRow,
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: controlsList,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    titleRow,
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          children: controlsList,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 2. Data Table with Dynamic Stretch
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.sizeOf(context).width;
              final isDesktop = screenWidth >= 1024;
              final availableWidth = isDesktop
                  ? math.max(680.0, screenWidth - 48 - 16 - 295 - 2)
                  : math.max(680.0, screenWidth - 48);

              // Expand details column to fill available card width
              final double detailsWidth = (availableWidth * 0.20).clamp(160.0, 320.0);
              const double fixedColumnsWidth =
                  24.0 + 22.0 + 85.0 + 100.0 + 55.0 + 65.0 + 60.0 + 65.0 + 65.0 + 75.0 + 110.0 + 32.0;
              final double totalNeededWidth = fixedColumnsWidth + detailsWidth;
              final double remainingSpace = availableWidth - totalNeededWidth;
              final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 11).clamp(6.0, 40.0) : 6.0;
              final double tableMinWidth = availableWidth >= 880.0 ? availableWidth : 880.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinWidth),
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowHeight: 40,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    horizontalMargin: 16,
                    columnSpacing: dynamicColumnSpacing,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: [
                      // 1. Select All Checkbox
                      DataColumn(
                        label: SizedBox(
                          width: 20,
                          child: Transform.scale(
                            scale: 0.85,
                            child: Checkbox(
                              value: _allCurrentSelected,
                              onChanged: _toggleSelectAll,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              activeColor: const Color(0xFF5636F5),
                            ),
                          ),
                        ),
                      ),
                      // 2. # Index
                      const DataColumn(label: Text('#', style: _headerStyle)),
                      // 3. Question Details
                      DataColumn(
                        label: SizedBox(
                          width: detailsWidth,
                          child: const Text('Question Details', style: _headerStyle),
                        ),
                      ),
                      // 4. Subject
                      const DataColumn(label: Text('Subject', style: _headerStyle)),
                      // 5. Test Series
                      const DataColumn(label: Text('Test Series', style: _headerStyle)),
                      // 6. Type
                      const DataColumn(label: Text('Type', style: _headerStyle)),
                      // 7. Difficulty
                      const DataColumn(label: Text('Difficulty', style: _headerStyle)),
                      // 8. Correct Answer
                      const DataColumn(label: Text('Correct Answer', style: _headerStyle)),
                      // 9. Usage Count
                      const DataColumn(label: Text('Usage Count', style: _headerStyle)),
                      // 10. Status
                      const DataColumn(label: Text('Status', style: _headerStyle)),
                      // 11. Created On
                      const DataColumn(label: Text('Created On', style: _headerStyle)),
                      // 12. Actions
                      const DataColumn(label: Text('Actions', style: _headerStyle)),
                    ],
                    rows: widget.items.asMap().entries.map((entry) {
                      final item = entry.value;
                      final isSelected = _selectedIds.contains(item.id);

                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (isSelected) return const Color(0xFFF5F3FF);
                          return null;
                        }),
                        cells: [
                          // 1. Checkbox
                          DataCell(
                            SizedBox(
                              width: 20,
                              child: Transform.scale(
                                scale: 0.85,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (val) => _toggleSelectItem(item.id, val),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  activeColor: const Color(0xFF5636F5),
                                ),
                              ),
                            ),
                          ),
                          // 2. # Index
                          DataCell(
                            Text(
                              '${item.questionNumber}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          // 3. Question Details
                          DataCell(
                            SizedBox(
                              width: detailsWidth,
                              child: Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: item.iconContainerBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(item.subjectIcon, color: Colors.white, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.questionText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        height: 1.15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 4. Subject
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: item.subjectBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.subject,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: item.subjectTextColor,
                                ),
                              ),
                            ),
                          ),
                          // 5. Test Series
                          DataCell(
                            Text(
                              item.testSeriesTitle,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                                height: 1.15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 6. Type
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFDBEAFE), width: 0.8),
                              ),
                              child: Text(
                                item.questionType,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ),
                          // 7. Difficulty
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.difficultyBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.difficulty.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: item.difficultyTextColor,
                                ),
                              ),
                            ),
                          ),
                          // 8. Correct Answer
                          DataCell(
                            Center(
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: const Color(0xFFDBEAFE), width: 0.8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item.correctAnswerChar,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // 9. Usage Count
                          DataCell(
                            Text(
                              _formatNumber(item.usageCount),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          // 10. Status
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: item.statusBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.status.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: item.statusTextColor,
                                ),
                              ),
                            ),
                          ),
                          // 11. Created On
                          DataCell(
                            Text(
                              _formatDate(item.createdAt),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          // 12. Actions
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // View
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 15),
                                  color: const Color(0xFF64748B),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  tooltip: 'View Question',
                                  onPressed: () => widget.onView(item),
                                ),
                                // Edit
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 15),
                                  color: const Color(0xFF64748B),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  tooltip: 'Edit Question',
                                  onPressed: () => widget.onEdit(item),
                                ),
                                // Duplicate
                                IconButton(
                                  icon: const Icon(Icons.content_copy_rounded, size: 15),
                                  color: const Color(0xFF64748B),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  tooltip: 'Duplicate Question',
                                  onPressed: () => widget.onDuplicate(item),
                                ),
                                // More Dropdown
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded,
                                      size: 16, color: Color(0xFF64748B)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  tooltip: 'More actions',
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  onSelected: (val) {
                                    if (val == 'toggle_status') widget.onToggleStatus(item);
                                    if (val == 'view') widget.onView(item);
                                    if (val == 'edit') widget.onEdit(item);
                                    if (val == 'duplicate') widget.onDuplicate(item);
                                    if (val == 'delete') widget.onDelete(item);
                                  },
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      value: 'view',
                                      child: const Row(
                                        children: [
                                          Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF5636F5)),
                                          SizedBox(width: 8),
                                          Text('View Details', style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: const Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0284C7)),
                                          SizedBox(width: 8),
                                          Text('Edit Question', style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'duplicate',
                                      child: const Row(
                                        children: [
                                          Icon(Icons.copy_rounded, size: 16, color: Color(0xFFF59E0B)),
                                          SizedBox(width: 8),
                                          Text('Duplicate', style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle_status',
                                      child: Row(
                                        children: [
                                          Icon(
                                            item.status == QuestionStatus.published
                                                ? Icons.pause_circle_outline
                                                : Icons.play_circle_outline,
                                            size: 16,
                                            color: const Color(0xFF10B981),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.status == QuestionStatus.published
                                                ? 'Change to Draft'
                                                : 'Publish Question',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3. Table Footer: Showing text + Pagination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Showing 1 to ${widget.items.length} of ${_formatNumber(widget.totalCount)} questions',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Prev Chevron
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 18),
                        color: widget.currentPage > 1
                            ? const Color(0xFF101A3A)
                            : const Color(0xFFCBD5E1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        onPressed: widget.currentPage > 1
                            ? () => widget.onPageChanged(widget.currentPage - 1)
                            : null,
                      ),
                      const SizedBox(width: 4),

                      // Page Pill 1 (Active Purple in reference)
                      _buildPagePill(1),
                      _buildPagePill(2),
                      _buildPagePill(3),
                      _buildPagePill(4),
                      _buildPagePill(5),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('...', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ),

                      // Max Page 1,406
                      _buildPagePill(1406),

                      const SizedBox(width: 4),
                      // Next Chevron
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 18),
                        color: widget.currentPage < widget.totalPages
                            ? const Color(0xFF101A3A)
                            : const Color(0xFFCBD5E1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        onPressed: widget.currentPage < widget.totalPages
                            ? () => widget.onPageChanged(widget.currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagePill(int pageNumber) {
    final isActive = widget.currentPage == pageNumber;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => widget.onPageChanged(pageNumber),
        child: Container(
          width: pageNumber > 999 ? 38 : 26,
          height: 26,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF5636F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            pageNumber > 999 ? _formatNumber(pageNumber) : '$pageNumber',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: items.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildFiltersButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (widget.onOpenFilters != null) {
          widget.onOpenFilters!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Filter drawer opened with advanced criteria.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, size: 14, color: Color(0xFF64748B)),
            SizedBox(width: 4),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      final part1 = s.substring(0, len - 3);
      final part2 = s.substring(len - 3);
      return '$part1,$part2';
    }
    return n.toString();
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = months[dt.month - 1];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );
}
