import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CategoriesMetricsRow extends StatelessWidget {
  final int totalCategories;
  final int activeCategories;
  final int draftCategories;
  final int archivedCategories;
  final int totalSubjects;

  const CategoriesMetricsRow({
    super.key,
    this.totalCategories = 48,
    this.activeCategories = 42,
    this.draftCategories = 4,
    this.archivedCategories = 2,
    this.totalSubjects = 128,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Metric Card Configs
        final cards = [
          _MetricCardData(
            icon: Icons.folder_rounded,
            iconBg: const Color(0xFF0084FF),
            title: 'Total Categories',
            value: totalCategories.toString(),
            badgeText: '+12%',
            badgePositive: true,
            subtext: '+6 this month',
            sparklineColor: const Color(0xFF0084FF),
            sparklineData: [20, 24, 22, 28, 35, 42, 48],
          ),
          _MetricCardData(
            icon: Icons.layers_rounded,
            iconBg: const Color(0xFF10B981),
            title: 'Active Categories',
            value: activeCategories.toString(),
            badgeText: '+10%',
            badgePositive: true,
            subtext: '+5 this month',
            sparklineColor: const Color(0xFF10B981),
            sparklineData: [18, 22, 26, 30, 36, 40, 42],
          ),
          _MetricCardData(
            icon: Icons.description_rounded,
            iconBg: const Color(0xFFF59E0B),
            title: 'Draft Categories',
            value: draftCategories.toString(),
            badgeText: '-20%',
            badgePositive: false,
            subtext: '-1 this month',
            sparklineColor: const Color(0xFFF59E0B),
            sparklineData: [8, 7, 9, 6, 5, 4, 4],
          ),
          _MetricCardData(
            icon: Icons.archive_rounded,
            iconBg: const Color(0xFF8B5CF6),
            title: 'Archived Categories',
            value: archivedCategories.toString(),
            badgeText: '+0%',
            badgePositive: true,
            subtext: '0 this month',
            sparklineColor: const Color(0xFF8B5CF6),
            sparklineData: [2, 2, 2, 3, 2, 2, 2],
          ),
          _MetricCardData(
            icon: Icons.article_rounded,
            iconBg: const Color(0xFFF43F5E),
            title: 'Total Subjects',
            value: totalSubjects.toString(),
            badgeText: '+18%',
            badgePositive: true,
            subtext: '+20 this month',
            sparklineColor: const Color(0xFFF43F5E),
            sparklineData: [60, 75, 85, 95, 110, 120, 128],
          ),
        ];

        if (width >= 1050) {
          // 5 cards in 1 row with equal width
          return Row(
            children: cards.asMap().entries.map((entry) {
              final idx = entry.key;
              final data = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: idx == 0 ? 0 : 7,
                    right: idx == cards.length - 1 ? 0 : 7,
                  ),
                  child: _buildCard(data),
                ),
              );
            }).toList(),
          );
        } else if (width >= 650) {
          // 2 or 3 in a grid
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((c) => SizedBox(
                      width: (width - 24) / 2,
                      child: _buildCard(c),
                    ))
                .toList(),
          );
        } else {
          // mobile scroll or vertical list
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCard(c),
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildCard(_MetricCardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icon Container on the Left
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),

          // 2. Text & Data on the Right of the Icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Value + Badge Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data.value,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101A3A),
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: data.badgePositive
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            data.badgePositive
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 9,
                            color: data.badgePositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF43F5E),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            data.badgeText,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: data.badgePositive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF43F5E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Subtext
                Text(
                  data.subtext,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Sparkline on the Far Right
          const SizedBox(width: 6),
          SizedBox(
            width: 48,
            height: 24,
            child: CustomPaint(
              size: const Size(48, 24),
              painter: _MiniSparklinePainter(
                data: data.sparklineData,
                lineColor: data.sparklineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCardData {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String value;
  final String badgeText;
  final bool badgePositive;
  final String subtext;
  final Color sparklineColor;
  final List<double> sparklineData;

  const _MetricCardData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.badgeText,
    required this.badgePositive,
    required this.subtext,
    required this.sparklineColor,
    required this.sparklineData,
  });
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _MiniSparklinePainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) => true;
}
