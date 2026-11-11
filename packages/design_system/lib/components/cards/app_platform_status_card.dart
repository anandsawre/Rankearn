import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';

/// Data model for an individual service status row in [AppPlatformStatusCard].
class PlatformServiceItem {
  final String name;
  final String status;
  final bool isHealthy;

  const PlatformServiceItem({
    required this.name,
    this.status = 'Operational',
    this.isHealthy = true,
  });
}

/// Data model for platform health metrics (e.g. Uptime, Response Time, Last Updated).
class PlatformMetricItem {
  final IconData icon;
  final String label;
  final String value;

  const PlatformMetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Centralized, theme-tokenized Platform Status Card Component.
///
/// Displays real-time operational status of backend services, health badge,
/// and infrastructure metrics (uptime, latency, last sync) with Rankearn design tokens.
class AppPlatformStatusCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final bool isAllOperational;
  final List<PlatformServiceItem> services;
  final List<PlatformMetricItem> metrics;
  final double? height;
  final bool fillHeight;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const AppPlatformStatusCard({
    super.key,
    this.title = 'Platform Status',
    this.badgeText = 'Checking...',
    this.isAllOperational = true,
    this.services = const [],
    this.metrics = const [],
    this.height = 300,
    this.fillHeight = false,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isExpandedMode = fillHeight || height != null;

    Widget content;
    if (isLoading && services.isEmpty) {
      content = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
          ),
        ),
      );
    } else if (services.isEmpty && metrics.isEmpty) {
      content = Center(
        child: Text(
          'No telemetry checks available',
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      );
    } else {
      final servicesColumn = Column(
        mainAxisSize: MainAxisSize.min,
        children: services.map((svc) {
          final isHealthy = svc.isHealthy;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isHealthy ? Icons.check_circle_rounded : Icons.error_rounded,
                        color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 15.5,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          svc.name,
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  svc.status,
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: isExpandedMode ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (isExpandedMode)
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: servicesColumn,
              ),
            )
          else
            servicesColumn,
          if (metrics.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(color: AppColors.borderSubtle, height: 1),
            ),
            ...metrics.map((metric) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            metric.icon,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              metric.label,
                              style: TextStyle(
                                fontFamily: AppTypography.fontHeading,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      metric.value,
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      );
    }

    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: isExpandedMode ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // ── Header Bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isAllOperational
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isAllOperational
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFECACA),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isAllOperational
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (isExpandedMode) Expanded(child: content) else content,
        ],
      ),
    );
  }
}

