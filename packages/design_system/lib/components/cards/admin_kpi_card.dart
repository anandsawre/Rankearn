import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';

/// A tokenized KPI metric card component for the Rankearn Admin Dashboard.
/// Follows centralized design tokens ([AppColors], [AppTypography], [AppRadii]).
class AdminKpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String value;
  final String label;
  final String? growth;
  final bool isGrowthPositive;
  final VoidCallback? onTap;

  const AdminKpiCard({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconBgColor,
    required this.value,
    required this.label,
    this.growth,
    this.isGrowthPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconBg = iconBgColor ?? iconColor.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: AppRadii.adminControl,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.adminControl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Squircle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: AppRadii.adminControl,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 10),

              // 2. Metric Value (with optional growth badge)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: AppTypography.adminMetricValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (growth != null && growth!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isGrowthPositive
                            ? AppColors.adminSuccessLight
                            : AppColors.adminDangerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGrowthPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 11,
                            color: isGrowthPositive
                                ? AppColors.adminSuccess
                                : AppColors.adminDanger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            growth!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isGrowthPositive
                                  ? AppColors.adminSuccess
                                  : AppColors.adminDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),

              // 3. Metric Label
              Text(
                label,
                style: AppTypography.adminMetricLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
