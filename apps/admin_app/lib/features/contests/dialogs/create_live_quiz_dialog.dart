import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_quiz_item.dart';

class CreateLiveQuizDialog extends StatefulWidget {
  final LiveQuizItem? initialItem;
  final Function(LiveQuizItem) onSave;

  const CreateLiveQuizDialog({
    super.key,
    this.initialItem,
    required this.onSave,
  });

  @override
  State<CreateLiveQuizDialog> createState() => _CreateLiveQuizDialogState();
}

class _CreateLiveQuizDialogState extends State<CreateLiveQuizDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _durationController;
  late TextEditingController _questionsController;
  late TextEditingController _rewardsController;
  late TextEditingController _entryFeeController;
  String _category = 'Railway';
  DateTime _startTime = DateTime.now().add(const Duration(hours: 2));
  LiveQuizStatus _status = LiveQuizStatus.scheduled;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _durationController = TextEditingController(text: (item?.durationMinutes ?? 45).toString());
    _questionsController = TextEditingController(text: (item?.questionsCount ?? 25).toString());
    _rewardsController = TextEditingController(text: (item?.rewardCoins ?? 1500).toString());
    _entryFeeController = TextEditingController(text: (item?.entryFeeCoins ?? 0).toString());
    if (item != null) {
      _category = item.category;
      _startTime = item.startTime;
      _status = item.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _questionsController.dispose();
    _rewardsController.dispose();
    _entryFeeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final duration = int.tryParse(_durationController.text.trim()) ?? 45;
    final entryFee = int.tryParse(_entryFeeController.text.trim()) ?? 0;
    final now = DateTime.now();
    final localEnd = _startTime.add(Duration(minutes: duration));

    LiveQuizStatus resolvedStatus = _status;
    if (_status != LiveQuizStatus.draft) {
      if (now.isBefore(_startTime)) {
        resolvedStatus = LiveQuizStatus.scheduled;
      } else if (now.isAfter(localEnd)) {
        resolvedStatus = LiveQuizStatus.completed;
      } else {
        resolvedStatus = LiveQuizStatus.liveNow;
      }
    }

    final newItem = LiveQuizItem(
      id: widget.initialItem?.id ?? 'lq-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'Live competitive quiz showdown with instant reward distribution.',
      category: _category,
      status: resolvedStatus,
      startTime: _startTime,
      durationMinutes: duration,
      questionsCount: int.tryParse(_questionsController.text.trim()) ?? 25,
      participantsCount: widget.initialItem?.participantsCount ?? 0,
      rewardCoins: int.tryParse(_rewardsController.text.trim()) ?? 1500,
      entryFeeCoins: entryFee,
    );

    widget.onSave(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;

    final availableCategories = <String>[
      'General',
      'Railway',
      'General Science',
      'Mathematics',
      'Current Affairs',
      'Reasoning',
      'Biology',
      'Mixed',
      'SSC',
      'Banking',
    ];
    if (_category.trim().isNotEmpty && !availableCategories.contains(_category.trim())) {
      availableCategories.add(_category.trim());
    }

    final selectedCategory = availableCategories.contains(_category)
        ? _category
        : availableCategories.first;

    return AppModalDialog(
      title: isEdit ? 'Edit Live Quiz' : 'Create Live Quiz',
      subtitle: 'Scheduled Fast Live Quiz • Instant Coin Rewards',
      iconData: Icons.podcasts_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF7C3AED)],
      maxWidth: 600,
      scrollable: true,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
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
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            isEdit ? 'Save Changes' : 'Create Live Quiz',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quiz Title
            const Text('Quiz Title *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('e.g. RRB Technician Mega Live Showdown 01'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 14),

            // Description
            const Text('Description', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              decoration: _inputDecoration('Short description and rules of the live quiz showdown'),
            ),
            const SizedBox(height: 14),

            // Category & Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<String>(
                        value: selectedCategory,
                        items: availableCategories
                            .map((c) => AppDropdownItem(value: c, label: c))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<LiveQuizStatus>(
                        value: _status,
                        items: const [
                          AppDropdownItem(value: LiveQuizStatus.scheduled, label: 'Scheduled'),
                          AppDropdownItem(value: LiveQuizStatus.liveNow, label: 'Live Now'),
                          AppDropdownItem(value: LiveQuizStatus.ongoing, label: 'Ongoing'),
                          AppDropdownItem(value: LiveQuizStatus.completed, label: 'Completed'),
                          AppDropdownItem(value: LiveQuizStatus.draft, label: 'Draft'),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Start Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date *', style: _labelStyle),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _startTime,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) {
                            setState(() {
                              _startTime = DateTime(
                                d.year,
                                d.month,
                                d.day,
                                _startTime.hour,
                                _startTime.minute,
                              );
                            });
                          }
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
                              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF5636F5)),
                              const SizedBox(width: 8),
                              Text(
                                '${_startTime.year}-${_startTime.month.toString().padLeft(2, '0')}-${_startTime.day.toString().padLeft(2, '0')}',
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
                      const Text('Start Time *', style: _labelStyle),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_startTime),
                          );
                          if (t != null) {
                            setState(() {
                              _startTime = DateTime(
                                _startTime.year,
                                _startTime.month,
                                _startTime.day,
                                t.hour,
                                t.minute,
                              );
                            });
                          }
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
                              const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF5636F5)),
                              const SizedBox(width: 8),
                              Text(
                                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
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
            const SizedBox(height: 14),

            // Duration, Questions, Entry & Reward Coins
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Duration (min)', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('45'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Questions', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _questionsController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('25'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Entry (Coins)', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _entryFeeController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0=Free'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reward Coins', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _rewardsController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('1500'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.5),
      ),
    );
  }
}
