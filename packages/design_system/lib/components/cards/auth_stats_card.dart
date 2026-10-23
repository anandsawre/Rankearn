import 'package:flutter/material.dart';

/// Reusable 3-metric statistics banner for Authentication Hero
class AuthStatsCard extends StatelessWidget {
  final String activeLearners;
  final String practiceQuestions;
  final String userRating;

  const AuthStatsCard({
    super.key,
    this.activeLearners = '1L+',
    this.practiceQuestions = '10,000+',
    this.userRating = '4.8',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2EBF8),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0610194F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 460;

          if (isCompact) {
            return Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 12,
              runSpacing: 10,
              children: [
                _buildStatItem(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF2563EB),
                  value: activeLearners,
                  label: 'Active Learners',
                ),
                _buildStatItem(
                  icon: Icons.article_rounded,
                  iconColor: const Color(0xFF2563EB),
                  value: practiceQuestions,
                  label: 'Practice Questions',
                ),
                _buildStatItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: userRating,
                  label: 'User Rating',
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 10,
                child: _buildStatItem(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF2563EB),
                  value: activeLearners,
                  label: 'Active Learners',
                ),
              ),
              _buildDivider(),
              Expanded(
                flex: 12,
                child: _buildStatItem(
                  icon: Icons.article_rounded,
                  iconColor: const Color(0xFF2563EB),
                  value: practiceQuestions,
                  label: 'Practice Questions',
                ),
              ),
              _buildDivider(),
              Expanded(
                flex: 9,
                child: _buildStatItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: userRating,
                  label: 'User Rating',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFE2EBF8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10194F),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
