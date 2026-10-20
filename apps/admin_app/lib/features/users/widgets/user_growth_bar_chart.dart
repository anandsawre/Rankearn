import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class UserGrowthBarChartCard extends StatelessWidget {
  final bool fillHeight;

  const UserGrowthBarChartCard({
    super.key,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bars = [
      _GrowthBar(label: 'Oct 12', value: 340),
      _GrowthBar(label: 'Oct 13', value: 520),
      _GrowthBar(label: 'Oct 14', value: 760),
      _GrowthBar(label: 'Oct 15', value: 1040),
      _GrowthBar(label: 'Oct 16', value: 1250),
      _GrowthBar(label: 'Oct 17', value: 1410),
      _GrowthBar(label: 'Oct 18', value: 1580),
    ];

    const double maxY = 1600.0;
    final yLabels = ['1,600', '1,200', '800', '400', '0'];

    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4EFF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'User Growth (Last 7 Days)',
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
          const SizedBox(height: 14),

          // Chart Area: Y-Axis Labels + Bars
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yLabels.map((lbl) {
                    return Text(
                      lbl,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 8),

                // Bars with Grid Lines
                Expanded(
                  child: Stack(
                    children: [
                      // Subtle Horizontal Grid Lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          return Container(
                            height: 1,
                            color: const Color(0xFFF1F5F9),
                          );
                        }),
                      ),

                      // Bars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: bars.map((bar) {
                          final ratio = (bar.value / maxY).clamp(0.05, 1.0);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: ratio,
                                        widthFactor: 0.68,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFF7C3AED),
                                                Color(0xFF5636F5),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    bar.label,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (fillHeight) {
      return Expanded(child: content);
    }
    return SizedBox(height: 195, child: content);
  }
}

class _GrowthBar {
  final String label;
  final int value;

  const _GrowthBar({required this.label, required this.value});
}
