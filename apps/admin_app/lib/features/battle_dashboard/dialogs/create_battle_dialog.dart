import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';

class CreateBattleDialog extends StatefulWidget {
  const CreateBattleDialog({super.key});

  @override
  State<CreateBattleDialog> createState() => _CreateBattleDialogState();
}

class _CreateBattleDialogState extends State<CreateBattleDialog> {
  BattleType _type = BattleType.oneVOne;
  final _titleController = TextEditingController(text: 'Rapid Science Showdown');
  String _subject = 'General Science';
  final String _category = 'RRB / SSC General';
  int _questionsCount = 5;
  int _timePerQuestion = 10;
  int _entryFee = 20;
  int _reward = 36;
  int _maxPlayers = 2;
  bool _isInstant = true;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onTypeChanged(BattleType type) {
    setState(() {
      _type = type;
      if (type == BattleType.oneVOne) {
        _maxPlayers = 2;
        _reward = (_entryFee * 1.8).toInt();
      } else if (type == BattleType.multiplayer) {
        _maxPlayers = 10;
        _reward = (_entryFee * 10 * 0.85).toInt();
      } else {
        _maxPlayers = 30;
        _reward = (_entryFee * 30 * 0.8).toInt();
      }
    });
  }

  void _handleFeeChange(int val) {
    setState(() {
      _entryFee = val;
      if (_type == BattleType.oneVOne) {
        _reward = (val * 1.8).toInt();
      } else {
        _reward = (val * _maxPlayers * 0.85).toInt();
      }
    });
  }

  void _handleCreate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    BattleDashboardService().createNewBattle(
      title: title,
      type: _type,
      subject: _subject,
      category: _category,
      questionsCount: _questionsCount,
      timePerQuestion: _timePerQuestion,
      entryFee: _entryFee,
      reward: _reward,
      maxPlayers: _maxPlayers,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Battle "$title" created and live!'),
        backgroundColor: AppColors.brandGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Create New Live Battle',
      subtitle: 'Deploy competitive instant or scheduled arena',
      iconData: Icons.flash_on_rounded,
      gradientColors: const [AppColors.battleAdminPurple, AppColors.battleAdminPurpleSecondary],
      maxWidth: 620,
      scrollable: true,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _handleCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.battleAdminPurple,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Launch Battle Arena', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Battle Type Selector
          const Text('Battle Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypePill(BattleType.oneVOne, '1 vs 1 Duel', Icons.sports_kabaddi_rounded),
              const SizedBox(width: 10),
              _buildTypePill(BattleType.multiplayer, 'Multiplayer', Icons.groups_rounded),
              const SizedBox(width: 10),
              _buildTypePill(BattleType.room, 'Private Room', Icons.meeting_room_rounded),
            ],
          ),
          const SizedBox(height: 18),

          // Title & Subject Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Battle Title', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: _inputDecoration('e.g., General Science Duel'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subject', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _subject,
                      items: const [
                        AppDropdownItem(value: 'General Science', label: 'General Science'),
                        AppDropdownItem(value: 'Reasoning', label: 'Reasoning'),
                        AppDropdownItem(value: 'Mathematics', label: 'Mathematics'),
                        AppDropdownItem(value: 'General Awareness', label: 'General Awareness'),
                        AppDropdownItem(value: 'Mixed (All)', label: 'Mixed (All)'),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _subject = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Questions & Duration Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Questions', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    AppDropdown<int>(
                      value: _questionsCount,
                      items: const [
                        AppDropdownItem(value: 5, label: '5 Questions'),
                        AppDropdownItem(value: 10, label: '10 Questions'),
                        AppDropdownItem(value: 15, label: '15 Questions'),
                        AppDropdownItem(value: 20, label: '20 Questions'),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _questionsCount = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Time / Question', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    AppDropdown<int>(
                      value: _timePerQuestion,
                      items: const [
                        AppDropdownItem(value: 10, label: '10 Seconds'),
                        AppDropdownItem(value: 15, label: '15 Seconds'),
                        AppDropdownItem(value: 20, label: '20 Seconds'),
                        AppDropdownItem(value: 30, label: '30 Seconds'),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _timePerQuestion = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Max Players', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextFormField(
                      enabled: _type != BattleType.oneVOne,
                      initialValue: _maxPlayers.toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: _inputDecoration(''),
                      onChanged: (v) {
                        final num = int.tryParse(v) ?? 2;
                        setState(() {
                          _maxPlayers = num;
                          _reward = (_entryFee * num * 0.85).toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stakes & Prize Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Entry Fee (Coins)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: _entryFee.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        decoration: _inputDecoration('').copyWith(
                          prefixIcon: const Icon(Icons.monetization_on_rounded, color: AppColors.warning, size: 18),
                        ),
                        onChanged: (v) => _handleFeeChange(int.tryParse(v) ?? 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prize Pool (Coins)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: ValueKey(_reward),
                        initialValue: _reward.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.brandGreen),
                        decoration: _inputDecoration('').copyWith(
                          prefixIcon: const Icon(Icons.emoji_events_rounded, color: AppColors.brandGreen, size: 18),
                        ),
                        onChanged: (v) => setState(() => _reward = int.tryParse(v) ?? 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Start Mode
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isInstant = true),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isInstant ? AppColors.brandGreenLight : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isInstant ? AppColors.brandGreen : const Color(0xFFCBD5E1)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Instant Start',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isInstant ? AppColors.brandGreenDark : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isInstant = false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isInstant ? AppColors.brandPurpleLight : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: !_isInstant ? AppColors.battleAdminPurple : const Color(0xFFCBD5E1)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Scheduled Start',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: !_isInstant ? AppColors.battleAdminPurple : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypePill(BattleType type, String label, IconData icon) {
    final isSelected = _type == type;
    return Expanded(
      child: InkWell(
        onTap: () => _onTypeChanged(type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandPurpleLight : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.battleAdminPurple : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.battleAdminPurple : const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.battleAdminPurple : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: AppColors.battleAdminPurple);
}
