import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../services/battle_dashboard_service.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _nameController = TextEditingController(text: 'Railway Aspirants Tech Hub');
  final _descController = TextEditingController(text: 'General Science & Reasoning battle group for RRB preparation');
  final _passwordController = TextEditingController();
  final String _roomCode = 'RM${(10000 + (DateTime.now().millisecondsSinceEpoch % 90000))}';

  String _subject = 'Mathematics';
  int _maxPlayers = 24;
  int _entryFee = 15;
  int _reward = 320;
  bool _isPrivate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleDeploy() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    BattleDashboardService().createNewRoom(
      name: name,
      code: _roomCode,
      subject: _subject,
      maxPlayers: _maxPlayers,
      entryFee: _entryFee,
      reward: _reward,
      isPrivate: _isPrivate,
      password: _isPrivate ? _passwordController.text.trim() : null,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room "$name" ($_roomCode) published!'),
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
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.battleAdminPurpleSecondary, AppColors.battleAdminPurple],
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
                    child: const Icon(Icons.meeting_room_rounded, color: AppColors.textOnPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Custom Battle Room',
                          style: AppTypography.headingSmall.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Configure custom room rules, code & access permissions',
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Name & Code
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Room Name', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _nameController,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                                decoration: _inputDecoration('e.g., RRB-Tech Practice'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Code', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(color: AppColors.brandPurpleLight, borderRadius: AppRadii.borderSm),
                                    child: Text('Auto', style: AppTypography.captionBold.copyWith(color: AppColors.battleAdminPurple, fontSize: 11)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                initialValue: _roomCode,
                                readOnly: true,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.battleAdminPurple),
                                decoration: _inputDecoration('').copyWith(
                                  fillColor: AppColors.brandPurpleLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text('Room Description', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Describe tournament guidelines or audience...'),
                    ),
                    const SizedBox(height: 16),

                    // Subject & Capacity
                    Row(
                      children: [
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
                                  DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'General Science', child: Text('General Science', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'Reasoning', child: Text('Reasoning', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'General Awareness', child: Text('General Awareness', style: AppTypography.bodyMedium)),
                                  DropdownMenuItem(value: 'Mixed (All)', child: Text('Mixed (All)', style: AppTypography.bodyMedium)),
                                ],
                                onChanged: (v) => setState(() => _subject = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Max Participants', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextFormField(
                                initialValue: _maxPlayers.toString(),
                                keyboardType: TextInputType.number,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                                decoration: _inputDecoration(''),
                                onChanged: (v) {
                                  final num = int.tryParse(v) ?? 20;
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

                    // Entry fee & reward
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
                                  onChanged: (v) {
                                    final f = int.tryParse(v) ?? 10;
                                    setState(() {
                                      _entryFee = f;
                                      _reward = (f * _maxPlayers * 0.85).toInt();
                                    });
                                  },
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
                                  onChanged: (v) => setState(() => _reward = int.tryParse(v) ?? 200),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Privacy Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.borderMd,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                            color: _isPrivate ? AppColors.warning : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isPrivate ? 'Private Room (Password Protected)' : 'Public Room (Open for all)',
                                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  _isPrivate ? 'Only players with password or direct link can join' : 'Visible on public rooms list',
                                  style: AppTypography.captionBold.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isPrivate,
                            activeThumbColor: AppColors.battleAdminPurple,
                            onChanged: (v) => setState(() => _isPrivate = v),
                          ),
                        ],
                      ),
                    ),

                    if (_isPrivate) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: _inputDecoration('Enter Room Password').copyWith(
                          prefixIcon: const Icon(Icons.key_rounded, size: 18, color: AppColors.battleAdminPurple),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _handleDeploy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.battleAdminPurple,
                  foregroundColor: AppColors.textOnPrimary,
                  minimumSize: const Size(double.infinity, 44),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
                  elevation: 0,
                ),
                child: Text('Deploy Room', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.textOnPrimary)),
              ),
            ),
          ],
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
