import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class DifficultyWiseBarChartCard extends StatelessWidget {
  final bool fillHeight;
  final int easyCount;
  final int mediumCount;
  final int hardCount;
  final int expertCount;

  const DifficultyWiseBarChartCard({
    super.key,
    this.fillHeight = false,
    this.easyCount = 3624,
    this.mediumCount = 4128,
    this.hardCount = 1680,
    this.expertCount = 410,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF0084FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Difficulty Wise Questions',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101A3A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4 Vertical Bars
          Builder(
            builder: (context) {
              final maxCount = [easyCount, mediumCount, hardCount, expertCount]
                  .reduce((a, b) => a > b ? a : b);
              const availableHeight = 44.0;

              return Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBar(
                      label: 'Easy',
                      count: easyCount,
                      maxCount: maxCount,
                      availableHeight: availableHeight,
                      color: const Color(0xFF10B981),
                    ),
                    _buildBar(
                      label: 'Medium',
                      count: mediumCount,
                      maxCount: maxCount,
                      availableHeight: availableHeight,
                      color: const Color(0xFFF59E0B),
                    ),
                    _buildBar(
                      label: 'Hard',
                      count: hardCount,
                      maxCount: maxCount,
                      availableHeight: availableHeight,
                      color: const Color(0xFFF43F5E),
                    ),
                    _buildBar(
                      label: 'Expert',
                      count: expertCount,
                      maxCount: maxCount,
                      availableHeight: availableHeight,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    if (fillHeight) return content;
    return SizedBox(height: 125, child: content);
  }

  Widget _buildBar({
    required String label,
    required int count,
    required int maxCount,
    required double availableHeight,
    required Color color,
  }) {
    final double fraction = maxCount > 0 ? (count / maxCount).clamp(0.12, 1.0) : 0.2;
    final double barHeight = availableHeight * fraction;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatNumber(count),
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101A3A),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 32,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      final part1 = s.substring(0, len - 3);
      final part2 = s.substring(len - 3);
      return '$part1,$part2';
    }
    return n.toString();
  }
}
