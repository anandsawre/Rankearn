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
      maxWidth: 600,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context),
        AppModalDialog.primaryButton(
          onPressed: _submit,
          child: Text(
            isEdit ? 'Save Changes' : 'Create Live Quiz',
            style: const TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quiz Title
            AppModalDialog.textField(
              controller: _titleController,
              hint: 'Quiz Title * (e.g. RRB Technician Mega Live Showdown 01)',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 12),

            // Description
            AppModalDialog.textField(
              controller: _descController,
              maxLines: 2,
              hint: 'Description (Short description and rules of the live quiz showdown)',
            ),
            const SizedBox(height: 12),

            // Category & Status
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    hint: 'Category *',
                    value: selectedCategory,
                    items: availableCategories
                        .map((c) => AppDropdownItem(value: c, label: c))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<LiveQuizStatus>(
                    hint: 'Status *',
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
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Start Date & Time
            Row(
              children: [
                Expanded(
                  child: AppDatePicker(
                    label: 'Date',
                    value: _startTime,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    onChanged: (d) {
                      setState(() {
                        _startTime = DateTime(
                          d.year,
                          d.month,
                          d.day,
                          _startTime.hour,
                          _startTime.minute,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTimePicker(
                    label: 'Time',
                    value: TimeOfDay.fromDateTime(_startTime),
                    onChanged: (t) {
                      setState(() {
                        _startTime = DateTime(
                          _startTime.year,
                          _startTime.month,
                          _startTime.day,
                          t.hour,
                          t.minute,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Duration, Questions, Entry & Reward Coins
            Row(
              children: [
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    hint: 'Duration (45)',
                    suffixText: 'min',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _questionsController,
                    keyboardType: TextInputType.number,
                    hint: 'Questions (25)',
                    suffixText: 'Qs',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _entryFeeController,
                    keyboardType: TextInputType.number,
                    hint: 'Entry (0=Free)',
                    suffixText: 'Entry',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _rewardsController,
                    keyboardType: TextInputType.number,
                    hint: 'Reward (1500)',
                    suffixText: 'Coins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
