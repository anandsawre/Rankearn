import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class TopExamBarData {
  final String label;
  final int value;
  final Color color;

  const TopExamBarData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class TopCategoriesBarChartCard extends StatelessWidget {
  final bool fillHeight;
  final List<TopExamBarData> bars;
  final bool isLoading;

  const TopCategoriesBarChartCard({
    super.key,
    this.fillHeight = false,
    this.bars = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = bars.isEmpty
        ? 0
        : bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);

    final Widget body;
    if (isLoading && bars.isEmpty) {
      body = const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    } else if (bars.isEmpty) {
      body = const Center(
        child: Text(
          'No exam question metrics yet',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: bars.take(5).map((b) {
          final ratio = maxVal > 0 ? (b.value / maxVal) : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatNumber(b.value),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: b.value > 0 ? ratio.clamp(0.15, 1.0) : 0.06,
                        widthFactor: 0.72,
                        child: Container(
                          decoration: BoxDecoration(
                            color: b.value > 0 ? b.color : const Color(0xFFE2E8F0),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Top Exams by Questions',
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
          Expanded(child: body),
        ],
      ),
    );

    if (fillHeight) return content;
    return SizedBox(height: 165, child: content);
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      return '${s.substring(0, len - 3)},${s.substring(len - 3)}';
    }
    return n.toString();
  }
}
