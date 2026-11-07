import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';

/// Questions Table Card
/// Powered by the unified [AdminDataTableCard] from the Rankearn design system.
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
  final Set<String> _selectedIds = {};

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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    final double detailsWidth = (cardWidth * 0.20).clamp(160.0, 320.0);
    const double fixedColumnsWidth =
        24.0 + 22.0 + 85.0 + 100.0 + 55.0 + 65.0 + 60.0 + 65.0 + 65.0 + 75.0 + 110.0 + 32.0;
    final double remainingSpace = cardWidth - (fixedColumnsWidth + detailsWidth);
    final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 11).clamp(6.0, 40.0) : 6.0;

    return AdminDataTableCard(
          title: 'Questions List',
          totalCount: widget.totalCount,
          icon: Icons.description_rounded,
          iconBgColor: const Color(0xFF2563EB),
          searchQuery: widget.searchQuery,
          searchHint: 'Search questions...',
          onSearchChanged: widget.onSearchChanged,
          currentPage: widget.currentPage,
          totalPages: widget.totalPages,
          onPageChanged: widget.onPageChanged,
          itemLabel: 'questions',
          columnSpacing: dynamicColumnSpacing,
          filterControls: [
            AdminTableDropdown(
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
            AdminTableDropdown(
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
            AdminTableDropdown(
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
            AdminTableDropdown(
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
            AdminTableFiltersButton(
              onTap: widget.onOpenFilters ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Filter drawer opened with advanced criteria.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            ),
          ],
          columns: [
            DataColumn(
              label: SizedBox(
                width: 20,
                child: Checkbox(
                  value: _allCurrentSelected,
                  onChanged: _toggleSelectAll,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  activeColor: AppColors.brandPurple,
                ),
              ),
            ),
            DataColumn(label: Text('#', style: _headerStyle)),
            DataColumn(
              label: SizedBox(
                width: detailsWidth,
                child: Text('Question Details', style: _headerStyle),
              ),
            ),
            DataColumn(label: Text('Subject', style: _headerStyle)),
            DataColumn(label: Text('Test Series', style: _headerStyle)),
            DataColumn(label: Text('Type', style: _headerStyle)),
            DataColumn(label: Text('Difficulty', style: _headerStyle)),
            DataColumn(label: Text('Correct Answer', style: _headerStyle)),
            DataColumn(label: Text('Usage Count', style: _headerStyle)),
            DataColumn(label: Text('Status', style: _headerStyle)),
            DataColumn(label: Text('Created On', style: _headerStyle)),
            DataColumn(label: Text('Actions', style: _headerStyle)),
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
                DataCell(
                  SizedBox(
                    width: 20,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (val) => _toggleSelectItem(item.id, val),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.brandPurple,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${item.questionNumber}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
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
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
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
                DataCell(
                  AdminTableStatusBadge(
                    label: item.subject,
                    backgroundColor: item.subjectBgColor,
                    textColor: item.subjectTextColor,
                  ),
                ),
                DataCell(
                  Text(
                    item.testSeriesTitle,
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  AdminTableStatusBadge(
                    label: item.questionType,
                    backgroundColor: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFDBEAFE),
                    textColor: const Color(0xFF2563EB),
                  ),
                ),
                DataCell(
                  AdminTableStatusBadge(
                    label: item.difficulty.label,
                    backgroundColor: item.difficultyBgColor,
                    textColor: item.difficultyTextColor,
                  ),
                ),
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
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _formatNumber(item.usageCount),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  AdminTableStatusBadge(
                    label: item.status.label,
                    backgroundColor: item.statusBgColor,
                    textColor: item.statusTextColor,
                  ),
                ),
                DataCell(
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdminTableActionButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'View Question',
                        onTap: () => widget.onView(item),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Question',
                        onTap: () => widget.onEdit(item),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.content_copy_rounded,
                        tooltip: 'Duplicate Question',
                        onTap: () => widget.onDuplicate(item),
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        tooltip: 'More actions',
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            child: Row(
                              children: [
                                const Icon(Icons.visibility_outlined, size: 16, color: AppColors.brandPurple),
                                const SizedBox(width: 8),
                                Text(
                                  'View Details',
                                  style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0284C7)),
                                const SizedBox(width: 8),
                                Text(
                                  'Edit Question',
                                  style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                const Icon(Icons.copy_rounded, size: 16, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 8),
                                Text(
                                  'Duplicate',
                                  style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                                ),
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
                                  color: AppColors.brandGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.status == QuestionStatus.published
                                      ? 'Change to Draft'
                                      : 'Publish Question',
                                  style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontHeading,
                                    fontSize: 12,
                                    color: Colors.red,
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
            );
          }).toList(),
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }

  static TextStyle get _headerStyle => TextStyle(
        fontFamily: AppTypography.fontHeading,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );
}
