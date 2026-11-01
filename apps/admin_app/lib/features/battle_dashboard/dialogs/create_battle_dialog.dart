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
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header with purple gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.battleAdminPurple, AppColors.battleAdminPurpleSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadii.borderTopLg,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.2),
                      borderRadius: AppRadii.borderMd,
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: AppColors.textOnPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Live Battle',
                          style: AppTypography.headingSmall.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Deploy competitive instant or scheduled arena',
                          style: AppTypography.captionBold.copyWith(color: AppColors.battleAdminPurpleLight),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.battleAdminPurpleLight),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Battle Type Selector
                    Text('Battle Type', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                    const SizedBox(height: 20),

                    // Title & Subject Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Battle Title', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _titleController,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                                decoration: _inputDecoration('e.g., General Science Duel'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subject', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _subject,
                                decoration: _inputDecoration(''),
                                items: [
                                  DropdownMenuItem(value: 'General Science', child: Text('General Science', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'Reasoning', child: Text('Reasoning', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'General Awareness', child: Text('General Awareness', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'Mixed (All)', child: Text('Mixed (All)', style: AppTypography.bodyMedium)),
                                ],
                                onChanged: (v) => setState(() => _subject = v!),
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
                              Text('Questions', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: _questionsCount,
                                decoration: _inputDecoration(''),
                                items: [
                                  DropdownMenuItem(value: 5, child: Text('5 Questions', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 10, child: Text('10 Questions', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 15, child: Text('15 Questions', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 20, child: Text('20 Questions', style: AppTypography.bodyMedium)),
                                ],
                                onChanged: (v) => setState(() => _questionsCount = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time / Question', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: _timePerQuestion,
                                decoration: _inputDecoration(''),
                                items: [
                                  DropdownMenuItem(value: 10, child: Text('10 Seconds', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 15, child: Text('15 Seconds', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 20, child: Text('20 Seconds', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 30, child: Text('30 Seconds', style: AppTypography.bodyMedium)),
                                ],
                                onChanged: (v) => setState(() => _timePerQuestion = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Max Players', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextFormField(
                                enabled: _type != BattleType.oneVOne,
                                initialValue: _maxPlayers.toString(),
                                keyboardType: TextInputType.number,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
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
                        color: AppColors.surfaceSubtle,
                        borderRadius: AppRadii.borderLg,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Entry Fee (Coins)', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: _entryFee.toString(),
                                  keyboardType: TextInputType.number,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
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
                                Text('Prize Pool (Coins)', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  key: ValueKey(_reward),
                                  initialValue: _reward.toString(),
                                  keyboardType: TextInputType.number,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.brandGreen),
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
                            borderRadius: AppRadii.borderMd,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isInstant ? AppColors.brandGreenLight : AppColors.surface,
                                borderRadius: AppRadii.borderMd,
                                border: Border.all(color: _isInstant ? AppColors.brandGreen : AppColors.borderSubtle),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Instant Start',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _isInstant ? AppColors.brandGreenDark : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isInstant = false),
                            borderRadius: AppRadii.borderMd,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isInstant ? AppColors.brandPurpleLight : AppColors.surface,
                                borderRadius: AppRadii.borderMd,
                                border: Border.all(color: !_isInstant ? AppColors.battleAdminPurple : AppColors.borderSubtle),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Scheduled Start',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: !_isInstant ? AppColors.battleAdminPurple : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.battleAdminPurple,
                  foregroundColor: AppColors.textOnPrimary,
                  minimumSize: const Size(double.infinity, 44),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
                  elevation: 0,
                ),
                child: Text('Launch Battle Arena', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.textOnPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypePill(BattleType type, String label, IconData icon) {
    final isSelected = _type == type;
    return Expanded(
      child: InkWell(
        onTap: () => _onTypeChanged(type),
        borderRadius: AppRadii.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandPurpleLight : AppColors.surface,
            borderRadius: AppRadii.borderMd,
            border: Border.all(
              color: isSelected ? AppColors.battleAdminPurple : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.battleAdminPurple : AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.battleAdminPurple : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: AppRadii.borderMd,
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderMd,
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderMd,
        borderSide: const BorderSide(color: AppColors.battleAdminPurple, width: 1.5),
      ),
    );
  }
}
