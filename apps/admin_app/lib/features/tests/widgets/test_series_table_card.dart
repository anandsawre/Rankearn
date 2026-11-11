import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';

/// Test Series Table Card
/// Powered by the unified [AdminDataTableCard] from the Rankearn design system.
class TestSeriesTableCard extends StatefulWidget {
  final List<TestSeriesItem> items;
  final int totalCount;
  final String selectedSubject;
  final List<String> availableSubjects;
  final String selectedStatus;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onFiltersTap;
  final Function(TestSeriesItem) onView;
  final Function(TestSeriesItem) onAnalytics;
  final Function(TestSeriesItem) onEdit;
  final Function(TestSeriesItem) onDelete;
  final Function(TestSeriesItem) onToggleStatus;
  final Function(TestSeriesItem)? onAddQuestion;
  final Function(TestSeriesItem)? onViewQuestions;

  const TestSeriesTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.selectedSubject,
    this.availableSubjects = const [],
    required this.selectedStatus,
    required this.searchQuery,
    required this.currentPage,
    required this.totalPages,
    this.isLoading = false,
    required this.onSubjectChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onPageChanged,
    this.onFiltersTap,
    required this.onView,
    required this.onAnalytics,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    this.onAddQuestion,
    this.onViewQuestions,
  });

  @override
  State<TestSeriesTableCard> createState() => _TestSeriesTableCardState();
}

class _TestSeriesTableCardState extends State<TestSeriesTableCard> {
  final Set<String> _selectedIds = {};

  void _toggleSelectAll(bool? val) {
    setState(() {
      if (val == true) {
        _selectedIds.addAll(widget.items.map((i) => i.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = widget.items.isNotEmpty &&
        widget.items.every((i) => _selectedIds.contains(i.id));

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    final double detailsWidth = (cardWidth * 0.22).clamp(180.0, 360.0);
    const double fixedColumnsWidth = 24.0 + 22.0 + 85.0 + 60.0 + 75.0 + 55.0 + 75.0 + 75.0 + 80.0 + 110.0 + 32.0;
    final double remainingSpace = cardWidth - (fixedColumnsWidth + detailsWidth);
    final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 10).clamp(6.0, 48.0) : 6.0;

    final subjectDropdownItems = <String>{
      'All Subjects',
      ...widget.availableSubjects.where((s) => s.trim().isNotEmpty),
      ...widget.items.map((i) => i.subject.trim()).where((s) => s.isNotEmpty),
      widget.selectedSubject,
    }.toList();

    return AdminDataTableCard(
          title: 'Test Series List',
          totalCount: widget.totalCount,
          icon: Icons.format_list_bulleted_rounded,
          iconBgColor: const Color(0xFF2563EB),
          searchQuery: widget.searchQuery,
          searchHint: 'Search test series...',
          onSearchChanged: widget.onSearchChanged,
          currentPage: widget.currentPage,
          totalPages: widget.totalPages,
          onPageChanged: widget.onPageChanged,
          isLoading: widget.isLoading && widget.items.isEmpty,
          itemLabel: 'test series',
          columnSpacing: dynamicColumnSpacing,
          filterControls: [
            AdminTableDropdown(
              value: widget.selectedSubject,
              items: subjectDropdownItems,
              onChanged: widget.onSubjectChanged,
            ),
            AdminTableDropdown(
              value: widget.selectedStatus,
              items: const [
                'All Status',
                'Published',
                'Draft',
                'Archived',
              ],
              onChanged: widget.onStatusChanged,
            ),
            if (widget.onFiltersTap != null)
              AdminTableFiltersButton(
                onTap: widget.onFiltersTap!,
              ),
          ],
          columns: [
            DataColumn(
              label: SizedBox(
                width: 20,
                child: Checkbox(
                  value: allSelected,
                  onChanged: _toggleSelectAll,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  activeColor: AppColors.brandPurple,
                ),
              ),
            ),
            DataColumn(
              label: Text('#', style: _headerStyle),
            ),
            DataColumn(
              label: SizedBox(
                width: detailsWidth,
                child: Text('Test Series Details', style: _headerStyle),
              ),
            ),
            DataColumn(
              label: Text('• Subject', style: _headerStyle),
            ),
            DataColumn(
              label: Text('Total Tests', style: _headerStyle),
            ),
            DataColumn(
              label: Text('Total Questions', style: _headerStyle),
            ),
            DataColumn(
              label: Text('Price', style: _headerStyle),
            ),
            DataColumn(
              label: Text('• Enrollments', style: _headerStyle),
            ),
            DataColumn(
              label: Text('• Status', style: _headerStyle),
            ),
            DataColumn(
              label: Text('Created On', style: _headerStyle),
            ),
            DataColumn(
              label: Text('Actions', style: _headerStyle),
            ),
          ],
          rows: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final isSelected = _selectedIds.contains(item.id);

            return DataRow(
              selected: isSelected,
              onSelectChanged: (_) => _toggleItem(item.id),
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFF8FAFC);
                }
                if (isSelected) {
                  return const Color(0xFFEEF2FF);
                }
                return Colors.white;
              }),
              cells: [
                DataCell(
                  SizedBox(
                    width: 20,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleItem(item.id),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.brandPurple,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${index + 1}',
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: item.iconColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(item.icon, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(_buildSubjectBadge(item.subject)),
                DataCell(
                  Text(
                    '${item.totalTests}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  InkWell(
                    onTap: widget.onViewQuestions != null ? () => widget.onViewQuestions!(item) : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatNumber(item.totalQuestions),
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.onViewQuestions != null ? AppColors.brandPurple : AppColors.textPrimary,
                              decoration: widget.onViewQuestions != null ? TextDecoration.underline : null,
                              decorationColor: AppColors.brandPurple.withValues(alpha: 0.35),
                            ),
                          ),
                          if (widget.onViewQuestions != null) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.brandPurple),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '₹${item.priceInr}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _formatNumber(item.enrollments),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataCell(_buildStatusBadge(item.status)),
                DataCell(
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdminTableActionButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'View Details',
                        onTap: () => widget.onView(item),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.bar_chart_rounded,
                        tooltip: 'Analytics',
                        onTap: () => widget.onAnalytics(item),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Series',
                        onTap: () => widget.onEdit(item),
                      ),
                      if (widget.onViewQuestions != null) ...[
                        const SizedBox(width: 4),
                        AdminTableActionButton(
                          icon: Icons.format_list_bulleted_rounded,
                          tooltip: 'View Questions',
                          color: AppColors.brandBlue,
                          onTap: () => widget.onViewQuestions!(item),
                        ),
                      ],
                      if (widget.onAddQuestion != null) ...[
                        const SizedBox(width: 4),
                        AdminTableActionButton(
                          icon: Icons.post_add_rounded,
                          tooltip: 'Add Questions',
                          color: AppColors.brandPurple,
                          onTap: () => widget.onAddQuestion!(item),
                        ),
                      ],
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        onSelected: (val) {
                          if (val == 'view_questions') {
                            widget.onViewQuestions?.call(item);
                          } else if (val == 'add_question') {
                            widget.onAddQuestion?.call(item);
                          } else if (val == 'toggle_status') {
                            widget.onToggleStatus(item);
                          } else if (val == 'delete') {
                            widget.onDelete(item);
                          }
                        },
                        itemBuilder: (ctx) => [
                          if (widget.onViewQuestions != null)
                            PopupMenuItem(
                              value: 'view_questions',
                              child: Row(
                                children: [
                                  const Icon(Icons.format_list_bulleted_rounded, size: 14, color: AppColors.brandBlue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View Questions',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontHeading,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brandBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'add_question',
                            child: Row(
                              children: [
                                const Icon(Icons.post_add_rounded, size: 14, color: AppColors.brandPurple),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Questions',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontHeading,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle_status',
                            child: Text(
                              item.status == TestSeriesStatus.published ? 'Move to Draft' : 'Publish Now',
                              style: TextStyle(
                                fontFamily: AppTypography.fontHeading,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: AppTypography.fontHeading,
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        );
  }

  Widget _buildSubjectBadge(String subject) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    final lower = subject.toLowerCase();
    if (lower.contains('science')) {
      bg = const Color(0xFFEEF2FF);
      text = const Color(0xFF6366F1);
    } else if (lower.contains('math')) {
      bg = const Color(0xFFFFF1F2);
      text = const Color(0xFFF43F5E);
    } else if (lower.contains('reasoning')) {
      bg = const Color(0xFFF0F9FF);
      text = const Color(0xFF0284C7);
    } else if (lower.contains('current') || lower.contains('affairs')) {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFEA580C);
    } else if (lower.contains('chemistry')) {
      bg = const Color(0xFFFDF2F8);
      text = const Color(0xFFDB2777);
    } else if (lower.contains('biology')) {
      bg = const Color(0xFFF0FDF4);
      text = const Color(0xFF16A34A);
    }

    return AdminTableStatusBadge(
      label: subject,
      backgroundColor: bg,
      textColor: text,
    );
  }

  Widget _buildStatusBadge(TestSeriesStatus status) {
    final isPublished = status == TestSeriesStatus.published;
    final bg = isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF);
    final text = isPublished ? const Color(0xFF16A34A) : const Color(0xFF3B82F6);

    return AdminTableStatusBadge(
      label: status.label,
      backgroundColor: bg,
      textColor: text,
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
