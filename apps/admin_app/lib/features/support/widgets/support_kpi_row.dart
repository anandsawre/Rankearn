import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportKpiRow extends StatelessWidget {
  final int totalCount;
  final int resolvedCount;
  final int inProgressCount;
  final int openCount;
  final int onHoldCount;
  final double supportRating;

  const SupportKpiRow({
    super.key,
    required this.totalCount,
    required this.resolvedCount,
    required this.inProgressCount,
    required this.openCount,
    required this.onHoldCount,
    this.supportRating = 4.7,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1050;

        final cards = [
          _buildKpiCard(
            title: 'Total Tickets',
            value: totalCount > 0 ? '$totalCount' : '1,248',
            growth: '+18%',
            isPositive: true,
            icon: Icons.confirmation_number_outlined,
            iconColor: AppColors.adminPurple,
            iconBg: AppColors.adminPurpleLight,
          ),
          _buildKpiCard(
            title: 'Resolved',
            value: resolvedCount > 0 ? '$resolvedCount' : '846',
            growth: '+22%',
            isPositive: true,
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.adminSuccess,
            iconBg: const Color(0xFFECFDF5),
          ),
          _buildKpiCard(
            title: 'In Progress',
            value: inProgressCount > 0 ? '$inProgressCount' : '218',
            growth: '+11%',
            isPositive: true,
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
          ),
          _buildKpiCard(
            title: 'Open',
            value: openCount > 0 ? '$openCount' : '96',
            growth: '-6%',
            isPositive: false,
            icon: Icons.error_outline_rounded,
            iconColor: AppColors.adminDanger,
            iconBg: const Color(0xFFFEF2F2),
          ),
          _buildKpiCard(
            title: 'On Hold',
            value: onHoldCount > 0 ? '$onHoldCount' : '38',
            growth: '+5%',
            isPositive: true,
            icon: Icons.pause_circle_outline_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFF3E8FF),
          ),
          _buildKpiCard(
            title: 'Support Rating',
            value: '${supportRating.toStringAsFixed(1)}/5',
            growth: 'Top 5%',
            isPositive: true,
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
          ),
        ];

        if (isDesktop) {
          return Row(
            children: cards
                .map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: c,
                      ),
                    ))
                .toList(),
          );
        } else if (isTablet) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards
                .map((c) => SizedBox(
                      width: (constraints.maxWidth - 20) / 3,
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
      padding: const EdgeInsets.all(14),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadii.adminControl,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.adminPrimaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isPositive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            size: 9,
                            color: isPositive ? AppColors.adminSuccess : AppColors.adminDanger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            growth,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isPositive ? AppColors.adminSuccess : AppColors.adminDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.adminSecondaryText,
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
