import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_quiz_item.dart';

class ScheduleQuizDialog extends StatefulWidget {
  final List<LiveQuizItem> quizzes;
  final Function(LiveQuizItem, DateTime) onSchedule;

  const ScheduleQuizDialog({
    super.key,
    required this.quizzes,
    required this.onSchedule,
  });

  @override
  State<ScheduleQuizDialog> createState() => _ScheduleQuizDialogState();
}

class _ScheduleQuizDialogState extends State<ScheduleQuizDialog> {
  String? _selectedQuizId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.quizzes.isNotEmpty) {
      _selectedQuizId = widget.quizzes.first.id;
    }
  }

  void _submit() {
    if (_selectedQuizId == null) return;
    final selectedQuiz = widget.quizzes.firstWhere(
      (q) => q.id == _selectedQuizId,
      orElse: () => widget.quizzes.first,
    );
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onSchedule(selectedQuiz, scheduledDateTime);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Schedule Live Quiz',
      subtitle: 'Pick a live contest and set audience broadcast launch time',
      iconData: Icons.schedule_rounded,
      maxWidth: 480,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context),
        AppModalDialog.primaryButton(
          onPressed: _submit,
          child: const Text(
            'Schedule Quiz',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Select Quiz Dropdown
          AppDropdown<String>(
            hint: 'Select Quiz *',
            value: _selectedQuizId ?? (widget.quizzes.isNotEmpty ? widget.quizzes.first.id : null),
            items: widget.quizzes.isNotEmpty
                ? widget.quizzes
                    .map((q) => AppDropdownItem(
                          value: q.id,
                          label: '${q.title} (${q.category})',
                        ))
                    .toList()
                : const [
                    AppDropdownItem(value: 'none', label: 'No Quizzes Available'),
                  ],
            onChanged: (val) {
              if (val != null && val != 'none') {
                setState(() => _selectedQuizId = val);
              }
            },
          ),
          const SizedBox(height: 12),

          // Date & Time Row
          Row(
            children: [
              Expanded(
                child: AppDatePicker(
                  label: 'Date',
                  value: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onChanged: (d) => setState(() => _selectedDate = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTimePicker(
                  label: 'Time',
                  value: _selectedTime,
                  onChanged: (t) => setState(() => _selectedTime = t),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
