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
    } catch (_) {}
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
    if (!_formKey.currentState!.validate()) return;

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

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date/time must be after start date/time.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final entryFee = int.tryParse(_entryFeeController.text) ?? 0;
    final prizePool = int.tryParse(_prizePoolController.text) ?? 10000;
    final maxPart = int.tryParse(_maxParticipantsController.text) ?? 5000;

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
      id: widget.editItem?.id ?? 'tour_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      backgroundColor: Colors.white,
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5636F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEdit ? 'Edit Tournament' : 'Create Tournament',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),

              // Scrollable Form Fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Tournament Title *',
                        hint: 'e.g. RRB Technician Grand Quiz',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 12),

                      // Subtitle / Tagline
                      _buildTextField(
                        controller: _subtitleController,
                        label: 'Subtitle / Description',
                        hint: 'e.g. All India Live Quiz Tournament',
                      ),
                      const SizedBox(height: 12),

                      // Category & Status Row
                      Builder(
                        builder: (context) {
                          final availableCategories = <String>{
                            'General',
                            ..._categories,
                            'SSC',
                            'Banking',
                            if (_category.trim().isNotEmpty) _category.trim(),
                          }.toList();

                          final selectedCategory = availableCategories.contains(_category)
                              ? _category
                              : availableCategories.first;

                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Category *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedCategory,
                                          isExpanded: true,
                                          onChanged: (val) {
                                            if (val != null) setState(() => _category = val);
                                          },
                                          items: availableCategories
                                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                                              .toList(),
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
                                    const Text('Status *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<TournamentStatus>(
                                          value: _status,
                                          isExpanded: true,
                                          onChanged: (val) {
                                            if (val != null) setState(() => _status = val);
                                          },
                                          items: TournamentStatus.values
                                              .map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 12))))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Entry Fee & Prize Pool Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _entryFeeController,
                              label: 'Entry Fee (₹ / Coins)',
                              hint: '0 for free',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTextField(
                              controller: _prizePoolController,
                              label: 'Prize Pool (₹) *',
                              hint: '50000',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter prize pool' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Start Date & Time
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              label: 'Start Date',
                              currentDate: _startDate,
                              onPicked: (d) => setState(() => _startDate = d),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTimePicker(
                              label: 'Start Time',
                              currentTime: _startTime,
                              onPicked: (t) => setState(() => _startTime = t),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // End Date & Time
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              label: 'End Date',
                              currentDate: _endDate,
                              onPicked: (d) => setState(() => _endDate = d),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTimePicker(
                              label: 'End Time',
                              currentTime: _endTime,
                              onPicked: (t) => setState(() => _endTime = t),
                            ),
                          ),
                        ],
                      ),

                      // Optional: Copy Questions From Existing Test
                      if (!isEdit) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Select an existing test or mock set to automatically populate this tournament.',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String?>(
                                    value: _selectedSourceTestId,
                                    isExpanded: true,
                                    hint: const Text('None (Blank tournament - add questions later)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    items: [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('None (Blank tournament - add questions later)', style: TextStyle(fontSize: 12)),
                                      ),
                                      ..._availableSourceTests.map((t) {
                                        final tId = t['id']?.toString() ?? '';
                                        final tTitle = t['title']?.toString() ?? 'Test';
                                        final tCat = t['category_id']?.toString() ?? 'General';
                                        final tQs = (t['total_questions'] as num?)?.toInt() ?? 0;
                                        return DropdownMenuItem<String?>(
                                          value: tId,
                                          child: Text(
                                            '$tTitle ($tCat • $tQs Questions)',
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (val) => setState(() => _selectedSourceTestId = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      isEdit ? 'Save Changes' : 'Create Tournament',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime currentDate,
    required ValueChanged<DateTime> onPicked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: currentDate,
              firstDate: DateTime(2025),
              lastDate: DateTime(2030),
            );
            if (picked != null) onPicked(picked);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${currentDate.day}/${currentDate.month}/${currentDate.year}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay currentTime,
    required ValueChanged<TimeOfDay> onPicked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: currentTime,
            );
            if (picked != null) onPicked(picked);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  currentTime.format(context),
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
