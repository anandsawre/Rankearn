import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/lucky_wheel_item.dart';

class ManageCampaignsDialog extends StatefulWidget {
  final List<LuckyWheelCampaignItem> campaigns;
  final ValueChanged<LuckyWheelCampaignItem> onToggleStatus;

  const ManageCampaignsDialog({
    super.key,
    required this.campaigns,
    required this.onToggleStatus,
  });

  @override
  State<ManageCampaignsDialog> createState() => _ManageCampaignsDialogState();
}

class _ManageCampaignsDialogState extends State<ManageCampaignsDialog> {
  late List<LuckyWheelCampaignItem> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.campaigns);
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Manage Lucky Wheel Campaigns',
      subtitle: 'Control campaign lifecycles, pause/resume, and review limits',
      iconData: Icons.folder_outlined,
      gradientColors: const [Color(0xFF00C48C), Color(0xFF10B981)],
      maxWidth: 720,
      maxHeight: 620,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: const Text('Done'),
        ),
      ],
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: _list.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final item = _list[i];
          final isPaused = item.status == WheelCampaignStatus.paused;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.iconData, size: 16, color: item.iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${item.totalSpins} spins • ${item.participants} users • Cost: ${item.spinCost} coins',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.status.backgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.status.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: item.status.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final updatedStatus = isPaused
                        ? WheelCampaignStatus.active
                        : WheelCampaignStatus.paused;
                    final updated = item.copyWith(status: updatedStatus);
                    widget.onToggleStatus(updated);
                    setState(() {
                      _list[i] = updated;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaused ? const Color(0xFF10B981) : const Color(0xFFFF9F0A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 14),
                  label: Text(
                    isPaused ? 'Resume' : 'Pause',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
