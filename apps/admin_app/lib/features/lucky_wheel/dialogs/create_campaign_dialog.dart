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
    _dailyLimitController = TextEditingController(text: (item?.dailyLimit ?? 3).toString());
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
      dailyLimit: int.tryParse(_dailyLimitController.text) ?? 3,
      campaignLimit: int.tryParse(_campaignLimitController.text) ?? 10,
      iconData: _rewardType.icon,
      iconColor: _rewardType.color,
      iconBgColor: _rewardType.backgroundColor,
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5636F5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const LuckyWheelIcon(color: Color(0xFF5636F5), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Edit Lucky Wheel Campaign' : 'Create Lucky Wheel Campaign',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101A3A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Configure spin rules, reward type, and user eligibility',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          decoration: InputDecoration(
                            hintText: 'e.g. Festive Diwali Mega Spin',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          decoration: InputDecoration(
                            hintText: 'e.g. Spin daily and win coins, cashback and gift vouchers',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Reward Type & Status Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Primary Reward Type *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<WheelRewardType>(
                                    initialValue: _rewardType,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    items: WheelRewardType.values.map((t) {
                                      return DropdownMenuItem(value: t, child: Text(t.label));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _rewardType = val);
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
                                  const Text(
                                    'Status *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<WheelCampaignStatus>(
                                    initialValue: _status,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    items: WheelCampaignStatus.values.map((s) {
                                      return DropdownMenuItem(value: s, child: Text(s.label));
                                    }).toList(),
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
                                    decoration: InputDecoration(
                                      hintText: '10',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
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
                                    decoration: InputDecoration(
                                      hintText: '3',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
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
                                    decoration: InputDecoration(
                                      hintText: '10',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
