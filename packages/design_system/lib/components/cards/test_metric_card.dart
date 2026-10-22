import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// TestMetricCard matching the 4 statistics cards in the Tests screen
class TestMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const TestMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.backgroundColor,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withAlpha(45),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                // Squircle Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(70),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Label and Value Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
