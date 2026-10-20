import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class QuestionsMetricsRow extends StatelessWidget {
  final int totalQuestions;
  final int activeQuestions;
  final int draftQuestions;
  final int archivedQuestions;
  final int questionSets;

  const QuestionsMetricsRow({
    super.key,
    this.totalQuestions = 9842,
    this.activeQuestions = 8936,
    this.draftQuestions = 542,
    this.archivedQuestions = 364,
    this.questionSets = 128,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 950;

        final cards = [
          _buildMetricCard(
            title: 'Total Questions',
            value: _formatNumber(totalQuestions),
            growthText: '↑ +15%',
            isNegative: false,
            trendSubtext: '+1,280 this month',
            accentColor: const Color(0xFF0084FF),
            bgTint: const Color(0xFFF0F8FF),
            icon: Icons.question_mark_rounded,
          ),
          _buildMetricCard(
            title: 'Active Questions',
            value: _formatNumber(activeQuestions),
            growthText: '↑ +18%',
            isNegative: false,
            trendSubtext: '+1,324 this month',
            accentColor: const Color(0xFF10B981),
            bgTint: const Color(0xFFF0FDF4),
            icon: Icons.check_rounded,
          ),
          _buildMetricCard(
            title: 'Draft Questions',
            value: _formatNumber(draftQuestions),
            growthText: '↓ -12%',
            isNegative: true,
            trendSubtext: '-84 this month',
            accentColor: const Color(0xFFF59E0B),
            bgTint: const Color(0xFFFFFBEB),
            icon: Icons.description_outlined,
          ),
          _buildMetricCard(
            title: 'Archived Questions',
            value: _formatNumber(archivedQuestions),
            growthText: '↑ +6%',
            isNegative: false,
            trendSubtext: '+21 this month',
            accentColor: const Color(0xFF8B5CF6),
            bgTint: const Color(0xFFF5F3FF),
            icon: Icons.inventory_2_outlined,
          ),
          _buildMetricCard(
            title: 'Question Sets',
            value: _formatNumber(questionSets),
            growthText: '↑ +22%',
            isNegative: false,
            trendSubtext: '+23 this month',
            accentColor: const Color(0xFFF43F5E),
            bgTint: const Color(0xFFFFF1F2),
            icon: Icons.layers_rounded,
          ),
        ];

        if (isDesktop) {
          return Row(
            children: cards
                .map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: c,
                      ),
                    ))
                .toList(),
          );
        }

        if (isTablet) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards
                .map((c) => SizedBox(
                      width: (constraints.maxWidth - 20) / 2,
                      child: c,
                    ))
                .toList(),
          );
        }

        // Mobile layout: SingleChildScrollView horizontal or stacked
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(width: 190, child: c),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String growthText,
    required bool isNegative,
    required String trendSubtext,
    required Color accentColor,
    required Color bgTint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withAlpha(60),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 9),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101A3A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isNegative ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          growthText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isNegative ? const Color(0xFFE11D48) : const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  trendSubtext,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Mini Sparkline Curve
          SizedBox(
            width: 38,
            height: 24,
            child: CustomPaint(
              painter: _SparklinePainter(color: accentColor),
            ),
          ),
        ],
      ),
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

class _SparklinePainter extends CustomPainter {
  final Color color;

  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.55,
      size.width * 0.45,
      size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.75,
      size.width * 0.85,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.color != color;
}
