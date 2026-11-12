import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/tournament_item.dart';

class CreateTournamentDialog extends StatefulWidget {
  final TournamentItem? editItem;
  final ValueChanged<TournamentItem> onSave;
  final void Function(TournamentItem item, String? sourceTestId)? onSaveWithSource;

  const CreateTournamentDialog({
    super.key,
    this.editItem,
    required this.onSave,
    this.onSaveWithSource,
  });

  @override
  State<CreateTournamentDialog> createState() => _CreateTournamentDialogState();
}

class _CreateTournamentDialogState extends State<CreateTournamentDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _entryFeeController;
  late TextEditingController _prizePoolController;
  late TextEditingController _maxParticipantsController;

  late String _category;
  late TournamentStatus _status;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  List<Map<String, dynamic>> _availableSourceTests = [];
  String? _selectedSourceTestId;

  final List<String> _categories = [
    'Railway',
    'General Science',
    'Mathematics',
    'Current Affairs',
    'State Level',
    'Reasoning',
    'Biology',
    'Mixed',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _subtitleController = TextEditingController(text: item?.subtitle ?? '');
    _entryFeeController = TextEditingController(text: (item?.entryFee ?? 0).toString());
    _prizePoolController = TextEditingController(text: (item?.prizePool ?? 10000).toString());
    _maxParticipantsController = TextEditingController(text: (item?.maxParticipants ?? 5000).toString());

    _category = item?.category ?? 'Railway';
    _status = item?.status ?? TournamentStatus.upcoming;

    final now = DateTime.now();
    _startDate = item?.startDate ?? now.add(const Duration(days: 2));
    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);

    _endDate = item?.endDate ?? _startDate.add(const Duration(hours: 2));
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);

    _loadAvailableSourceTests();
  }

  Future<void> _loadAvailableSourceTests() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;
    try {
      final res = await client
          .from('tests')
          .select('id, title, category_id, total_questions')
          .order('created_at', ascending: false)
          .limit(50);
      if (mounted) {
        setState(() {
          _availableSourceTests = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Error loading source tests for tournament: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final entryFee = int.tryParse(_entryFeeController.text.trim()) ?? 0;
    final prizePool = int.tryParse(_prizePoolController.text.trim()) ?? 10000;
    final maxPart = int.tryParse(_maxParticipantsController.text.trim()) ?? 5000;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final now = DateTime.now();
    TournamentStatus resolvedStatus = _status;
    if (_status != TournamentStatus.archived) {
      if (now.isBefore(startDateTime)) {
        resolvedStatus = TournamentStatus.upcoming;
      } else if (now.isAfter(endDateTime)) {
        resolvedStatus = TournamentStatus.completed;
      } else {
        resolvedStatus = TournamentStatus.ongoing;
      }
    }

    final result = TournamentItem(
      id: widget.editItem?.id ?? 'tourney-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isNotEmpty
          ? _subtitleController.text.trim()
          : 'All India Mega Tournament with Leaderboard & Rewards',
      category: _category,
      startDate: startDateTime,
      endDate: endDateTime,
      entryFee: entryFee,
      participants: widget.editItem?.participants ?? 0,
      status: resolvedStatus,
      prizePool: prizePool,
      maxParticipants: maxPart,
    );

    if (widget.onSaveWithSource != null) {
      widget.onSaveWithSource!(result, _selectedSourceTestId);
    } else {
      widget.onSave(result);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editItem != null;

    final availableCategories = <String>[
      'General',
      ..._categories,
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
      title: isEdit ? 'Edit Tournament' : 'Create Tournament',
      subtitle: 'Configure tournament parameters, prize pool & schedule',
      iconData: Icons.emoji_events_rounded,
      maxWidth: 620,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context),
        AppModalDialog.primaryButton(
          onPressed: _submit,
          child: Text(
            isEdit ? 'Save Changes' : 'Create Tournament',
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
            // Title
            AppModalDialog.textField(
              controller: _titleController,
              hint: 'Tournament Title * (e.g. RRB Technician Grand Championship)',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 12),

            // Subtitle
            AppModalDialog.textField(
              controller: _subtitleController,
              hint: 'Subtitle / Description (e.g. All India Live Quiz Tournament & Leaderboard)',
            ),
            const SizedBox(height: 12),

            // Category & Status Row
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
                  child: AppDropdown<TournamentStatus>(
                    hint: 'Status *',
                    value: _status,
                    items: TournamentStatus.values
                        .map((s) => AppDropdownItem(value: s, label: s.label))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Entry Fee & Prize Pool Row
            Row(
              children: [
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _entryFeeController,
                    keyboardType: TextInputType.number,
                    hint: 'Entry Fee (0 for free)',
                    suffixText: 'Coins / ₹',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _prizePoolController,
                    keyboardType: TextInputType.number,
                    hint: 'Prize Pool * (50000)',
                    suffixText: 'Coins / ₹',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter prize pool' : null,
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
                    label: 'Start Date',
                    value: _startDate,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    onChanged: (d) => setState(() => _startDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTimePicker(
                    label: 'Start Time',
                    value: _startTime,
                    onChanged: (t) => setState(() => _startTime = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // End Date & Time
            Row(
              children: [
                Expanded(
                  child: AppDatePicker(
                    label: 'End Date',
                    value: _endDate,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    onChanged: (d) => setState(() => _endDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTimePicker(
                    label: 'End Time',
                    value: _endTime,
                    onChanged: (t) => setState(() => _endTime = t),
                  ),
                ),
              ],
            ),

            // Optional: Copy Questions From Existing Test
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
                        const Icon(Icons.copy_all_rounded, size: 16, color: AppModalDialog.defaultPrimaryColor),
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
                      'Select an existing test or mock set to automatically populate questions for this tournament.',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    AppDropdown<String?>(
                      value: _selectedSourceTestId,
                      items: [
                        const AppDropdownItem(
                          value: null,
                          label: 'None (Blank tournament - add questions later)',
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
                      onChanged: (val) => setState(() => _selectedSourceTestId = val),
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
