import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class LivePlayersChart extends StatelessWidget {
  final List<String> dates;
  final List<double> values;
  final int? highlightedIndex;
  final String? tooltipValue;
  final Color lineColor;
  final double height;
  final String emptyText;

  const LivePlayersChart({
    super.key,
    this.dates = const [],
    this.values = const [],
    this.highlightedIndex,
    this.tooltipValue,
    this.lineColor = AppColors.battleAdminPurple,
    this.height = 175,
    this.emptyText = 'No battle activity recorded yet',
  });

  @override
  Widget build(BuildContext context) {
    final safeHighlight = (highlightedIndex != null &&
            highlightedIndex! >= 0 &&
            highlightedIndex! < values.length)
        ? highlightedIndex
        : null;

    return AppLineChart(
      dates: dates,
      values: values,
      highlightedIndex: safeHighlight,
      tooltipValue: tooltipValue,
      tooltipStyle: AppLineChartTooltipStyle.pill,
      lineColor: lineColor,
      height: height,
      emptyText: emptyText,
    );
  }
}
