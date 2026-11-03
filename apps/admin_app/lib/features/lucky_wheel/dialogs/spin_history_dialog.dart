import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/lucky_wheel_item.dart';

class SpinHistoryDialog extends StatefulWidget {
  const SpinHistoryDialog({super.key});

  @override
  State<SpinHistoryDialog> createState() => _SpinHistoryDialogState();
}

class _SpinHistoryDialogState extends State<SpinHistoryDialog> {
  String _search = '';

  final List<WheelSpinRecord> _records = [
    WheelSpinRecord(
      id: 'SPIN-98214',
      campaignId: 'wheel-camp-001',
      campaignTitle: 'Daily Spin Rewards',
      userName: 'Rahul Sharma',
      userAvatar: 'RS',
      rewardLabel: '50 Coins',
      rewardType: WheelRewardType.coins,
      rewardValue: 50,
      timestamp: DateTime(2026, 10, 21, 18, 42),
      status: 'Credited',
      transactionId: 'TXN-COIN-49210',
    ),
    WheelSpinRecord(
      id: 'SPIN-98213',
      campaignId: 'wheel-camp-002',
      campaignTitle: 'Festive Mega Spin',
      userName: 'Priya Patel',
      userAvatar: 'PP',
      rewardLabel: '₹50 Cashback',
      rewardType: WheelRewardType.cashback,
      rewardValue: 50,
      timestamp: DateTime(2026, 10, 21, 18, 15),
      status: 'Credited',
      transactionId: 'TXN-CASH-19208',
    ),
    WheelSpinRecord(
      id: 'SPIN-98212',
      campaignId: 'wheel-camp-001',
      campaignTitle: 'Daily Spin Rewards',
      userName: 'Aman Verma',
      userAvatar: 'AV',
      rewardLabel: '100 Coins',
      rewardType: WheelRewardType.coins,
      rewardValue: 100,
      timestamp: DateTime(2026, 10, 21, 17, 50),
      status: 'Credited',
      transactionId: 'TXN-COIN-49209',
    ),
    WheelSpinRecord(
      id: 'SPIN-98211',
      campaignId: 'wheel-camp-003',
      campaignTitle: 'New User Bonus Spin',
      userName: 'Sneha Rao',
      userAvatar: 'SR',
      rewardLabel: 'Free Re-Spin',
      rewardType: WheelRewardType.gift,
      rewardValue: 10,
      timestamp: DateTime(2026, 10, 21, 17, 12),
      status: 'Redeemed',
      transactionId: 'TXN-GIFT-83102',
    ),
    WheelSpinRecord(
      id: 'SPIN-98210',
      campaignId: 'wheel-camp-001',
      campaignTitle: 'Daily Spin Rewards',
      userName: 'Vikas Kumar',
      userAvatar: 'VK',
      rewardLabel: 'Better Luck Next Time',
      rewardType: WheelRewardType.noPrize,
      rewardValue: 0,
      timestamp: DateTime(2026, 10, 21, 16, 40),
      status: 'Completed',
      transactionId: 'N/A',
    ),
    WheelSpinRecord(
      id: 'SPIN-98209',
      campaignId: 'wheel-camp-004',
      campaignTitle: 'Weekend Lucky Draw',
      userName: 'Ananya Gupta',
      userAvatar: 'AG',
      rewardLabel: '20% Discount Coupon',
      rewardType: WheelRewardType.discount,
      rewardValue: 20,
      timestamp: DateTime(2026, 10, 21, 16, 10),
      status: 'Issued',
      transactionId: 'CPN-LUCKY20-891',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _records.where((r) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return r.userName.toLowerCase().contains(q) ||
          r.campaignTitle.toLowerCase().contains(q) ||
          r.rewardLabel.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList();

    return AppModalDialog(
      title: 'Authoritative Spin & Reward Ledger',
      subtitle: 'Cryptographically verified server outcomes and transaction references',
      iconData: Icons.history_rounded,
      gradientColors: const [Color(0xFFFF9F0A), Color(0xFFFBBF24)],
      maxWidth: 820,
      maxHeight: 680,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: const Text('Close Ledger'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          SizedBox(
            height: 40,
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: AppModalDialog.inputDecoration(
                'Search by user, campaign, reward, or spin ID...',
                prefixIcon: const Icon(Icons.search_rounded, size: 16),
                focusColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Ledger Table
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                headingRowHeight: 38,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 52,
                horizontalMargin: 12,
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Spin ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Participant', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Campaign', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Outcome Reward', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Ledger Txn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                ],
                rows: filtered.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF5636F5),
                              child: Text(r.userAvatar, style: const TextStyle(fontSize: 9, color: Colors.white)),
                            ),
                            const SizedBox(width: 6),
                            Text(r.userName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      DataCell(Text(r.campaignTitle, style: const TextStyle(fontSize: 11.5))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: r.rewardType.backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r.rewardLabel,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: r.rewardType.color),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.status,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.transactionId,
                          style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
