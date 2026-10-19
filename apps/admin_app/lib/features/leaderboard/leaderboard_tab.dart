import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  String _timeFilter = 'daily'; // 'daily', 'weekly', 'monthly'

  final List<Map<String, dynamic>> _rankings = [
    {
      'rank': 1,
      'name': 'Pooja Verma',
      'email': 'pooja.verma@gmail.com',
      'score': 2950,
      'accuracy': '94.2%',
      'tests': 42,
      'location': 'Patna, Bihar',
      'coinsWon': '5,000 Coins',
    },
    {
      'rank': 2,
      'name': 'Manish Kumar',
      'email': 'manish.k99@yahoo.com',
      'score': 2820,
      'accuracy': '91.8%',
      'tests': 38,
      'location': 'Gaya, Bihar',
      'coinsWon': '3,000 Coins',
    },
    {
      'rank': 3,
      'name': 'Anjali Kumari',
      'email': 'anjali.k@gmail.com',
      'score': 2740,
      'accuracy': '89.5%',
      'tests': 35,
      'location': 'Muzaffarpur, Bihar',
      'coinsWon': '1,500 Coins',
    },
    {
      'rank': 4,
      'name': 'Vikram Rathore',
      'email': 'vikram.r@gmail.com',
      'score': 2610,
      'accuracy': '88.0%',
      'tests': 31,
      'location': 'Bhagalpur, Bihar',
      'coinsWon': '500 Coins',
    },
    {
      'rank': 5,
      'name': 'Sneha Patel',
      'email': 'sneha.patel@gmail.com',
      'score': 2540,
      'accuracy': '86.4%',
      'tests': 29,
      'location': 'Darbhanga, Bihar',
      'coinsWon': '250 Coins',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Header
          _buildMasterHeader(),
          const SizedBox(height: 24),

          // Podium for Top 3 (Rank 2, Rank 1, Rank 3)
          _buildPodiumSection(),
          const SizedBox(height: 24),

          // All Rankings Table
          _buildRankingsTable(),
        ],
      ),
    );
  }

  Widget _buildMasterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: AppRadii.borderLg,
                  boxShadow: const [
                    BoxShadow(color: Color(0x30F59E0B), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.leaderboard, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All-India Leaderboard & Standings', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Real-time merit rankings, accuracy ratios, and tournament performance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),

          // Time Filter Pills
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildTimePill('Today (Daily)', 'daily'),
                _buildTimePill('This Week', 'weekly'),
                _buildTimePill('Monthly (All-Time)', 'monthly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePill(String label, String value) {
    final isSelected = _timeFilter == value;
    return InkWell(
      onTap: () => setState(() => _timeFilter = value),
      borderRadius: AppRadii.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: AppRadii.borderMd,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSection() {
    if (_rankings.length < 3) return const SizedBox.shrink();
    final r1 = _rankings[0];
    final r2 = _rankings[1];
    final r3 = _rankings[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2 (Silver)
        Expanded(child: _buildPodiumCard(r2, 2, const Color(0xFF94A3B8), 180)),
        const SizedBox(width: 16),
        // Rank 1 (Gold)
        Expanded(child: _buildPodiumCard(r1, 1, const Color(0xFFF59E0B), 220)),
        const SizedBox(width: 16),
        // Rank 3 (Bronze)
        Expanded(child: _buildPodiumCard(r3, 3, const Color(0xFFB45309), 160)),
      ],
    );
  }

  Widget _buildPodiumCard(Map<String, dynamic> candidate, int rank, Color color, double height) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: color.withAlpha(80), width: rank == 1 ? 2.0 : 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: rank == 1 ? 28 : 22,
            backgroundColor: color.withAlpha(30),
            child: Text(
              candidate['name'][0],
              style: TextStyle(color: color, fontSize: rank == 1 ? 20 : 16, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: AppRadii.borderPill,
            ),
            child: Text(
              'RANK #$rank',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(candidate['name'], style: AppTypography.titleMedium, textAlign: TextAlign.center),
          Text(candidate['location'], style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          Text(
            '${candidate['score']} XP',
            style: TextStyle(fontSize: rank == 1 ? 18 : 15, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
          ),
          Text(
            '${candidate['accuracy']} Accuracy • ${candidate['tests']} Tests',
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Complete Standings Roster', style: AppTypography.titleLarge),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rankings.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
            itemBuilder: (context, idx) {
              final r = _rankings[idx];
              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: idx < 3 ? AppColors.brandPrimary.withAlpha(20) : const Color(0xFFF1F5F9),
                    borderRadius: AppRadii.borderMd,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${r['rank']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: idx < 3 ? AppColors.brandPrimaryDark : const Color(0xFF64748B),
                    ),
                  ),
                ),
                title: Text(r['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('${r['location']} • Accuracy: ${r['accuracy']} • ${r['tests']} Tests', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${r['score']} XP', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text(r['coinsWon'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
