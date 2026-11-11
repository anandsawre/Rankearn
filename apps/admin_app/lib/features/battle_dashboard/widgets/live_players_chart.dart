import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Players in Live Battles Chart component powered directly by the design system's [AppLineChart].
class LivePlayersChart extends StatelessWidget {
  final List<String> dates;
  final List<double> values;
  final int highlightedIndex;
  final String tooltipValue;
  final Color lineColor;
  final double height;

  const LivePlayersChart({
    super.key,
    this.dates = const ['10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM'],
    this.values = const [2800, 4100, 3700, 4900, 6100, 5800, 8742],
    this.highlightedIndex = 6,
    this.tooltipValue = '8,742 Live',
    this.lineColor = AppColors.battleAdminPurple,
    this.height = 175,
  });

  @override
  Widget build(BuildContext context) {
    return AppLineChart(
      height: height,
      dates: dates,
      values: values,
      highlightedIndex: highlightedIndex,
      tooltipDate: null,
      tooltipValue: tooltipValue,
      tooltipStyle: AppLineChartTooltipStyle.pill,
      lineColor: lineColor,
      fillColor: lineColor,
      maxY: 10000,
      yLabels: const [10000, 8000, 6000, 4000, 2000, 0],
      yLabelFormatter: (val) {
        if (val == 0) return '0';
        return '${(val / 1000).round()}K';
      },
    );
  }
}
