import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class TopCategoriesBarChartCard extends StatelessWidget {
  final bool fillHeight;

  const TopCategoriesBarChartCard({
    super.key,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bars = [
      _BarData(label: 'Competitive\nExams', value: 4850, valueStr: '4,850', color: const Color(0xFF0084FF)),
      _BarData(label: 'Entrance\nExams', value: 3420, valueStr: '3,420', color: const Color(0xFFF43F5E)),
      _BarData(label: 'School\nEducation', value: 2340, valueStr: '2,340', color: const Color(0xFFF59E0B)),
      _BarData(label: 'General\nAwareness', value: 2100, valueStr: '2,100', color: const Color(0xFF8B5CF6)),
      _BarData(label: 'State Level\nExams', value: 1950, valueStr: '1,950', color: const Color(0xFF10B981)),
    ];

    const maxVal = 4850.0;

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
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Top Categories by Questions',
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
          const SizedBox(height: 12),

          // Bars Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: bars.map((b) {
                final ratio = b.value / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label on top
                        Text(
                          b.valueStr,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // The Bar
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: ratio.clamp(0.15, 1.0),
                              widthFactor: 0.72,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: b.color,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Category Name underneath
                        SizedBox(
                          height: 24,
                          child: Text(
                            b.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );

    if (fillHeight) return content;
    return SizedBox(height: 155, child: content);
  }
}

class _BarData {
  final String label;
  final int value;
  final String valueStr;
  final Color color;

  const _BarData({
    required this.label,
    required this.value,
    required this.valueStr,
    required this.color,
  });
}
