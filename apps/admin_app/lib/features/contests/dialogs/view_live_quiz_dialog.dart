import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_quiz_item.dart';

class ViewLiveQuizDialog extends StatelessWidget {
  final LiveQuizItem item;

  const ViewLiveQuizDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: item.title,
      subtitle: '${item.category} • ${item.statusLabel}',
      iconData: Icons.podcasts_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      maxWidth: 580,
      scrollable: true,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
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
          // Description
          Text(
            item.description.isNotEmpty ? item.description : 'Live competitive showdown with instant ranking & coin distribution.',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
          ),
          const SizedBox(height: 14),

          // Key Parameters Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParam('Category', item.category),
                    _buildParam('Status', item.statusLabel),
                    _buildParam('Duration', '${item.durationMinutes} min'),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParam('Participants', item.participantsCount.toString()),
                    _buildParam('Questions', item.questionsCount.toString()),
                    _buildParam('Reward Coins', '${item.rewardCoins} pts'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top Leaderboard Preview
          const Text(
            'Top Participants / Leaderboard',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),

          _buildLeaderboardRow(rank: 1, name: 'Priya Sharma', score: '98 pts', time: '12m 40s', avatarColor: const Color(0xFF5636F5)),
          _buildLeaderboardRow(rank: 2, name: 'Amit Verma', score: '94 pts', time: '13m 15s', avatarColor: const Color(0xFF2587F8)),
          _buildLeaderboardRow(rank: 3, name: 'Rahul Kumar', score: '91 pts', time: '14m 02s', avatarColor: const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildParam(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildLeaderboardRow({
    required int rank,
    required String name,
    required String score,
    required String time,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: rank == 1 ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: rank == 1 ? const Color(0xFFD97706) : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          ),
          Text(score, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
          const SizedBox(width: 12),
          Text(time, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
