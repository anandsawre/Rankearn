import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Premium Upgrade Banner:
/// - Soft gold and cream gradient with decorative artwork
/// - Crown icon, "Upgrade to Premium", features description
/// - "Upgrade Now →" CTA button with golden glow
/// - 3D Crown illustration on the right
class ProfilePremiumBanner extends StatelessWidget {
  final bool isPro;
  final VoidCallback onUpgrade;

  const ProfilePremiumBanner({
    super.key,
    required this.isPro,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFEF3C7), // Warm golden cream
            Color(0xFFFFFBEB), // Soft ivory
            Color(0xFFFEF08A), // Light sunny yellow
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10B45309),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Soft background decorative sunburst glow
            Positioned(
              top: -30,
              right: 80,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(80),
                ),
              ),
            ),

            // Content padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 450;

                  return Row(
                    children: [
                      // 1. Left Crown Icon in Squircle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x25F59E0B),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 2. Middle Text & Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isPro
                                  ? 'Rankearn PRO Active'
                                  : 'Upgrade to Premium',
                              style: AppTypography.cardHeading.copyWith(
                                color: const Color(0xFF78350F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPro
                                  ? 'All VIP perks, mock tests & discounts unlocked!'
                                  : 'Unlock unlimited tests, advanced analytics, live tests and more!',
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFF92400E),
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isCompact) ...[
                              const SizedBox(height: 10),
                              _buildUpgradeButton(),
                            ],
                          ],
                        ),
                      ),

                      // 3. Desktop / Standard CTA + Crown Illustration
                      if (!isCompact) ...[
                        const SizedBox(width: 12),
                        _buildUpgradeButton(),
                        const SizedBox(width: 12),
                        _build3DCrownArt(),
                      ] else ...[
                        const SizedBox(width: 8),
                        _build3DCrownArt(size: 42),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onUpgrade,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFDF00), Color(0xFFF59E0B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x35F59E0B),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPro ? 'View Pass' : 'Upgrade Now',
                style: AppTypography.captionBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DCrownArt({double size = 52}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(90),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15CA8A04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/premium_crown_banner.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Text('👑', style: TextStyle(fontSize: 26))),
        ),
      ),
    );
  }
}
