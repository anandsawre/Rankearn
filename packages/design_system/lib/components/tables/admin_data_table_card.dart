import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';
import '../inputs/app_dropdown.dart';
import '../inputs/app_date_range_picker.dart';

/// Reusable centralized Admin Data Table Card component.
///
/// Provides a unified header (title with icon, search input, customizable filter controls),
/// a horizontally responsive data table, and a pagination footer matching Rankearn design specifications.
class AdminDataTableCard extends StatelessWidget {
  /// Card header title (e.g. "Live Quiz List", "Test Series List").
  final String title;

  /// Total count of items, displayed beside title as `(totalCount)`.
  final int totalCount;

  /// Header left icon (e.g. `Icons.podcasts_rounded`, `Icons.description_rounded`).
  final IconData? icon;

  /// Background color of the header icon container (defaults to `AppColors.brandBlue`).
  final Color? iconBgColor;

  /// Icon color inside the header icon container (defaults to `Colors.white`).
  final Color iconColor;

  /// Controller for search input field.
  final TextEditingController? searchController;

  /// Current search query string.
  final String? searchQuery;

  /// Placeholder hint text for search input.
  final String searchHint;

  /// Callback when search query changes.
  final ValueChanged<String>? onSearchChanged;

  /// Custom filter controls (e.g. status dropdown, category dropdown, date range picker, filters button).
  final List<Widget>? filterControls;

  /// Additional action buttons on the header right (e.g. "+ Add New" button).
  final List<Widget>? headerActions;

  /// Table columns (defaults to empty when [customBody] is provided).
  final List<DataColumn> columns;

  /// Table rows (defaults to empty when [customBody] is provided).
  final List<DataRow> rows;

  /// Optional custom body to replace the DataTable (e.g. for Grid View or custom card lists).
  final Widget? customBody;

  /// Minimum width of the table before horizontal scrolling activates (defaults to 860.0).
  final double minWidth;

  /// Column spacing in DataTable. If null, spacing dynamically adjusts to fill width.
  final double? columnSpacing;

  /// Current page number (1-based).
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  /// Number of rows displayed per page.
  final int rowsPerPage;

  /// Available options for rows per page.
  final List<int> rowsPerPageOptions;

  /// Callback when page changes.
  final ValueChanged<int>? onPageChanged;

  /// Callback when rows per page changes.
  final ValueChanged<int>? onRowsPerPageChanged;

  /// Plural noun for items (e.g. "live quizzes", "test series", "questions").
  final String itemLabel;

  /// Custom empty state widget when `rows` is empty.
  final Widget? emptyWidget;

  /// Alias for [emptyWidget].
  final Widget? emptyState;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Whether to display date range filter button in header controls.
  final bool showDateRange;

  /// Label text for date range button.
  final String? dateRangeText;

  /// Callback when date range button is tapped.
  final VoidCallback? onDateRangeTap;

  /// Whether to display "Filters" popup button in header controls.
  final bool showFiltersButton;

  /// Callback when "Filters" button is tapped.
  final VoidCallback? onFiltersTap;

  const AdminDataTableCard({
    super.key,
    required this.title,
    required this.totalCount,
    this.icon,
    this.iconBgColor,
    this.iconColor = Colors.white,
    this.searchController,
    this.searchQuery,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.filterControls,
    this.headerActions,
    this.columns = const [],
    this.rows = const [],
    this.customBody,
    this.minWidth = 860.0,
    this.columnSpacing,
    this.currentPage = 1,
    this.totalPages = 1,
    this.rowsPerPage = 10,
    this.rowsPerPageOptions = const [5, 10, 20, 50],
    this.onPageChanged,
    this.onRowsPerPageChanged,
    this.itemLabel = 'items',
    this.emptyWidget,
    this.emptyState,
    this.isLoading = false,
    this.showDateRange = false,
    this.dateRangeText,
    this.onDateRangeTap,
    this.showFiltersButton = false,
    this.onFiltersTap,
  });

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
          // ── 1. Header Controls Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 640;
                final isTablet = constraints.maxWidth >= 640 && constraints.maxWidth < 1050;

                final titleWidget = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: iconBgColor ?? AppColors.brandBlue,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        '$title ($totalCount)',
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );

                final searchWidget = onSearchChanged != null
                    ? AdminTableSearchField(
                        controller: searchController,
                        initialQuery: searchQuery,
                        hintText: searchHint,
                        onChanged: onSearchChanged!,
                        width: isMobile ? double.infinity : 220,
                      )
                    : null;

                final secondaryControls = <Widget>[
                  ...?filterControls,
                  if (showDateRange && onDateRangeTap != null)
                    AdminTableDateRangeButton(
                      text: dateRangeText ?? 'Select Date Range',
                      onTap: onDateRangeTap!,
                    ),
                  if (showFiltersButton)
                    AdminTableFiltersButton(
                      onTap: onFiltersTap ?? () {},
                    ),
                ];

                // ── Mobile Layout (< 640px) ──
                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleWidget),
                          if (headerActions != null && headerActions!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < headerActions!.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  headerActions![i],
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                      if (searchWidget != null) ...[
                        const SizedBox(height: 10),
                        searchWidget,
                      ],
                      if (secondaryControls.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < secondaryControls.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                secondaryControls[i],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                }

                // ── Tablet Layout (640px - 1050px) ──
                if (isTablet) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleWidget),
                          if (headerActions != null && headerActions!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < headerActions!.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  headerActions![i],
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (searchWidget != null) ...[
                            searchWidget,
                            const SizedBox(width: 8),
                          ],
                          if (secondaryControls.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int i = 0; i < secondaryControls.length; i++) ...[
                                      if (i > 0) const SizedBox(width: 8),
                                      secondaryControls[i],
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                }

                // ── Desktop Wide Layout (>= 1050px) ──
                final allControls = <Widget>[
                  ?searchWidget,
                  ...secondaryControls,
                  ...?headerActions,
                ];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      titleWidget,
                      if (allControls.isNotEmpty) const SizedBox(width: 16),
                      for (int i = 0; i < allControls.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        allControls[i],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // ── 2. Data Table / Custom Body ──
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPurple),
                ),
              ),
            )
          else if (customBody != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: customBody!,
            )
          else if (rows.isEmpty)
            emptyWidget ??
                emptyState ??
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 40, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'No $itemLabel found',
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final effectiveMinWidth = math.max(minWidth, availableWidth);

                final effectiveColumnSpacing = columnSpacing ??
                    () {
                      if (columns.length <= 1) return 16.0;
                      final double estimatedContentWidth =
                          (columns.length - 1) * 72.0 + 190.0 + 32.0;
                      final double freeSpace = availableWidth - estimatedContentWidth;
                      final int gaps = columns.length - 1;
                      if (freeSpace > 0 && gaps > 0) {
                        return (freeSpace / gaps).clamp(16.0, 96.0);
                      }
                      return 16.0;
                    }();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: effectiveMinWidth),
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 58,
                      horizontalMargin: 16,
                      columnSpacing: effectiveColumnSpacing,
                      headingRowColor:
                          WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      showCheckboxColumn: false,
                      columns: columns,
                      rows: rows,
                    ),
                  ),
                );
              },
            ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // ── 3. Table Pagination Footer ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 750;
                final isVeryNarrow = constraints.maxWidth < 480;
                final startIdx = totalCount == 0 ? 0 : (currentPage - 1) * rowsPerPage + 1;
                final endIdx = math.min(currentPage * rowsPerPage, totalCount);

                final infoText = Text(
                  'Showing $startIdx to $endIdx of $totalCount $itemLabel',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                );

                final pageControls = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPageNavBtn(
                      icon: Icons.chevron_left_rounded,
                      isEnabled: currentPage > 1,
                      onTap: onPageChanged != null && currentPage > 1
                          ? () => onPageChanged!(currentPage - 1)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    ..._buildPageNumbers(),
                    const SizedBox(width: 4),
                    _buildPageNavBtn(
                      icon: Icons.chevron_right_rounded,
                      isEnabled: currentPage < totalPages,
                      onTap: onPageChanged != null && currentPage < totalPages
                          ? () => onPageChanged!(currentPage + 1)
                          : null,
                    ),
                  ],
                );

                final pageSizeSelector = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Show',
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: AppRadii.borderSm,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: rowsPerPageOptions.contains(rowsPerPage)
                              ? rowsPerPage
                              : rowsPerPageOptions.first,
                          isDense: true,
                          dropdownColor: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 4,
                          items: rowsPerPageOptions.map((opt) {
                            final isSel = opt == rowsPerPage;
                            return DropdownMenuItem<int>(
                              value: opt,
                              child: Text(
                                '$opt',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
                                  fontSize: 11,
                                  fontWeight:
                                      isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel
                                      ? AppColors.brandPurple
                                      : AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: onRowsPerPageChanged != null
                              ? (val) {
                                  if (val != null) onRowsPerPageChanged!(val);
                                }
                              : null,
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'per page',
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                );

                if (isVeryNarrow) {
                  return Column(
                    children: [
                      infoText,
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: pageControls,
                      ),
                      const SizedBox(height: 8),
                      pageSizeSelector,
                    ],
                  );
                }

                if (isNarrow) {
                  return Column(
                    children: [
                      infoText,
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          pageControls,
                          pageSizeSelector,
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    infoText,
                    pageControls,
                    pageSizeSelector,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNavBtn({
    required IconData icon,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 15,
          color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final total = totalPages <= 0 ? 1 : totalPages;
    final widgets = <Widget>[];

    if (total <= 5) {
      for (int p = 1; p <= total; p++) {
        widgets.add(_buildPageNumberBtn(p, isSelected: currentPage == p));
        if (p < total) widgets.add(const SizedBox(width: 3));
      }
    } else {
      final int start;
      final int end;
      if (currentPage <= 3) {
        start = 1;
        end = 4;
      } else if (currentPage >= total - 2) {
        start = total - 3;
        end = total;
      } else {
        start = currentPage - 1;
        end = currentPage + 1;
      }

      if (start > 1) {
        widgets.add(_buildPageNumberBtn(1, isSelected: currentPage == 1));
        widgets.add(const SizedBox(width: 3));
        if (start > 2) {
          widgets.add(Text(
            '...',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ));
          widgets.add(const SizedBox(width: 3));
        }
      }

      for (int p = start; p <= end; p++) {
        widgets.add(_buildPageNumberBtn(p, isSelected: currentPage == p));
        if (p < end) widgets.add(const SizedBox(width: 3));
      }

      if (end < total) {
        widgets.add(const SizedBox(width: 3));
        if (end < total - 1) {
          widgets.add(Text(
            '...',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ));
          widgets.add(const SizedBox(width: 3));
        }
        widgets.add(_buildPageNumberBtn(total, isSelected: currentPage == total));
      }
    }

    return widgets;
  }

  Widget _buildPageNumberBtn(int page, {required bool isSelected}) {
    return InkWell(
      onTap: onPageChanged != null ? () => onPageChanged!(page) : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPurple : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.brandPurple : AppColors.borderSubtle,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Table Sub-Components & Controls
// ─────────────────────────────────────────────────────────────────────────────

/// Stylized Search Input Field for Table Header.
class AdminTableSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialQuery;
  final String hintText;
  final ValueChanged<String> onChanged;
  final double? width;
  final double height;

  const AdminTableSearchField({
    super.key,
    this.controller,
    this.initialQuery,
    this.hintText = 'Search...',
    required this.onChanged,
    this.width = 210,
    this.height = 32,
  });

  @override
  State<AdminTableSearchField> createState() => _AdminTableSearchFieldState();
}

class _AdminTableSearchFieldState extends State<AdminTableSearchField> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant AdminTableSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != null && widget.initialQuery != _internalController.text) {
      _internalController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextField(
        controller: _internalController,
        onChanged: (val) {
          widget.onChanged(val);
          setState(() {});
        },
        style: TextStyle(
          fontFamily: AppTypography.fontHeading,
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 10.5,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 15,
            color: AppColors.textMuted,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 28),
          suffixIcon: _internalController.text.isNotEmpty
              ? InkWell(
                  onTap: () {
                    _internalController.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 26, minHeight: 26),
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
            borderSide: const BorderSide(color: AppColors.brandPurple, width: 1.2),
          ),
        ),
      ),
    );
  }
}

/// Stylized Filter Dropdown Button for Table Header powered by Design System [AppDropdown].
class AdminTableDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T item)? itemLabel;
  final Widget? prefixIcon;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const AdminTableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
    this.prefixIcon,
    this.height = 34.0,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : value);

    final calculatedWidth = width ??
        () {
          int maxLen = 0;
          for (final i in items) {
            final label = itemLabel != null ? itemLabel!(i) : i.toString();
            if (label.length > maxLen) maxLen = label.length;
          }
          return (maxLen * 7.5 + 48.0).clamp(120.0, 200.0);
        }();

    return SizedBox(
      width: calculatedWidth,
      child: AppDropdown<T>(
        value: effectiveValue,
        height: height,
        fillColor: backgroundColor ?? const Color(0xFFF8FAFC),
        borderColor: borderColor ?? AppColors.borderSubtle,
        focusedBorderColor: AppColors.brandPrimary,
        selectedItemColor: AppColors.brandPrimary,
        selectedItemBackgroundColor: const Color(0xFFECFDF5),
        borderRadius: borderRadius ?? AppRadii.borderSm,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        style: TextStyle(
          fontFamily: AppTypography.fontHeading,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        prefixIcon: prefixIcon,
        items: items.map((item) {
          final label = itemLabel != null ? itemLabel!(item) : item.toString();
          return AppDropdownItem<T>(
            value: item,
            label: label,
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }
}

/// Stylized Date Range Picker Button for Table Header.
class AdminTableDateRangeButton extends StatelessWidget {
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final VoidCallback? onTap;
  final String placeholder;
  final String? text;

  const AdminTableDateRangeButton({
    super.key,
    this.dateRange,
    this.onDateRangeChanged,
    this.onTap,
    this.placeholder = 'Select Date Range',
    this.text,
  });

  String _formatMonthDay(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final label = text ??
        (dateRange != null
            ? '${_formatMonthDay(dateRange!.start)} - ${_formatMonthDay(dateRange!.end)}'
            : placeholder);

    return InkWell(
      onTap: onTap ??
          () async {
            if (onDateRangeChanged == null) return;
            final picked = await AppDateRangePicker.show(
              context: context,
              initialDateRange: dateRange,
            );
            if (picked != null) {
              onDateRangeChanged!(picked);
            }
          },
      borderRadius: AppRadii.borderSm,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: AppRadii.borderSm,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Stylized "Filters" button for Table Header.
class AdminTableFiltersButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;

  const AdminTableFiltersButton({
    super.key,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderSm,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandPurple.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: AppRadii.borderSm,
          border: Border.all(color: isActive ? AppColors.brandPurple : AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 15,
              color: isActive ? AppColors.brandPurple : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Filters',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.brandPurple : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stylized Action Icon Button inside table row (e.g. View, Edit, Analytics, Delete, More).
class AdminTableActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final Color? color;

  const AdminTableActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.onPressed,
    this.color,
  }) : assert(onTap != null || onPressed != null, 'Either onTap or onPressed must be provided');

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap ?? onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 14,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Stylized Status Badge Pill for table row (e.g. Completed, Live Now, Scheduled, Draft).
class AdminTableStatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color? borderColor;
  final Color textColor;
  final bool isLive;

  const AdminTableStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.borderColor,
    required this.textColor,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor ?? backgroundColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          if (isLive) ...[
            const SizedBox(width: 5),
            _PulsingWaveDot(color: textColor),
          ],
        ],
      ),
    );
  }
}

class _PulsingWaveDot extends StatefulWidget {
  final Color color;

  const _PulsingWaveDot({required this.color});

  @override
  State<_PulsingWaveDot> createState() => _PulsingWaveDotState();
}

class _PulsingWaveDotState extends State<_PulsingWaveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final scale = 1.0 + (t * 1.35);
          final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.75;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
