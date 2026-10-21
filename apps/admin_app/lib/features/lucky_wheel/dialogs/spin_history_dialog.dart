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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 660),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                      color: const Color(0xFFFF9F0A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.history_rounded, color: Color(0xFFFF9F0A), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authoritative Spin & Reward Ledger',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Cryptographically verified server outcomes and transaction references',
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
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              // Search bar
              SizedBox(
                height: 36,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search by user, campaign, reward, or spin ID...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 16),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ledger Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
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
            ),
              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5636F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close Ledger'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
