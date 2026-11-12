import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../feedback/app_modal_dialog.dart';

/// Centralized tokenized Date Picker trigger with a branded custom modal calendar dialog.
///
/// Features:
/// - Exact 42px height alignment with AppModalDialog.textField and AppDropdown.
/// - Soft ambient card shadow and 10px rounded corners.
/// - Vibrant Orange Hero Header Dialog with Glassmorphic Pod matching Rankearn Dialog System.
/// - Tokenized weekday headers, clean selected/today pills, month navigators, and action buttons.
class AppDatePicker extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final double height;
  final bool enabled;

  const AppDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.firstDate,
    this.lastDate,
    this.height = 42.0,
    this.enabled = true,
  });

  String get _formattedDate {
    final y = value.year.toString();
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;
    final picked = await AppModalDialog.show<DateTime>(
      context: context,
      builder: (ctx) => _AppDatePickerDialog(
        initialDate: value,
        firstDate: firstDate ?? DateTime(2024),
        lastDate: lastDate ?? DateTime(2035),
      ),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.surfaceSubtle,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0B0F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppModalDialog.defaultPrimaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formattedDate,
                style: AppTypography.formInput.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ),
            if (label != null)
              Text(
                label!,
                style: AppTypography.formHint.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom branded Calendar Dialog
class _AppDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _AppDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<_AppDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
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

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final weekdayStr = dayNames[_selectedDate.weekday % 7];
    final monthStr = _months[_selectedDate.month - 1].substring(0, 3);
    final formattedSelected = '$weekdayStr, $monthStr ${_selectedDate.day}, ${_selectedDate.year}';

    return AppModalDialog(
      title: 'Select Date',
      subtitle: formattedSelected,
      iconData: Icons.calendar_month_rounded,
      maxWidth: 390,
      actions: [
        AppModalDialog.cancelButton(context),
        AppModalDialog.primaryButton(
          onPressed: () => Navigator.of(context).pop(_selectedDate),
          child: const Text(
            'Confirm Date',
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

          // Days Grid
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startOffset = firstDayOfMonth.weekday % 7; // Sunday = 0

    final totalCells = ((startOffset + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        if (index < startOffset || index >= startOffset + daysInMonth) {
          return const SizedBox.shrink();
        }

        final dayNum = index - startOffset + 1;
        final cellDate = DateTime(_displayedMonth.year, _displayedMonth.month, dayNum);
        final isSelected = cellDate.year == _selectedDate.year &&
            cellDate.month == _selectedDate.month &&
            cellDate.day == _selectedDate.day;
        final isToday = cellDate.year == today.year &&
            cellDate.month == today.month &&
            cellDate.day == today.day;
        final isOutOfRange = cellDate.isBefore(widget.firstDate) || cellDate.isAfter(widget.lastDate);

        Color? bgColor;
        Color textColor = AppColors.textPrimary;
        BoxBorder? border;

        if (isSelected) {
          bgColor = AppModalDialog.defaultPrimaryColor;
          textColor = Colors.white;
        } else if (isToday) {
          bgColor = AppColors.brandOrangeLight;
          border = Border.all(color: AppModalDialog.defaultPrimaryColor, width: 1.5);
          textColor = AppModalDialog.defaultPrimaryColor;
        }

        return InkWell(
          onTap: isOutOfRange
              ? null
              : () => setState(() => _selectedDate = cellDate),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: border,
            ),
            child: Text(
              '$dayNum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                color: isOutOfRange
                    ? AppColors.disabled
                    : textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Centralized tokenized Time Picker trigger with a branded custom modal clock dialog.
class AppTimePicker extends StatelessWidget {
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  final String? label;
  final double height;
  final bool enabled;

  const AppTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.height = 42.0,
    this.enabled = true,
  });

  String get _formattedTime {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;
    final picked = await AppModalDialog.show<TimeOfDay>(
      context: context,
      builder: (ctx) => _AppTimePickerDialog(initialTime: value),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.surfaceSubtle,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0B0F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: AppModalDialog.defaultPrimaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formattedTime,
                style: AppTypography.formInput.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ),
            if (label != null)
              Text(
                label!,
                style: AppTypography.formHint.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom branded Time Picker Dialog
class _AppTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const _AppTimePickerDialog({required this.initialTime});

  @override
  State<_AppTimePickerDialog> createState() => _AppTimePickerDialogState();
}

class _AppTimePickerDialogState extends State<_AppTimePickerDialog> {
  late int _selectedHour; // 1..12
  late int _selectedMinute; // 0..59
  late bool _isAm;

  @override
  void initState() {
    super.initState();
    final h24 = widget.initialTime.hour;
    _isAm = h24 < 12;
    _selectedHour = (h24 % 12 == 0) ? 12 : (h24 % 12);
    _selectedMinute = widget.initialTime.minute;
  }

  TimeOfDay get _computedTime {
    int h24;
    if (_isAm) {
      h24 = (_selectedHour == 12) ? 0 : _selectedHour;
    } else {
      h24 = (_selectedHour == 12) ? 12 : _selectedHour + 12;
    }
    return TimeOfDay(hour: h24, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    final hStr = _selectedHour.toString().padLeft(2, '0');
    final mStr = _selectedMinute.toString().padLeft(2, '0');
    final amPmStr = _isAm ? 'AM' : 'PM';
    final subtitle = '$hStr:$mStr $amPmStr (24-Hour: ${_computedTime.hour.toString().padLeft(2, '0')}:${_computedTime.minute.toString().padLeft(2, '0')})';

    return AppModalDialog(
      title: 'Select Time',
      subtitle: subtitle,
      iconData: Icons.alarm_rounded,
      maxWidth: 390,
      actions: [
        AppModalDialog.cancelButton(context),
        AppModalDialog.primaryButton(
          onPressed: () => Navigator.of(context).pop(_computedTime),
          child: const Text(
            'Confirm Time',
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
          // Large Time Banner Box with AM/PM pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours Box
                _buildTimeBox(
                  value: hStr,
                  label: 'Hour',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Minutes Box
                _buildTimeBox(
                  value: mStr,
                  label: 'Minute',
                ),
                const SizedBox(width: 16),
                // AM / PM Toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildPeriodButton('AM', _isAm, () => setState(() => _isAm = true)),
                      Container(height: 1, width: 44, color: AppColors.border),
                      _buildPeriodButton('PM', !_isAm, () => setState(() => _isAm = false)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Select Hour Chips (1 to 12)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SELECT HOUR',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(12, (i) {
              final h = i + 1;
              final isSel = h == _selectedHour;
              return InkWell(
                onTap: () => setState(() => _selectedHour = h),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 48,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? AppModalDialog.defaultPrimaryColor : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSel ? AppModalDialog.defaultPrimaryColor : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$h',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Quick Select Minute Chips (00, 05, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SELECT MINUTE',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55].map((m) {
              final isSel = m == _selectedMinute;
              final mFormatted = m.toString().padLeft(2, '0');
              return InkWell(
                onTap: () => setState(() => _selectedMinute = m),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 48,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? AppModalDialog.defaultPrimaryColor : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSel ? AppModalDialog.defaultPrimaryColor : AppColors.border,
                    ),
                  ),
                  child: Text(
                    ':$mFormatted',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox({required String value, required String label}) {
    return Container(
      width: 64,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppModalDialog.defaultPrimaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: AppTypography.fontHeading,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        color: isSelected ? AppColors.brandOrangeLight : Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppModalDialog.defaultPrimaryColor : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
