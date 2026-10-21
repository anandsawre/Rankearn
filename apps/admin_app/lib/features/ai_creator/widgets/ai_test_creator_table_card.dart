import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';

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

  const AiTestCreatorTableCard({
    super.key,
    required this.items,
    this.totalCount = 124,
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
  late final TextEditingController _searchController;
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
    'Published',
    'Draft',
    'Processing',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AiTestCreatorTableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Toolbar
          _buildToolbar(context),
          const SizedBox(height: 12),

          // Bulk action banner if items selected
          if (_selectedIds.isNotEmpty) ...[
            _buildBulkActionBar(),
            const SizedBox(height: 10),
          ],

          // 2. Data Table with zero horizontal overflow on wide screens
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              final tableMinWidth = cardWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinWidth),
                  child: DataTable(
                    showCheckboxColumn: false,
                    horizontalMargin: 8,
                    columnSpacing: 8,
                    dataRowMinHeight: 58,
                    dataRowMaxHeight: 58,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: _buildColumns(),
                    rows: _buildRows(context),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // 3. Footer Pagination
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;

    final headerTitle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF2587F8),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AI Generated Tests (${_formatNumber(widget.totalCount)})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101A3A),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        // Search Input
        SizedBox(
          width: isCompact ? 140 : 165,
          height: 32,
          child: TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search tests...',
              hintStyle: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 14, color: AppColors.textSecondary),
              prefixIconConstraints: const BoxConstraints(minWidth: 26),
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.2),
              ),
            ),
          ),
        ),

        // Subject Filter Dropdown
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _subjectOptions.contains(widget.selectedSubject)
                  ? widget.selectedSubject
                  : _subjectOptions.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) widget.onSubjectChanged(val);
              },
              items: _subjectOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
            ),
          ),
        ),

        // Difficulty Filter Dropdown
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _difficultyOptions.contains(widget.selectedDifficulty)
                  ? widget.selectedDifficulty
                  : _difficultyOptions.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) widget.onDifficultyChanged(val);
              },
              items: _difficultyOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
            ),
          ),
        ),

        // Status Filter Dropdown
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusOptions.contains(widget.selectedStatus)
                  ? widget.selectedStatus
                  : _statusOptions.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) widget.onStatusChanged(val);
              },
              items: _statusOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
            ),
          ),
        ),

        // Date Range Picker
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final res = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 1),
              initialDateRange: widget.dateRange ??
                  DateTimeRange(
                    start: DateTime(2026, 10, 1),
                    end: DateTime(2026, 10, 31),
                  ),
            );
            if (res != null) {
              widget.onDateRangeChanged(res);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  widget.dateRange != null
                      ? '${_formatShortDate(widget.dateRange!.start)} - ${_formatShortDate(widget.dateRange!.end)}'
                      : 'Oct 1, 2026 - Oct 31, 2026',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                if (widget.dateRange != null)
                  InkWell(
                    onTap: () => widget.onDateRangeChanged(null),
                    child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                  )
                else
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        // Filters Button
        InkWell(
          onTap: widget.onFiltersTap ?? () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 12, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  'Filters',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle,
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: controls,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerTitle,
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: controls,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIds.length} test(s) selected',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4338CA),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exporting ${_selectedIds.length} tests...')),
              );
            },
            icon: const Icon(Icons.file_download_outlined, size: 16),
            label: const Text('Export Selected'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5636F5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Publishing ${_selectedIds.length} tests...')),
              );
            },
            icon: const Icon(Icons.publish_rounded, size: 16),
            label: const Text('Publish Selected'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      // 1. Checkbox
      DataColumn(
        label: SizedBox(
          width: 24,
          child: Checkbox(
            value: _isAllSelected,
            onChanged: (val) => _toggleSelectAll(),
            activeColor: const Color(0xFF5636F5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),

      // 2. Row #
      const DataColumn(
        label: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 3. Test Details
      const DataColumn(
        label: Text('Test Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 4. Subject
      const DataColumn(
        label: Text('Subject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 5. Difficulty
      const DataColumn(
        label: Text('Difficulty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 6. Questions
      const DataColumn(
        label: Text('Questions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 7. Time
      const DataColumn(
        label: Text('Time', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 8. Status
      const DataColumn(
        label: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 9. Created On
      const DataColumn(
        label: Text('Created On', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 10. Created By
      const DataColumn(
        label: Text('Created By', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),

      // 11. Actions
      const DataColumn(
        label: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ),
    ];
  }

  List<DataRow> _buildRows(BuildContext context) {
    if (widget.items.isEmpty) {
      return [
        DataRow(
          cells: [
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
            DataCell(
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text('No AI generated tests match your filter criteria.', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
            const DataCell(SizedBox()),
          ],
        ),
      ];
    }

    return widget.items.map((item) {
      final isSelected = _selectedIds.contains(item.id);

      return DataRow(
        selected: isSelected,
        onSelectChanged: (val) => _toggleRow(item.id),
        cells: [
          // 1. Checkbox
          DataCell(
            SizedBox(
              width: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (val) => _toggleRow(item.id),
                activeColor: const Color(0xFF5636F5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // 2. Row #
          DataCell(
            Text(
              item.rowNumber.toString(),
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),

          // 3. Test Details (Icon Container + Title + Subtitle)
          DataCell(
            Row(
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101A3A),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.subtitle,
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. Subject Badge
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: item.subject.backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: item.subject.color.withAlpha(50), width: 0.8),
              ),
              child: Text(
                item.subject.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: item.subject.color,
                ),
              ),
            ),
          ),

          // 5. Difficulty Badge
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: item.difficulty.backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: item.difficulty.color.withAlpha(50), width: 0.8),
              ),
              child: Text(
                item.difficulty.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: item.difficulty.color,
                ),
              ),
            ),
          ),

          // 6. Questions
          DataCell(
            Text(
              item.questionCount.toString(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // 7. Time
          DataCell(
            Text(
              '${item.durationMinutes} min',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // 8. Status Badge (with pulsing dot for Processing)
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: item.status.backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: item.status.color.withAlpha(50), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.status == AiTestStatus.processing) ...[
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.status.color.withValues(alpha: 0.4 + 0.6 * _pulseController.value),
                          ),
                        );
                      },
                    ),
                  ],
                  Text(
                    item.status.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: item.status.color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 9. Created On
          DataCell(
            Text(
              _formatShortDate(item.createdOn),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),

          // 10. Created By (Avatar + Name)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: const Color(0xFF5636F5),
                  child: const Text(
                    'A',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.createdBy,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          // 11. Actions (View [eye], Analytics [bar chart], Edit [pencil], More [dots])
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View action
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF64748B)),
                  tooltip: 'Preview Test Questions',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () => widget.onViewTest(item),
                ),
                const SizedBox(width: 2),

                // Analytics action
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF64748B)),
                  tooltip: 'Test Analytics',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () => widget.onAnalyticsTest(item),
                ),
                const SizedBox(width: 2),

                // Edit action
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                  tooltip: 'Edit Test',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () => widget.onEditTest(item),
                ),
                const SizedBox(width: 2),

                // More Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF64748B)),
                  tooltip: 'More Options',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onSelected: (val) {
                    if (val == 'view') {
                      widget.onViewTest(item);
                    } else if (val == 'analytics') {
                      widget.onAnalyticsTest(item);
                    } else if (val == 'edit') {
                      widget.onEditTest(item);
                    } else if (val == 'delete') {
                      widget.onDeleteTest(item);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 15, color: Color(0xFF5636F5)),
                          SizedBox(width: 8),
                          Text('View & Review Questions', style: TextStyle(fontSize: 11.5)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'analytics',
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 15, color: Color(0xFF2587F8)),
                          SizedBox(width: 8),
                          Text('View Analytics', style: TextStyle(fontSize: 11.5)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 15, color: Color(0xFFFF9F0A)),
                          SizedBox(width: 8),
                          Text('Edit Parameters', style: TextStyle(fontSize: 11.5)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 8),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFF43F5E)),
                          SizedBox(width: 8),
                          Text('Delete Test', style: TextStyle(fontSize: 11.5, color: Color(0xFFF43F5E))),
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
    }).toList();
  }

  Widget _buildFooter() {
    final startItem = widget.items.isEmpty ? 0 : (widget.currentPage - 1) * widget.rowsPerPage + 1;
    final endItem = math.min(widget.currentPage * widget.rowsPerPage, widget.totalCount);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        // Left: Showing X to Y of Z tests
        Text(
          'Showing $startItem to $endItem of ${_formatNumber(widget.totalCount)} tests',
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),

        // Center: Pagination Buttons (< 1 2 3 4 5 ... 18 >)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 16),
              onPressed: widget.currentPage > 1
                  ? () => widget.onPageChanged(widget.currentPage - 1)
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            const SizedBox(width: 2),

            // Pages (1, 2, 3, 4, 5 ... 18)
            ..._buildPaginationNumbers(),

            const SizedBox(width: 2),
            // Next
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 16),
              onPressed: widget.currentPage < 18
                  ? () => widget.onPageChanged(widget.currentPage + 1)
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),

        // Right: Show 10 per page
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Show ', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: widget.rowsPerPage,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  onChanged: (val) {
                    if (val != null) widget.onRowsPerPageChanged(val);
                  },
                  items: [5, 10, 20, 50]
                      .map((n) => DropdownMenuItem(value: n, child: Text(n.toString())))
                      .toList(),
                ),
              ),
            ),
            const Text(' per page', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPaginationNumbers() {
    final widgets = <Widget>[];
    final pages = [1, 2, 3, 4, 5];

    for (final p in pages) {
      final isCurrent = p == widget.currentPage;
      widgets.add(
        InkWell(
          onTap: () => widget.onPageChanged(p),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF5636F5) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              p.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(width: 2));
    }

    // Ellipsis ...
    widgets.add(
      const Text('...', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
    );
    widgets.add(const SizedBox(width: 2));

    // Page 18
    const lastPage = 18;
    final isLastCurrent = lastPage == widget.currentPage;
    widgets.add(
      InkWell(
        onTap: () => widget.onPageChanged(lastPage),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isLastCurrent ? const Color(0xFF5636F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            lastPage.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isLastCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isLastCurrent ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );

    return widgets;
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

  static String _formatShortDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }
}
