import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/lucky_wheel_item.dart';
import '../widgets/lucky_wheel_icon.dart';

class CreateLuckyWheelDialog extends StatefulWidget {
  final ValueChanged<LuckyWheelCampaignItem> onCampaignCreated;
  final LuckyWheelCampaignItem? editItem;

  const CreateLuckyWheelDialog({
    super.key,
    required this.onCampaignCreated,
    this.editItem,
  });

  @override
  State<CreateLuckyWheelDialog> createState() => _CreateLuckyWheelDialogState();
}

class _CreateLuckyWheelDialogState extends State<CreateLuckyWheelDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _spinCostController;
  late final TextEditingController _dailyLimitController;
  late final TextEditingController _campaignLimitController;

  late WheelRewardType _rewardType;
  late WheelCampaignStatus _status;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _subtitleController = TextEditingController(text: item?.subtitle ?? '');
    _spinCostController = TextEditingController(text: (item?.spinCost ?? 10).toString());
    _dailyLimitController = TextEditingController(text: (item?.dailyLimit ?? 5).toString());
    _campaignLimitController = TextEditingController(text: (item?.campaignLimit ?? 10).toString());

    _rewardType = item?.rewardType ?? WheelRewardType.coins;
    _status = item?.status ?? WheelCampaignStatus.active;
    _startDate = item?.startDate ?? DateTime.now();
    _endDate = item?.endDate ?? DateTime.now().add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _spinCostController.dispose();
    _dailyLimitController.dispose();
    _campaignLimitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.editItem != null;
    final created = LuckyWheelCampaignItem(
      id: widget.editItem?.id ?? 'wheel-camp-${DateTime.now().millisecondsSinceEpoch}',
      rowNumber: widget.editItem?.rowNumber ?? 1,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      rewardType: _rewardType,
      startDate: _startDate,
      endDate: _endDate,
      totalSpins: widget.editItem?.totalSpins ?? 0,
      participants: widget.editItem?.participants ?? 0,
      status: _status,
      createdBy: widget.editItem?.createdBy ?? 'Admin',
      spinCost: int.tryParse(_spinCostController.text) ?? 10,
      dailyLimit: int.tryParse(_dailyLimitController.text) ?? 5,
      campaignLimit: int.tryParse(_campaignLimitController.text) ?? 10,
      iconData: _rewardType.icon,
      iconColor: _rewardType.color,
      iconBgColor: _rewardType.backgroundColor,
      slices: widget.editItem?.slices ?? [],
    );

    widget.onCampaignCreated(created);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit
              ? 'Campaign "${created.title}" updated successfully!'
              : 'Campaign "${created.title}" created successfully!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editItem != null;

    return AppModalDialog(
      title: isEdit ? 'Edit Lucky Wheel Campaign' : 'Create Lucky Wheel Campaign',
      subtitle: 'Configure spin rules, reward type, and user eligibility',
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const LuckyWheelIcon(color: Colors.white, size: 20),
      ),
      gradientColors: const [Color(0xFF5636F5), Color(0xFF7C3AED)],
      maxWidth: 620,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          icon: const Icon(Icons.check_rounded, size: 16),
          label: Text(isEdit ? 'Update Campaign' : 'Create Campaign'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campaign Title
            const Text(
              'Campaign Name *',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a campaign name' : null,
              decoration: AppModalDialog.inputDecoration(
                'e.g. Festive Diwali Mega Spin',
                focusColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),

            // Subtitle / Description
            const Text(
              'Short Description *',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _subtitleController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a description' : null,
              decoration: AppModalDialog.inputDecoration(
                'e.g. Spin daily and win coins, cashback and gift vouchers',
                focusColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),

            // Reward Type & Status Row
            Row(
              children: [
                Expanded(
                  child: AppDropdown<WheelRewardType>(
                    label: 'Primary Reward Type *',
                    value: _rewardType,
                    items: WheelRewardType.values.map((t) {
                      return AppDropdownItem(value: t, label: t.label);
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _rewardType = val);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppDropdown<WheelCampaignStatus>(
                    label: 'Status *',
                    value: _status,
                    items: WheelCampaignStatus.values.map((s) {
                      return AppDropdownItem(value: s, label: s.label);
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Spin Cost, Daily Limit, Campaign Limit Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spin Cost (Coins)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _spinCostController,
                        keyboardType: TextInputType.number,
                        decoration: AppModalDialog.inputDecoration('10', focusColor: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Limit / User',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _dailyLimitController,
                        keyboardType: TextInputType.number,
                        decoration: AppModalDialog.inputDecoration('5', focusColor: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campaign Limit',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _campaignLimitController,
                        keyboardType: TextInputType.number,
                        decoration: AppModalDialog.inputDecoration('10', focusColor: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Date Range pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _startDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
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
                      const Text(
                        'End Date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                            ],
                          ),
                        ),
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
}
