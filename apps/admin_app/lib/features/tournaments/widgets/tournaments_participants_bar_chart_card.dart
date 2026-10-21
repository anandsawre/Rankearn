import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class DailyTournamentParticipantsData {
  final String dateLabel;
  final int count;

  const DailyTournamentParticipantsData({required this.dateLabel, required this.count});
}

/// Participants Trend (Last 7 Days) Card
/// Bar chart card matching the reference image.
class TournamentsParticipantsBarChartCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<DailyTournamentParticipantsData> dailyData;

  const TournamentsParticipantsBarChartCard({
    super.key,
    this.onViewAll,
    this.dailyData = const [
      DailyTournamentParticipantsData(dateLabel: 'Oct 12', count: 1200),
      DailyTournamentParticipantsData(dateLabel: 'Oct 13', count: 1850),
      DailyTournamentParticipantsData(dateLabel: 'Oct 14', count: 2400),
      DailyTournamentParticipantsData(dateLabel: 'Oct 15', count: 3100),
      DailyTournamentParticipantsData(dateLabel: 'Oct 16', count: 3900),
      DailyTournamentParticipantsData(dateLabel: 'Oct 17', count: 3300),
      DailyTournamentParticipantsData(dateLabel: 'Oct 18', count: 4100),
    ],
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
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Participants Trend (Last 7 Days)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
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
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bar Chart with Y-Axis and X-Axis
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-Axis labels (4k, 3k, 2k, 1k, 0)
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('4k', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                    Text('3k', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                    Text('2k', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                    Text('1k', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                    Text('0', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(width: 8),

                // Bars & Date labels
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
      ),
    );
  }

  Widget _buildBar(DailyTournamentParticipantsData data) {
    const maxVal = 4500.0;
    final normalized = (data.count / maxVal).clamp(0.08, 1.0);
    const chartHeight = 60.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: '${data.dateLabel}: ${data.count} participants',
          child: Container(
            width: 14,
            height: chartHeight * normalized,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6B4EFF),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B4EFF).withAlpha(40),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          data.dateLabel,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
