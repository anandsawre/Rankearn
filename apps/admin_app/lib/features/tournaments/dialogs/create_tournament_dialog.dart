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
      gradientColors: const [Color(0xFF5636F5), Color(0xFF7C3AED)],
      maxWidth: 620,
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
            isEdit ? 'Save Changes' : 'Create Tournament',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Text('Tournament Title *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('e.g. RRB Technician Grand Championship'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 14),

            // Subtitle
            const Text('Subtitle / Description', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _subtitleController,
              decoration: _inputDecoration('e.g. All India Live Quiz Tournament & Leaderboard'),
            ),
            const SizedBox(height: 14),

            // Category & Status Row
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
                      AppDropdown<TournamentStatus>(
                        value: _status,
                        items: TournamentStatus.values
                            .map((s) => AppDropdownItem(value: s, label: s.label))
                            .toList(),
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

            // Entry Fee & Prize Pool Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Entry Fee (Coins / ₹)', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _entryFeeController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0 for free'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prize Pool (Coins / ₹) *', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _prizePoolController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('50000'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter prize pool' : null,
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
                            initialDate: _startDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setState(() => _startDate = d);
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
                                '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
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
                            initialTime: _startTime,
                          );
                          if (t != null) setState(() => _startTime = t);
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

            // End Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date *', style: _labelStyle),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setState(() => _endDate = d);
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
                                '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
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
                      const Text('End Time *', style: _labelStyle),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (t != null) setState(() => _endTime = t);
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
                                '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
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

            // Optional: Copy Questions From Existing Test
            if (!isEdit) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.copy_all_rounded, size: 16, color: Color(0xFF5636F5)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Copy Questions from Existing Test (Optional)',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select an existing test or mock set to automatically populate questions for this tournament.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
