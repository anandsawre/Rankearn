import 'package:flutter/material.dart';

class ExamCategoryPalette {
  final Color bg;
  final Color bgEnd;
  final Color border;
  final Color accent;

  const ExamCategoryPalette({
    required this.bg,
    required this.bgEnd,
    required this.border,
    required this.accent,
  });

  static const List<ExamCategoryPalette> defaultPalettes = [
    ExamCategoryPalette(
      bg: Color(0xFFF5F7FF), // Soft Indigo
      bgEnd: Color(0xFFE0E7FF),
      border: Color(0xFFC7D2FE),
      accent: Color(0xFF4F46E5),
    ),
    ExamCategoryPalette(
      bg: Color(0xFFF0FDF4), // Soft Emerald
      bgEnd: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
      accent: Color(0xFF059669),
    ),
    ExamCategoryPalette(
      bg: Color(0xFFFFFDF5), // Soft Amber
      bgEnd: Color(0xFFFEF3C7),
      border: Color(0xFFFDE68A),
      accent: Color(0xFFD97706),
    ),
    ExamCategoryPalette(
      bg: Color(0xFFFAF5FF), // Soft Purple
      bgEnd: Color(0xFFF3E8FF),
      border: Color(0xFFE9D5FF),
      accent: Color(0xFF7C3AED),
    ),
    ExamCategoryPalette(
      bg: Color(0xFFFFF5F6), // Soft Rose
      bgEnd: Color(0xFFFFE4E6),
      border: Color(0xFFFECDD3),
      accent: Color(0xFFE11D48),
    ),
    ExamCategoryPalette(
      bg: Color(0xFFF0FDFF), // Soft Cyan
      bgEnd: Color(0xFFCFFAFE),
      border: Color(0xFFA5F3FC),
      accent: Color(0xFF0891B2),
    ),
    ExamCategoryPalette(
      bg: Color(0xFFFFF8F1), // Soft Orange
      bgEnd: Color(0xFFFFEDD5),
      border: Color(0xFFFED7AA),
      accent: Color(0xFFEA580C),
    ),
    ExamCategoryPalette(
      bg: Color(0xFFF0FDF9), // Soft Teal
      bgEnd: Color(0xFFCCFBF1),
      border: Color(0xFF99F6E4),
      accent: Color(0xFF0D9488),
    ),
  ];

  static ExamCategoryPalette forIndex(int index) {
    return defaultPalettes[index % defaultPalettes.length];
  }
}

/// Standard Exam Category Card matching the reference Target Exam design
class ExamCategoryCard extends StatelessWidget {
  final int index;
  final String id;
  final String name;
  final String badgeText;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final double height;

  const ExamCategoryCard({
    super.key,
    required this.index,
    required this.id,
    required this.name,
    required this.badgeText,
    this.icon,
    this.isSelected = false,
    required this.onTap,
    this.width = 122,
    this.height = 144,
  });

  static IconData resolveIcon(String name, String id) {
    final lower = ('$name $id').toLowerCase();
    if (id == 'all') return Icons.layers_rounded;
    if (lower.contains('bpsc') ||
        lower.contains('state pcs') ||
        lower.contains('civil') ||
        lower.contains('pcs')) {
      return Icons.account_balance_rounded;
    }
    if (lower.contains('upsc') ||
        lower.contains('ias') ||
        lower.contains('ips')) {
      return Icons.military_tech_rounded;
    }
    if (lower.contains('ssc') ||
        lower.contains('cgl') ||
        lower.contains('chsl') ||
        lower.contains('mts')) {
      return Icons.assignment_rounded;
    }
    if (lower.contains('railway') ||
        lower.contains('rrb') ||
        lower.contains('ntpc') ||
        lower.contains('group d')) {
      return Icons.train_rounded;
    }
    if (lower.contains('ctest') ||
        lower.contains('science') ||
        lower.contains('tech') ||
        lower.contains('lab')) {
      return Icons.biotech_rounded;
    }
    if (lower.contains('bank') ||
        lower.contains('ibps') ||
        lower.contains('sbi') ||
        lower.contains('po') ||
        lower.contains('clerk')) {
      return Icons.savings_rounded;
    }
    if (lower.contains('defence') ||
        lower.contains('nda') ||
        lower.contains('cds') ||
        lower.contains('afcat')) {
      return Icons.shield_rounded;
    }
    if (lower.contains('teach') ||
        lower.contains('ctet') ||
        lower.contains('tet') ||
        lower.contains('bed')) {
      return Icons.school_rounded;
    }
    if (lower.contains('police') ||
        lower.contains('si') ||
        lower.contains('constable')) {
      return Icons.local_police_rounded;
    }
    if (lower.contains('math') ||
        lower.contains('aptitude') ||
        lower.contains('quant')) {
      return Icons.calculate_rounded;
    }
    return Icons.school_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final palette = ExamCategoryPalette.forIndex(index);
    final iconData = icon ?? resolveIcon(name, id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.bg, palette.bgEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? palette.accent : palette.border.withAlpha(160),
          width: isSelected ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? palette.accent.withAlpha(40)
                : palette.accent.withAlpha(12),
            blurRadius: isSelected ? 12 : 5,
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
                  top: -16,
                  right: -16,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.accent.withAlpha(isSelected ? 28 : 16),
                    ),
                  ),
                ),
                // Background Design 2: Top-Right Concentric Ring
                Positioned(
                  top: -26,
                  right: -26,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.accent.withAlpha(isSelected ? 32 : 18),
                        width: 1.5,
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
                      iconData,
                      size: 54,
                      color: palette.accent.withAlpha(isSelected ? 30 : 18),
                    ),
                  ),
                ),
                // Background Design 4: Bottom-Left Soft White Highlight Bubble
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(isSelected ? 110 : 70),
                    ),
                  ),
                ),
                // Foreground Content
                SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: palette.accent.withAlpha(22),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            iconData,
                            color: palette.accent,
                            size: 23,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: isSelected
                                    ? palette.accent
                                    : const Color(0xFF1E293B),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? palette.accent.withAlpha(25)
                                    : Colors.white.withAlpha(190),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badgeText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? palette.accent
                                      : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 11,
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
