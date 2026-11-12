import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class UserGrowthBarPoint {
  final String label;
  final int value;

  const UserGrowthBarPoint({required this.label, required this.value});
}

class UserGrowthBarChartCard extends StatelessWidget {
  final bool fillHeight;
  final List<UserGrowthBarPoint> bars;
  final bool isLoading;

  const UserGrowthBarChartCard({
    super.key,
    this.fillHeight = false,
    this.bars = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxRaw = bars.isEmpty
        ? 0
        : bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final int maxY = math.max(4, ((maxRaw + 3) ~/ 4) * 4);
    final yLabels = [
      '$maxY',
      '${(maxY * 0.75).round()}',
      '${(maxY * 0.5).round()}',
      '${(maxY * 0.25).round()}',
      '0',
    ];

    final Widget body;
    if (isLoading && bars.isEmpty) {
      body = const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    } else if (bars.isEmpty || bars.every((b) => b.value == 0)) {
      body = const Center(
        child: Text(
          'No new user signups in last 7 days',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: yLabels
                .map(
                  (lbl) => Text(
                    lbl,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (_) => Container(height: 1, color: const Color(0xFFF1F5F9)),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: bars.map((bar) {
                    final ratio = bar.value > 0 ? (bar.value / maxY).clamp(0.08, 1.0) : 0.03;
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
                                    decoration: BoxDecoration(
                                      gradient: bar.value > 0
                                          ? const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [Color(0xFF7C3AED), Color(0xFF5636F5)],
                                            )
                                          : null,
                                      color: bar.value > 0 ? null : const Color(0xFFE2E8F0),
                                      borderRadius: const BorderRadius.vertical(
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
                              overflow: TextOverflow.ellipsis,
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
      );
    }

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
          Expanded(child: body),
        ],
      ),
    );

    if (fillHeight) {
      return Expanded(child: content);
    }
    return SizedBox(height: 195, child: content);
  }
}
