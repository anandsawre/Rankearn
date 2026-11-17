import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/live_quiz_item.dart';

class CreateLiveQuizDialog extends StatefulWidget {
  final LiveQuizItem? initialItem;
  final Function(LiveQuizItem) onSave;
  final void Function(LiveQuizItem item, String? sourceTestId)? onSaveWithSource;

  const CreateLiveQuizDialog({
    super.key,
    this.initialItem,
    required this.onSave,
    this.onSaveWithSource,
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

  List<Map<String, dynamic>> _availableSourceTests = [];
  String? _selectedSourceTestId;

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

    _loadAvailableSourceTests();
  }

  Future<void> _loadAvailableSourceTests() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;
    try {
      final res = await client
          .from('tests')
          .select('id, title, category_id, total_questions, duration_minutes')
          .order('created_at', ascending: false)
          .limit(100);
      if (mounted) {
        setState(() {
          _availableSourceTests = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Error loading source tests for live quiz: $e');
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

    if (widget.onSaveWithSource != null) {
      widget.onSaveWithSource!(newItem, _selectedSourceTestId);
    } else {
      widget.onSave(newItem);
    }
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

            // Copy Questions From Existing Test (Optional)
            if (!isEdit) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppRadii.cardSubtle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.copy_all_rounded,
                          size: 16,
                          color: AppModalDialog.defaultPrimaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Copy Questions from Existing Test (Optional)',
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select an existing test or mock set to automatically populate questions for this live quiz.',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppDropdown<String?>(
                      value: _selectedSourceTestId,
                      items: [
                        const AppDropdownItem(
                          value: null,
                          label: 'None (Blank quiz - add questions later)',
                        ),
                        ..._availableSourceTests.map((t) {
                          final tId = t['id']?.toString() ?? '';
                          final tTitle = t['title']?.toString() ?? 'Test';
                          final tCat = t['category_id']?.toString() ?? 'General';
                          final tQs = (t['total_questions'] as num?)?.toInt() ?? 0;
                          return AppDropdownItem<String?>(
                            value: tId,
                            label: '$tTitle ($tCat • $tQs Questions)',
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedSourceTestId = val;
                          if (val != null) {
                            final match = _availableSourceTests.firstWhere(
                              (t) => t['id']?.toString() == val,
                              orElse: () => {},
                            );
                            if (match.isNotEmpty) {
                              final srcTitle = match['title']?.toString();
                              if (srcTitle != null && srcTitle.isNotEmpty &&
                                  (_titleController.text.trim().isEmpty || _titleController.text.trim().contains('Live Showdown'))) {
                                _titleController.text = '$srcTitle (Live Showdown)';
                              }
                              final srcQs = (match['total_questions'] as num?)?.toInt();
                              if (srcQs != null && srcQs > 0) {
                                _questionsController.text = srcQs.toString();
                              }
                              final srcDur = (match['duration_minutes'] as num?)?.toInt();
                              if (srcDur != null && srcDur > 0) {
                                _durationController.text = srcDur.toString();
                              }
                              final srcCat = match['category_id']?.toString();
                              if (srcCat != null && srcCat.isNotEmpty) {
                                _category = srcCat;
                              }
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
