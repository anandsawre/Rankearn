import 'package:flutter/material.dart';
import 'sparkline_painter.dart';

/// Single Statistics Card at the bottom of the left hero section
class AuthStatsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final String value;
  final String label;
  final String growth;
  final List<double> sparklineData;
  final double? verticalPadding;
  final double? sparklineHeight;

  const AuthStatsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.value,
    required this.label,
    required this.growth,
    required this.sparklineData,
    this.verticalPadding,
    this.sparklineHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: verticalPadding ?? 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x041E293B),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Icon + Value & Growth
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circle Icon
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 7),

              // Value & Growth
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            growth,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Sparkline Wave
          const SizedBox(height: 5),
          SizedBox(
            height: sparklineHeight ?? 16,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklinePainter(
                data: sparklineData,
                lineColor: iconColor,
                fillColor: iconColor,
                strokeWidth: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
