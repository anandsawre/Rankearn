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
    return AppModalDialog(
      title: 'Create Custom Battle Room',
      subtitle: 'Configure custom room rules, code & access permissions',
      iconData: Icons.meeting_room_rounded,
      gradientColors: const [AppColors.battleAdminPurpleSecondary, AppColors.battleAdminPurple],
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
          onPressed: _handleDeploy,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.battleAdminPurple,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Deploy Arena Room', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
        ),
      ],
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
                    const Text('Room Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 12.5),
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
                        const Text('Code', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(color: AppColors.brandPurpleLight, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Auto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.battleAdminPurple)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: _roomCode,
                      readOnly: true,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.battleAdminPurple),
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
          const Text('Room Description', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            style: const TextStyle(fontSize: 12.5),
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
                    const Text('Subject', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _subject,
                      items: const [
                        AppDropdownItem(value: 'Mathematics', label: 'Mathematics'),
                        AppDropdownItem(value: 'General Science', label: 'General Science'),
                        AppDropdownItem(value: 'Reasoning', label: 'Reasoning'),
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Max Participants', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: _maxPlayers.toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12.5),
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
                        onChanged: (v) => setState(() => _reward = int.tryParse(v) ?? 50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Access Type (Public vs Private)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: _isPrivate,
                  activeColor: AppColors.battleAdminPurple,
                  onChanged: (val) => setState(() => _isPrivate = val ?? false),
                  title: const Text('Require Password / PIN to Join', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  subtitle: const Text('Only users with passcode can enter this arena', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ),
                if (_isPrivate) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: _inputDecoration('Enter 4-6 digit passcode'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
        borderSide: const BorderSide(color: AppColors.battleAdminPurple, width: 1.5),
      ),
    );
  }
}
