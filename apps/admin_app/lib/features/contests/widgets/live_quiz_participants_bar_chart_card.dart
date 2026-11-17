import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class DailyParticipantsData {
  final String dateLabel;
  final int count;

  const DailyParticipantsData({required this.dateLabel, required this.count});
}

/// Participants Trend Card
/// Bar chart card showing real participant metrics or clean empty state.
class LiveQuizParticipantsBarChartCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<DailyParticipantsData> dailyData;

  const LiveQuizParticipantsBarChartCard({
    super.key,
    this.onViewAll,
    this.dailyData = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Icon + Title + "View All"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5636F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Participants Trend',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewAll != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onViewAll,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5636F5),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Bar Chart with Y-Axis or Empty State
          if (dailyData.isEmpty)
            const SizedBox(
              height: 90,
              child: Center(
                child: Text(
                  'No participant activity recorded yet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Y-Axis Labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Max', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                      Text('0', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Bars Row
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: dailyData.map((d) => Expanded(child: _buildBar(d))).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(DailyParticipantsData data) {
    final maxCount = dailyData.map((d) => d.count).fold<int>(1, (a, b) => a > b ? a : b);
    final normalized = (data.count / maxCount).clamp(0.08, 1.0);
    const chartHeight = 68.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rounded Bar
        Container(
          width: 14,
          height: chartHeight * normalized,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFF8C7AE6),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withAlpha(45),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Date Label
        Text(
          data.dateLabel,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
