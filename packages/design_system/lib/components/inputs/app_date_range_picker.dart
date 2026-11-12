import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../feedback/app_modal_dialog.dart';

/// Centralized tokenized Date Range Picker trigger with custom branded modal dialog.
class AppDateRangePicker {
  AppDateRangePicker._();

  static Future<DateTimeRange?> show({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    final initial = initialDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
    return AppModalDialog.show<DateTimeRange>(
      context: context,
      builder: (ctx) => _AppDateRangePickerDialog(
        initialRange: initial,
        firstDate: firstDate ?? DateTime(2024),
        lastDate: lastDate ?? DateTime(2035),
      ),
    );
  }
}

class _AppDateRangePickerDialog extends StatefulWidget {
  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const _AppDateRangePickerDialog({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_AppDateRangePickerDialog> createState() => _AppDateRangePickerDialogState();
}

class _AppDateRangePickerDialogState extends State<_AppDateRangePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _displayedMonth;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(widget.initialRange.start.year, widget.initialRange.start.month, widget.initialRange.start.day);
    _endDate = DateTime(widget.initialRange.end.year, widget.initialRange.end.month, widget.initialRange.end.day);
    _displayedMonth = DateTime(_endDate!.year, _endDate!.month, 1);
  }

  void _onDayTapped(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (date.isBefore(_startDate!)) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  void _setPreset(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _endDate = today;
      _startDate = today.subtract(Duration(days: days));
      _displayedMonth = DateTime(_endDate!.year, _endDate!.month, 1);
    });
  }

  void _prevMonth() {
    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    if (prev.isAfter(DateTime(widget.firstDate.year, widget.firstDate.month - 1, 28))) {
      setState(() => _displayedMonth = prev);
    }
  }

  void _nextMonth() {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    if (next.isBefore(DateTime(widget.lastDate.year, widget.lastDate.month + 1, 1))) {
      setState(() => _displayedMonth = next);
    }
  }

  String _formatRangeLabel() {
    if (_startDate == null) return 'Select start date';
    final sStr = '${_months[_startDate!.month - 1].substring(0, 3)} ${_startDate!.day}, ${_startDate!.year}';
    if (_endDate == null) return '$sStr — Select end date';
    final eStr = '${_months[_endDate!.month - 1].substring(0, 3)} ${_endDate!.day}, ${_endDate!.year}';
    return '$sStr — $eStr';
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _startDate != null && _endDate != null;

    return AppModalDialog(
      title: 'Select Date Range',
      subtitle: _formatRangeLabel(),
      iconData: Icons.date_range_rounded,
      maxWidth: 440,
      actions: [
        AppModalDialog.cancelButton(context),
        AppModalDialog.primaryButton(
          onPressed: canConfirm
              ? () => Navigator.of(context).pop(DateTimeRange(start: _startDate!, end: _endDate!))
              : null,
          child: const Text(
            'Apply Range',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick presets row
          Row(
            children: [
              _buildPresetChip('Last 7 Days', 7),
              const SizedBox(width: 6),
              _buildPresetChip('Last 30 Days', 30),
              const SizedBox(width: 6),
              _buildPresetChip('Last 90 Days', 90),
            ],
          ),
          const SizedBox(height: 12),

          // Month Navigator Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 20, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                  onPressed: _prevMonth,
                ),
                Text(
                  '${_months[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Weekday header
          Row(
            children: _weekdays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: d == 'Sun' ? AppColors.liveRed : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar Grid with range highlight
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetStart = today.subtract(Duration(days: days));
    final isSelected = _startDate != null &&
        _endDate != null &&
        _startDate!.year == targetStart.year &&
        _startDate!.month == targetStart.month &&
        _startDate!.day == targetStart.day &&
        _endDate!.year == today.year &&
        _endDate!.month == today.month &&
        _endDate!.day == today.day;

    return Expanded(
      child: InkWell(
        onTap: () => _setPreset(days),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandOrangeLight : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppModalDialog.defaultPrimaryColor : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppModalDialog.defaultPrimaryColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startOffset = firstDayOfMonth.weekday % 7; // Sunday = 0
    final totalCells = ((startOffset + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 4,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        if (index < startOffset || index >= startOffset + daysInMonth) {
          return const SizedBox.shrink();
        }

        final dayNum = index - startOffset + 1;
        final cellDate = DateTime(_displayedMonth.year, _displayedMonth.month, dayNum);

        final isStart = _startDate != null &&
            cellDate.year == _startDate!.year &&
            cellDate.month == _startDate!.month &&
            cellDate.day == _startDate!.day;

        final isEnd = _endDate != null &&
            cellDate.year == _endDate!.year &&
            cellDate.month == _endDate!.month &&
            cellDate.day == _endDate!.day;

        final isInRange = _startDate != null &&
            _endDate != null &&
            cellDate.isAfter(_startDate!) &&
            cellDate.isBefore(_endDate!);

        final isOutOfRange = cellDate.isBefore(widget.firstDate) || cellDate.isAfter(widget.lastDate);

        Color? bgColor;
        Color textColor = AppColors.textPrimary;
        BorderRadius radius = BorderRadius.circular(8);

        if (isStart || isEnd) {
          bgColor = AppModalDialog.defaultPrimaryColor;
          textColor = Colors.white;
        } else if (isInRange) {
          bgColor = AppColors.brandOrangeLight;
          textColor = AppModalDialog.defaultPrimaryColor;
          radius = BorderRadius.zero;
        }

        return InkWell(
          onTap: isOutOfRange ? null : () => _onDayTapped(cellDate),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
            ),
            child: Text(
              '$dayNum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isStart || isEnd ? FontWeight.w800 : (isInRange ? FontWeight.w700 : FontWeight.w600),
                color: isOutOfRange ? AppColors.disabled : textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

