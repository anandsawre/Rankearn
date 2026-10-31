import 'package:flutter/material.dart';

/// Two compact statistic cards matching the reference:
/// 1. Today's Spins (Wheel icon, 1 / 3)
/// 2. Next Spin In (Clock icon, 14h 25m)
class SpinStatsRow extends StatelessWidget {
  final int spinsUsedToday;
  final int maxSpinsPerDay;
  final String formattedCooldown;

  const SpinStatsRow({
    super.key,
    required this.spinsUsedToday,
    this.maxSpinsPerDay = 5,
    required this.formattedCooldown,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Today's Spins
        Expanded(
          child: _buildStatCard(
            icon: Icons.cyclone_rounded,
            iconColor: const Color(0xFFC026D3), // Vibrant magenta/purple
            iconBg: const Color(0xFFFDF4FF),
            label: "Today's Spins",
            value: '$spinsUsedToday / $maxSpinsPerDay',
          ),
        ),
        const SizedBox(width: 12),

        // 2. Next Spin In
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time_filled_rounded,
            iconColor: const Color(0xFF059669), // Emerald green
            iconBg: const Color(0xFFECFDF5),
            label: 'Next Spin In',
            value: formattedCooldown,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDFECFA), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0610194F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),

          // Label & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF586B9B),
                    height: 1.15,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10194F),
                    letterSpacing: -0.2,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
