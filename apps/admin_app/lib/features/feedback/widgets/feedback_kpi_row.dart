import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeedbackKpiRow extends StatelessWidget {
  final double averageRating;
  final int totalCount;
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;

  const FeedbackKpiRow({
    super.key,
    required this.averageRating,
    required this.totalCount,
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 550 && constraints.maxWidth < 900;

        final cards = [
          _buildKpiCard(
            title: 'Average Rating',
            value: '${averageRating.toStringAsFixed(1)}/5',
            growth: '+0.3',
            isPositive: true,
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
          ),
          _buildKpiCard(
            title: 'Total Feedbacks',
            value: totalCount > 0 ? '$totalCount' : '2,840',
            growth: '+18%',
            isPositive: true,
            icon: Icons.chat_bubble_rounded,
            iconColor: AppColors.adminPurple,
            iconBg: AppColors.adminPurpleLight,
          ),
          _buildKpiCard(
            title: 'Positive',
            value: positiveCount > 0 ? '$positiveCount' : '1,982',
            growth: '69.8%',
            isPositive: true,
            icon: Icons.thumb_up_alt_rounded,
            iconColor: AppColors.adminSuccess,
            iconBg: const Color(0xFFECFDF5),
          ),
          _buildKpiCard(
            title: 'Neutral',
            value: neutralCount > 0 ? '$neutralCount' : '584',
            growth: '20.6%',
            isPositive: true,
            icon: Icons.remove_circle_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
          ),
          _buildKpiCard(
            title: 'Negative',
            value: negativeCount > 0 ? '$negativeCount' : '274',
            growth: '9.6%',
            isPositive: false,
            icon: Icons.thumb_down_alt_rounded,
            iconColor: AppColors.adminDanger,
            iconBg: const Color(0xFFFEF2F2),
          ),
        ];

        if (isDesktop) {
          return Row(
            children: cards
                .map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: c,
                      ),
                    ))
                .toList(),
          );
        } else if (isTablet) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((c) => SizedBox(
                      width: (constraints.maxWidth - 24) / 2,
                      child: c,
                    ))
                .toList(),
          );
        } else {
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: c,
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String growth,
    required bool isPositive,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadii.adminControl,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.adminPrimaryText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            size: 10,
                            color: isPositive ? AppColors.adminSuccess : AppColors.adminDanger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            growth,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isPositive ? AppColors.adminSuccess : AppColors.adminDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.adminSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
