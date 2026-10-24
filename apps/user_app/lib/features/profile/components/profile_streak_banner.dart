import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Full-width Daily Streak Banner:
/// - Flame illustration with glowing gradient
/// - Current streak count e.g. "7 Days"
/// - Seven weekday indicators (Mon-Sun) with checkmarks
/// - Motivator section with calendar icon and "Keep Learning!"
class ProfileStreakBanner extends StatelessWidget {
  final int streakDays;
  final int completedDays;
  final VoidCallback? onTap;

  const ProfileStreakBanner({
    super.key,
    this.streakDays = 7,
    this.completedDays = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.surfaceDark, // Midnight Navy
                AppColors.surfaceDarkCard, // Deep Slate Navy
                AppColors.surfaceDark, // Midnight Navy
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF334155), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x250F172A),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 800;

              if (isNarrow) {
                // Mobile/Tablet layout: Top row with flame & streak + calendar, Bottom row with weekday dots
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildFlameIcon(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$streakDays Days',
                                style: AppTypography.metricValue.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Current Streak',
                                style: AppTypography.metricLabel.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: _buildMotivator(compact: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    const SizedBox(height: 12),
                    _buildWeekdayRow(weekdays),
                  ],
                );
              }

              // Tablet / Desktop layout: Single horizontal row
              return Row(
                children: [
                  // 1. Flame + Days Count
                  _buildFlameIcon(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$streakDays Days',
                        style: AppTypography.metricValue.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Current Streak',
                        style: AppTypography.metricLabel.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  // 2. 7-Day Indicators
                  Expanded(child: _buildWeekdayRow(weekdays)),
                  const SizedBox(width: 16),

                  // 3. Vertical Divider
                  Container(
                    height: 40,
                    width: 1,
                    color: const Color(0xFF334155),
                  ),
                  const SizedBox(width: 16),

                  // 4. Motivator Section
                  _buildMotivator(compact: false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3D Glowing Flame Icon
  // ---------------------------------------------------------------------------
  Widget _buildFlameIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFF7C2D12)],
        ),
        border: Border.all(color: const Color(0xFFFB923C), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x60F97316),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('🔥', style: TextStyle(fontSize: 22)),
    );
  }

  // ---------------------------------------------------------------------------
  // Weekday Indicators with connecting track
  // ---------------------------------------------------------------------------
  Widget _buildWeekdayRow(List<String> weekdays) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 280.0;
        final targetWidth = constraints.maxWidth >= minWidth
            ? constraints.maxWidth
            : minWidth;

        final stackWidget = SizedBox(
          width: targetWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Connecting track line behind dots
              Positioned(
                top: 13,
                left: 12,
                right: 12,
                child: Container(height: 3, color: const Color(0xFF334155)),
              ),

              // Dots & Day Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(weekdays.length, (index) {
                  final isCompleted = index < completedDays;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle Indicator
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.brandGreen
                              : AppColors.surfaceDarkCard,
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF34D399)
                                : const Color(0xFF475569),
                            width: 1.8,
                          ),
                          boxShadow: isCompleted
                              ? const [
                                  BoxShadow(
                                    color: Color(0x4010B981),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            : Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                      ),
                      const SizedBox(height: 5),

                      // Weekday label
                      Text(
                        weekdays[index],
                        style: AppTypography.metricLabel.copyWith(
                          fontWeight: isCompleted
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCompleted
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );

        if (constraints.maxWidth < minWidth) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: stackWidget,
          );
        }

        return stackWidget;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Motivator: Calendar + "Keep Learning! Maintain your streak"
  // ---------------------------------------------------------------------------
  Widget _buildMotivator({required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withAlpha(40),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withAlpha(80),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.calendar_month_rounded,
            color: Color(0xFFA78BFA),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Keep Learning!',
              style: AppTypography.captionBold.copyWith(color: Colors.white),
            ),
            Text(
              'Maintain your streak',
              style: AppTypography.microTag.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
