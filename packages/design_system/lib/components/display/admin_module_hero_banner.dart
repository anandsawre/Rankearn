import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Reusable purple-gradient hero banner for Admin Management modules
/// (Notification Management, Referral & Earning, Promo Banners, etc.)
class AdminModuleHeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final Widget? badge;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;

  const AdminModuleHeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.badge,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7628E8),
            Color(0xFF5B1EB8),
            Color(0xFF4C16A8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.borderXl,
        boxShadow: const [
          BoxShadow(
            color: Color(0x334C16A8),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderXl,
        child: Stack(
          children: [
            // Decorative background glowing circular elements
            Positioned(
              left: -40,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(20),
                ),
              ),
            ),
            Positioned(
              right: 80,
              bottom: -50,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(12),
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA855F7).withAlpha(35),
                ),
              ),
            ),

            // Content padding & layout
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 20,
                vertical: isDesktop ? 24 : 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon avatar box with soft glow
                  Container(
                    width: isDesktop ? 54 : 44,
                    height: isDesktop ? 54 : 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(45),
                      borderRadius: AppRadii.borderLg,
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isDesktop ? 28 : 22,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badge != null) ...[
                          badge!,
                          const SizedBox(height: 6),
                        ],
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 22 : 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: isDesktop ? 13 : 12,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Optional Trailing Action or Widget
                  if (trailing != null) ...[
                    const SizedBox(width: 16),
                    trailing!,
                  ] else if (actionLabel != null && onAction != null) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: onAction,
                      icon: actionIcon != null
                          ? Icon(actionIcon, size: 16, color: AppColors.adminPrimaryText)
                          : const SizedBox.shrink(),
                      label: Text(
                        actionLabel!,
                        style: const TextStyle(
                          color: AppColors.adminPrimaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.adminPrimaryText,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.borderMd,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
