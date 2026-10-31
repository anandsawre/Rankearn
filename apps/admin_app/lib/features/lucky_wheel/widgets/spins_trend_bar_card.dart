import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/lucky_wheel_item.dart';

class SpinsTrendBarCard extends StatelessWidget {
  final List<WheelSpinsTrendDay> data;
  final VoidCallback? onViewAll;

  const SpinsTrendBarCard({
    super.key,
    this.data = const [],
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final list = data;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title + View All
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF5636F5),
                  size: 14,
                ),
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Spins Trend (Last 7 Days)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101A3A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5636F5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Chart Body: Y-Axis + Bars or Empty State
          if (list.isEmpty)
            const SizedBox(
              height: 90,
              child: Center(
                child: Text(
                  'No spin trend data available.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Y-Axis labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('20K', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, height: 1)),
                      Text('15K', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, height: 1)),
                      Text('10K', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, height: 1)),
                      Text('5K', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, height: 1)),
                      Text('0', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, height: 1)),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Bars
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: list.map((day) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // The Bar
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Tooltip(
                                    message: '${day.dateLabel}: ${day.count} spins',
                                    child: Container(
                                      height: (72 * day.heightRatio).clamp(6.0, 72.0),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF6B4EFF),
                                            Color(0xFF5636F5),
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Date label
                              Text(
                                day.dateLabel,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
