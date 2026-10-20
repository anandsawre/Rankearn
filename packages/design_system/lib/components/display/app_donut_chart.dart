import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';

/// Data model representing a single slice in the Donut Chart.
class DonutSlice {
  final String label;
  final double percentage;
  final Color color;
  final int? count;

  const DonutSlice({
    required this.label,
    required this.percentage,
    required this.color,
    this.count,
  });

  /// Factory helper to build from a record for backwards compatibility.
  factory DonutSlice.fromRecord(({String name, double percentage, Color color}) record) {
    return DonutSlice(
      label: record.name,
      percentage: record.percentage,
      color: record.color,
    );
  }
}

/// A highly reusable, responsive Donut Chart with rounded pill segments,
/// center metric label, and side legend matching the Rankearn design system.
///
/// Features:
/// - Rounded pill-cap arcs (`StrokeCap.round`) by default
/// - Automatic responsive stroke width (22px large, 13.5px compact)
/// - Center metric count & "Total" label with comma formatting
/// - Side legend with circular dot indicator, label, and bold percentage
class AppDonutChart extends StatelessWidget {
  final List<DonutSlice> slices;
  final int totalCount;
  final String totalLabel;
  final double? chartSize;
  final double? strokeWidth;
  final StrokeCap strokeCap;
  final double gapAngle;
  final TextStyle? totalNumberStyle;
  final TextStyle? totalLabelStyle;
  final TextStyle? legendLabelStyle;
  final TextStyle? legendPercentageStyle;
  final double legendSpacing;
  final MainAxisAlignment legendAlignment;
  final bool fillHeight;

  const AppDonutChart({
    super.key,
    required this.slices,
    this.totalCount = 0,
    this.totalLabel = 'Total',
    this.chartSize,
    this.strokeWidth,
    this.strokeCap = StrokeCap.round,
    this.gapAngle = 0.035,
    this.totalNumberStyle,
    this.totalLabelStyle,
    this.legendLabelStyle,
    this.legendPercentageStyle,
    this.legendSpacing = 12.0,
    this.legendAlignment = MainAxisAlignment.center,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = chartSize ?? 92.0;
    final isLarge = effectiveSize >= 120.0;
    final effectiveStroke = strokeWidth ?? (isLarge ? 22.0 : 13.5);

    final donutVisual = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(effectiveSize, effectiveSize),
            painter: _DonutChartPainter(
              slices: slices,
              strokeWidth: effectiveStroke,
              strokeCap: strokeCap,
              gapAngle: gapAngle,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatNumber(totalCount),
                style: totalNumberStyle ??
                    TextStyle(
                      fontSize: isLarge ? 22 : 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
              ),
              Text(
                totalLabel,
                style: totalLabelStyle ??
                    TextStyle(
                      fontSize: isLarge ? 12 : 9.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );

    final legendItems = slices.map((s) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: fillHeight ? 1.5 : (isLarge ? 3.5 : 2.2)),
        child: Row(
          children: [
            Container(
              width: isLarge ? 8 : 7.5,
              height: isLarge ? 8 : 7.5,
              decoration: BoxDecoration(
                color: s.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                s.label,
                style: legendLabelStyle ??
                    TextStyle(
                      fontSize: isLarge ? 11.5 : 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              s.count != null
                  ? '${s.percentage.toInt()}% (${_formatNumber(s.count!)})'
                  : '${s.percentage.toInt()}%',
              style: legendPercentageStyle ??
                  TextStyle(
                    fontSize: isLarge ? 11.5 : 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        donutVisual,
        SizedBox(width: legendSpacing),
        Expanded(
          child: Column(
            mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: fillHeight ? MainAxisAlignment.spaceEvenly : legendAlignment,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: legendItems,
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

/// A card container wrapper around [AppDonutChart], featuring standard Rankearn borders,
/// elevation, circular header badge icon, and title.
class AppDonutChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final List<DonutSlice> slices;
  final int totalCount;
  final String totalLabel;
  final double? height;
  final bool fillHeight;
  final double? chartSize;
  final double? strokeWidth;
  final StrokeCap strokeCap;
  final Widget? trailingHeader;

  const AppDonutChartCard({
    super.key,
    required this.title,
    this.icon = Icons.pie_chart_rounded,
    this.iconBg = const Color(0xFF3B82F6),
    required this.slices,
    this.totalCount = 0,
    this.totalLabel = 'Total',
    this.height,
    this.fillHeight = false,
    this.chartSize,
    this.strokeWidth,
    this.strokeCap = StrokeCap.round,
    this.trailingHeader,
  });

  @override
  Widget build(BuildContext context) {
    final isExpandedMode = fillHeight || height != null;

    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
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
          // Header Row with Circular Badge Icon
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingHeader != null) trailingHeader!,
            ],
          ),
          const SizedBox(height: 10),

          // Donut Chart + Legend
          if (isExpandedMode)
            Expanded(
              child: AppDonutChart(
                slices: slices,
                totalCount: totalCount,
                totalLabel: totalLabel,
                chartSize: chartSize,
                strokeWidth: strokeWidth,
                strokeCap: strokeCap,
                fillHeight: true,
              ),
            )
          else
            AppDonutChart(
              slices: slices,
              totalCount: totalCount,
              totalLabel: totalLabel,
              chartSize: chartSize,
              strokeWidth: strokeWidth,
              strokeCap: strokeCap,
              fillHeight: false,
            ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final double gapAngle;

  _DonutChartPainter({
    required this.slices,
    required this.strokeWidth,
    required this.strokeCap,
    required this.gapAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - (strokeWidth / 2);

    final totalPct = slices.fold<double>(0, (sum, s) => sum + s.percentage);
    if (totalPct <= 0) return;

    double startAngle = -math.pi / 2;
    for (final s in slices) {
      final sweepAngle = (s.percentage / totalPct) * (2 * math.pi) - gapAngle;

      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;

      if (sweepAngle > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (gapAngle / 2),
          sweepAngle,
          false,
          paint,
        );
      }

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
