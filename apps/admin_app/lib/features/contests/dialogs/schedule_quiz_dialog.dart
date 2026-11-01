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
      gradientColors: const [Color(0xFF0084FF), Color(0xFF00B4D8)],
      maxWidth: 480,
      scrollable: true,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0084FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Schedule Quiz', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Select Quiz Dropdown
          const Text('Select Quiz *', style: _labelStyle),
          const SizedBox(height: 6),
          AppDropdown<String>(
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
          const SizedBox(height: 16),

          // Date & Time Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Broadcast Date *', style: _labelStyle),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF0084FF)),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Broadcast Time *', style: _labelStyle),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (t != null) setState(() => _selectedTime = t);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF0084FF)),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );
}
