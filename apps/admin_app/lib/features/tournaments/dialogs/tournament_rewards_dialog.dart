import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/tournament_item.dart';

class TournamentRewardsDialog extends StatelessWidget {
  final TournamentItem? tournament;

  const TournamentRewardsDialog({super.key, this.tournament});

  @override
  Widget build(BuildContext context) {
    final pool = tournament?.prizePool ?? 10000;
    final tiers = [
      {'rank': 'Rank 1', 'percentage': '50%', 'amount': '₹${(pool * 0.50).toInt()}', 'color': const Color(0xFFF59E0B)},
      {'rank': 'Rank 2', 'percentage': '25%', 'amount': '₹${(pool * 0.25).toInt()}', 'color': const Color(0xFF94A3B8)},
      {'rank': 'Rank 3', 'percentage': '15%', 'amount': '₹${(pool * 0.15).toInt()}', 'color': const Color(0xFFB45309)},
      {'rank': 'Rank 4 - 10', 'percentage': '10%', 'amount': '₹${(pool * 0.10).toInt()}', 'color': const Color(0xFF5636F5)},
    ];

    return AppModalDialog(
      title: 'Prize Pool & Rewards',
      subtitle: 'Total Reward Pool: ₹$pool • Leaderboard payouts',
      iconData: Icons.card_giftcard_rounded,
      gradientColors: const [Color(0xFF00B368), Color(0xFF10B981)],
      maxWidth: 520,
      scrollable: true,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B368),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiers.length,
              separatorBuilder: (_, index) => const Divider(height: 18, color: Color(0xFFE2E8F0)),
              itemBuilder: (context, i) {
                final tier = tiers[i];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: tier['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tier['rank'] as String,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    Text(
                      tier['percentage'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    Text(
                      tier['amount'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
