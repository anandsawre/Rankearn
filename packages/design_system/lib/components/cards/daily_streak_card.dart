import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Daily Streak Card matching the Rankearn reference dashboard sidebar
class DailyStreakCard extends StatelessWidget {
  final int streakDays;
  final int completedDays;
  final List<String> days;
  final VoidCallback? onTap;

  final Color accentColor;

  const DailyStreakCard({
    super.key,
    this.streakDays = 7,
    this.completedDays = 5,
    this.days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.onTap,
    this.accentColor = const Color(0xFFF97316),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accentColor.withAlpha(20), Colors.white),
            Colors.white,
          ],
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: accentColor.withAlpha(45), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Stack(
          children: [
            // 1. Soft Halo Glow in Top Right
            Positioned(
              top: -25,
              right: -25,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withAlpha(20),
                ),
              ),
            ),

            // 2. Concentric Arc Ring
            Positioned(
              top: -35,
              right: -35,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withAlpha(18),
                    width: 1.0,
                  ),
                ),
              ),
            ),

            // 3. Faint Flame Watermark Icon in lower-right
            Positioned(
              right: 12,
              bottom: -10,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.12,
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    size: 68,
                    color: accentColor.withAlpha(20),
                  ),
                ),
              ),
            ),

            // 4. Foreground Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadii.borderLg,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Row: Flame Icon + Streak Details
                      Row(
                        children: [
                          // 3D Styled Flame Icon
                          Container(
                            width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                      ),
                      border: Border.all(
                        color: const Color(0xFFFED7AA),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x15F97316),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFF97316),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Streak',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$streakDays Days',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 7 Day Trackers Row (Mon - Sun)
              Row(
                children: List.generate(days.length, (index) {
                  final isCompleted = index < completedDays;
                  final dayLabel = days[index];

                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? const Color(0xFF10B981) // Vibrant Brand Green
                                : const Color(
                                    0xFFE2E8F0,
                                  ), // Inactive light grey
                            boxShadow: isCompleted
                                ? const [
                                    BoxShadow(
                                      color: Color(0x3310B981),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dayLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCompleted
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ),
          ],
        ),
      ),
    );
  }
}
