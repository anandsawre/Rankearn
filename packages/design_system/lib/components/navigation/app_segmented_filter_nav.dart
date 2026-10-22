import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// Presentation style of the filter navigation bar.
enum AppFilterNavStyle {
  /// Individual separated pill chips with rounded borders (used in Live Tests).
  chipPills,

  /// Contained pill bar inside a single continuous track with background (used in Tests).
  segmentedTrack,
}

/// Generic data model representing a single selectable filter tab.
class AppFilterNavItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Widget? iconWidget;
  final String? badgeText;

  const AppFilterNavItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.iconWidget,
    this.badgeText,
  });
}

/// Unified, reusable horizontal segmented & pill filter navigation component.
///
/// Supports both individual pill chip styling ([AppFilterNavStyle.chipPills])
/// and enclosed segmented track styling ([AppFilterNavStyle.segmentedTrack]).
class AppSegmentedFilterNav<T> extends StatelessWidget {
  /// Current selected value matching one of the [items].
  final T selectedValue;

  /// Callback when a filter tab is selected.
  final ValueChanged<T> onSelect;

  /// List of filter items.
  final List<AppFilterNavItem<T>> items;

  /// Visual presentation style. Defaults to [AppFilterNavStyle.chipPills].
  final AppFilterNavStyle style;

  /// Active background color for the selected item. Defaults to Brand Green (#10B981).
  final Color activeColor;

  /// Active text and icon color. Defaults to [Colors.white].
  final Color activeTextColor;

  /// Inactive text color. Defaults to [AppColors.textSecondary].
  final Color inactiveTextColor;

  /// Inactive background color for chips.
  final Color? inactiveBackgroundColor;

  /// Inactive border color.
  final Color inactiveBorderColor;

  /// Custom border radius for tab items.
  final BorderRadius? pillBorderRadius;

  /// Padding around the track or scroll view.
  final EdgeInsetsGeometry? contentPadding;

  const AppSegmentedFilterNav({
    super.key,
    required this.selectedValue,
    required this.onSelect,
    required this.items,
    this.style = AppFilterNavStyle.chipPills,
    this.activeColor = const Color(0xFF10B981),
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = AppColors.textSecondary,
    this.inactiveBackgroundColor,
    this.inactiveBorderColor = const Color(0xFFE2E8F0),
    this.pillBorderRadius,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (style == AppFilterNavStyle.segmentedTrack) {
      return Container(
        padding: contentPadding ?? const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                _buildTrackItem(items[i]),
              ],
            ],
          ),
        ),
      );
    }

    // Default: AppFilterNavStyle.chipPills
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: contentPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChipPillItem(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrackItem(AppFilterNavItem<T> item) {
    final isSelected = selectedValue == item.value;
    final radius = pillBorderRadius ?? BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(item.value),
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: radius,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: _buildItemContent(item, isSelected),
        ),
      ),
    );
  }

  Widget _buildChipPillItem(AppFilterNavItem<T> item) {
    final isSelected = selectedValue == item.value;
    final radius = pillBorderRadius ?? BorderRadius.circular(20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(item.value),
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (inactiveBackgroundColor ?? Colors.white),
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? activeColor : inactiveBorderColor,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: _buildItemContent(item, isSelected),
        ),
      ),
    );
  }

  Widget _buildItemContent(AppFilterNavItem<T> item, bool isSelected) {
    final textColor = isSelected ? activeTextColor : inactiveTextColor;
    final itemIconColor = isSelected
        ? activeTextColor
        : (item.iconColor ?? (style == AppFilterNavStyle.chipPills ? const Color(0xFF1E293B) : inactiveTextColor));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.iconWidget != null)
          item.iconWidget!
        else if (item.icon != null) ...[
          Icon(
            item.icon,
            size: item.icon == Icons.circle ? 7 : 16.5,
            color: itemIconColor,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          item.label,
          style: TextStyle(
            color: textColor,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        if (item.badgeText != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.brandBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.badgeText!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.brandBlue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
