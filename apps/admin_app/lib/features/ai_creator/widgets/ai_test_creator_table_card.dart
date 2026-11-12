import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';

/// AI Test Creator Table Card powered by the unified [AdminDataTableCard] from the design system.
class AiTestCreatorTableCard extends StatefulWidget {
  final List<AiGeneratedTestItem> items;
  final int totalCount;
  final int currentPage;
  final int rowsPerPage;
  final String searchQuery;
  final String selectedSubject;
  final String selectedDifficulty;
  final String selectedStatus;
  final DateTimeRange? dateRange;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onDifficultyChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<AiGeneratedTestItem> onViewTest;
  final ValueChanged<AiGeneratedTestItem> onAnalyticsTest;
  final ValueChanged<AiGeneratedTestItem> onEditTest;
  final ValueChanged<AiGeneratedTestItem> onDeleteTest;
  final VoidCallback? onFiltersTap;
  final bool isLoading;

  const AiTestCreatorTableCard({
    super.key,
    required this.items,
    this.totalCount = 0,
    this.isLoading = false,
    this.currentPage = 1,
    this.rowsPerPage = 10,
    this.searchQuery = '',
    this.selectedSubject = 'All Subjects',
    this.selectedDifficulty = 'All Difficulty',
    this.selectedStatus = 'All Status',
    this.dateRange,
    required this.onSearchChanged,
    required this.onSubjectChanged,
    required this.onDifficultyChanged,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.onViewTest,
    required this.onAnalyticsTest,
    required this.onEditTest,
    required this.onDeleteTest,
    this.onFiltersTap,
  });

  @override
  State<AiTestCreatorTableCard> createState() => _AiTestCreatorTableCardState();
}

class _AiTestCreatorTableCardState extends State<AiTestCreatorTableCard>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedIds = {};
  late final AnimationController _pulseController;

  static const List<String> _subjectOptions = [
    'All Subjects',
    'General Science',
    'Mathematics',
    'Reasoning',
    'Current Affairs',
    'Chemistry',
    'Biology',
    'Mixed',
  ];

  static const List<String> _difficultyOptions = [
    'All Difficulty',
    'Easy',
    'Medium',
    'Hard',
  ];

  static const List<String> _statusOptions = [
    'All Status',
    'Ready',
    'Processing',
    'Draft',
    'Saved',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isAllSelected =>
      widget.items.isNotEmpty && _selectedIds.length == widget.items.length;

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(widget.items.map((e) => e.id));
      }
    });
  }

  void _toggleRow(String id) {
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
    final totalPages = (widget.totalCount / widget.rowsPerPage).ceil();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    final double detailsWidth = (cardWidth * 0.22).clamp(180.0, 340.0);

    return AdminDataTableCard(
      title: 'AI Generated Tests',
      totalCount: widget.totalCount,
      icon: Icons.auto_awesome_rounded,
      iconBgColor: AppColors.brandBlue,
      searchQuery: widget.searchQuery,
      searchHint: 'Search tests by title, description...',
      onSearchChanged: widget.onSearchChanged,
      currentPage: widget.currentPage,
      totalPages: totalPages > 0 ? totalPages : 1,
      rowsPerPage: widget.rowsPerPage,
      onPageChanged: widget.onPageChanged,
      onRowsPerPageChanged: widget.onRowsPerPageChanged,
      itemLabel: 'tests',
      isLoading: widget.isLoading,
      filterControls: [
        AdminTableDropdown(
          value: widget.selectedSubject,
          items: _subjectOptions,
          onChanged: widget.onSubjectChanged,
        ),
        AdminTableDropdown(
          value: widget.selectedDifficulty,
          items: _difficultyOptions,
          onChanged: widget.onDifficultyChanged,
        ),
        AdminTableDropdown(
          value: widget.selectedStatus,
          items: _statusOptions,
          onChanged: widget.onStatusChanged,
        ),
        AdminTableDateRangeButton(
          dateRange: widget.dateRange,
          onDateRangeChanged: widget.onDateRangeChanged,
        ),
        AdminTableFiltersButton(
          onTap: widget.onFiltersTap ?? () {},
        ),
      ],
      columns: [
        DataColumn(
          label: SizedBox(
            width: 24,
            child: Checkbox(
              value: _isAllSelected,
              onChanged: (val) => _toggleSelectAll(),
              activeColor: AppColors.brandPurple,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            '#',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: detailsWidth,
            child: Text(
              'Test Details',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Subject',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Difficulty',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Questions',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Time',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Status',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Created On',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Created By',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Actions',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
      rows: widget.items.map((item) {
        final isSelected = _selectedIds.contains(item.id);

        return DataRow(
          selected: isSelected,
          onSelectChanged: (val) => _toggleRow(item.id),
          cells: [
            DataCell(
              SizedBox(
                width: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (val) => _toggleRow(item.id),
                  activeColor: AppColors.brandPurple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            DataCell(
              Text(
                item.rowNumber.toString(),
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: detailsWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, color: item.iconColor, size: 17),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 10,
                              color: AppColors.textMuted,
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
            DataCell(
              AdminTableStatusBadge(
                label: item.subject.label,
                backgroundColor: item.subject.backgroundColor,
                textColor: item.subject.color,
              ),
            ),
            DataCell(
              AdminTableStatusBadge(
                label: item.difficulty.label,
                backgroundColor: item.difficulty.backgroundColor,
                textColor: item.difficulty.color,
              ),
            ),
            DataCell(
              Text(
                item.questionCount.toString(),
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataCell(
              Text(
                '${item.durationMinutes} min',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataCell(
              AdminTableStatusBadge(
                label: item.status.label,
                backgroundColor: item.status.backgroundColor,
                textColor: item.status.color,
                isLive: item.status == AiTestStatus.processing,
              ),
            ),
            DataCell(
              Text(
                _formatShortDate(item.createdOn),
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.brandPurple,
                    child: const Text(
                      'A',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.createdBy,
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'Preview Test Questions',
                    onTap: () => widget.onViewTest(item),
                  ),
                  const SizedBox(width: 2),
                  AdminTableActionButton(
                    icon: Icons.bar_chart_rounded,
                    tooltip: 'Test Analytics',
                    onTap: () => widget.onAnalyticsTest(item),
                  ),
                  const SizedBox(width: 2),
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit Test',
                    onTap: () => widget.onEditTest(item),
                  ),
                  const SizedBox(width: 2),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    onSelected: (val) {
                      if (val == 'delete') widget.onDeleteTest(item);
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete Test',
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
      }).toList(),
    );
  }

  static String _formatShortDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
