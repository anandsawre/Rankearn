import 'package:flutter/material.dart';

/// SubjectSelectionCard styled to match the modern Exam / Subject Card design:
/// - Pastel gradient rounded rectangle with decorative rings & watermark icon
/// - Elevated white squircle icon box at top
/// - Centered bold subject title
/// - Bottom rounded pill badge for chapters / questions count
class SubjectSelectionCard extends StatelessWidget {
  final String title;
  final String? questionCount;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final int index;
  final double? width;
  final double? height;
  final bool isSelected;
  final VoidCallback onTap;

  const SubjectSelectionCard({
    super.key,
    required this.title,
    this.questionCount,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    this.index = 0,
    this.width = 116,
    this.height = 144,
    this.isSelected = false,
    required this.onTap,
  });

  static final List<({Color bg, Color bgEnd, Color border, Color accent})>
      _palettes = [
    (
      bg: const Color(0xFFF0FDF4),
      bgEnd: const Color(0xFFDCFCE7),
      border: const Color(0xFF86EFAC),
      accent: const Color(0xFF16A34A),
    ), // Mint / Green (like Railway Technician)
    (
      bg: const Color(0xFFEFF6FF),
      bgEnd: const Color(0xFFDBEAFE),
      border: const Color(0xFF93C5FD),
      accent: const Color(0xFF2563EB),
    ), // Soft Sky Blue
    (
      bg: const Color(0xFFFAF5FF),
      bgEnd: const Color(0xFFF3E8FF),
      border: const Color(0xFFD8B4FE),
      accent: const Color(0xFF9333EA),
    ), // Lavender / Purple
    (
      bg: const Color(0xFFFFF7ED),
      bgEnd: const Color(0xFFFFEDD5),
      border: const Color(0xFFFDBA74),
      accent: const Color(0xFFEA580C),
    ), // Warm Amber / Orange
    (
      bg: const Color(0xFFFDF2F8),
      bgEnd: const Color(0xFFFCE7F3),
      border: const Color(0xFFF9A8D4),
      accent: const Color(0xFFDB2777),
    ), // Rose / Pink
    (
      bg: const Color(0xFFECFEFF),
      bgEnd: const Color(0xFFCFFAFE),
      border: const Color(0xFFA5F3FC),
      accent: const Color(0xFF0891B2),
    ), // Cyan / Teal
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[index % _palettes.length];
    final activeAccent = accentColor != const Color(0xFF2587F8) ? accentColor : palette.accent;
    final activeBorder = isSelected ? activeAccent : palette.border.withValues(alpha: 0.65);
    final activeBgStart = palette.bg;
    final activeBgEnd = palette.bgEnd;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [activeBgStart, activeBgEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: activeBorder,
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: activeAccent.withValues(alpha: isSelected ? 0.25 : 0.08),
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // Background Design 1: Top-Right Decorative Glow Circle
                Positioned(
                  top: -14,
                  right: -14,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeAccent.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                // Background Design 2: Top-Right Concentric Ring
                Positioned(
                  top: -22,
                  right: -22,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: activeAccent.withValues(alpha: 0.16),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                // Background Design 3: Bottom-Right Tilted Watermark Icon
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: Icon(
                      icon,
                      size: 48,
                      color: activeAccent.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // Background Design 4: Bottom-Left Soft White Highlight Bubble
                Positioned(
                  bottom: -16,
                  left: -16,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ),

                // Foreground Content
                SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top white rounded squircle container with drop shadow
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: activeAccent.withValues(alpha: 0.16),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            icon,
                            color: activeAccent,
                            size: 22,
                          ),
                        ),

                        // Subject Title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                            fontSize: 12,
                            color: const Color(0xFF1E293B),
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Bottom Pill Badge (e.g. "1 Chapters", "2 Chapters", "10+ Qs")
                        if (questionCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: activeAccent.withValues(alpha: 0.22),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              questionCount!,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
