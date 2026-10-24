import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// Profile Hero Card: Iridescent pastel mesh gradient with student details,
/// circular avatar with camera action, role pills, and embedded Rank Card.
class ProfileHeroCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onChangeAvatar;
  final VoidCallback onSelectRole;
  final VoidCallback? onRankTap;
  final bool isDesktop;

  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.onEditProfile,
    required this.onChangeAvatar,
    required this.onSelectRole,
    this.onRankTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: isDesktop ? 215.0 : 0.0),
      decoration: BoxDecoration(
        // Iridescent mint-cyan to electric violet pastel gradient matching reference
        gradient: const LinearGradient(
          colors: [
            Color(0xFF86EFAC), // Soft bright mint
            Color(0xFFA7F3D0), // Pastel seafoam
            Color(0xFF93C5FD), // Sky blue
            Color(0xFFC4B5FD), // Lavender purple
            Color(0xFFE9D5FF), // Soft lilac
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.25, 0.55, 0.85, 1.0],
        ),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Colors.white.withAlpha(200), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Stack(
          children: [
            // Ambient soft light beam overlay
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(45),
                ),
              ),
            ),

            // Content padding with balanced vertical breathing room matching other tabs
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 26.0 : 16.0,
                vertical: isDesktop ? 24.0 : 16.0,
              ),
              child: isDesktop
                  ? _buildDesktopLayout(context)
                  : _buildMobileLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP LAYOUT (Horizontal Row: User Info Left | Rank Card Right)
  // ---------------------------------------------------------------------------
  Widget _buildDesktopLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 580) {
          return _buildMobileLayout(context);
        }

        final rankWidth = constraints.maxWidth > 750 ? 310.0 : 240.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Avatar + Details
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(radius: constraints.maxWidth > 700 ? 52 : 44),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildUserDetails(
                      context,
                      compact: constraints.maxWidth < 700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),

            // Right: Rank Card
            SizedBox(
              width: rankWidth,
              child: _buildRankCard(context, compact: rankWidth < 280),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE LAYOUT (Responsive Split or Stack)
  // ---------------------------------------------------------------------------
  Widget _buildMobileLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 500;

        if (isCompact) {
          // Narrow mobile: Stack user details and Rank card vertically
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(radius: 36),
                  const SizedBox(width: 14),
                  Expanded(child: _buildUserDetails(context, compact: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildRankCard(context),
            ],
          );
        }

        // Tablet / larger mobile: Side-by-side with Rank Card on the right
        final cardWidth = constraints.maxWidth > 650 ? 250.0 : 190.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(radius: 38),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildUserDetails(
                      context,
                      compact: constraints.maxWidth < 650,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: cardWidth,
              child: _buildRankCard(
                context,
                compact: constraints.maxWidth < 650,
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // AVATAR WIDGET (With Camera Badge Action)
  // ---------------------------------------------------------------------------
  Widget _buildAvatar({double radius = 42}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer glow & circular ring
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFF0F766E), width: 3.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x200D9488),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child:
                profile.profilePhotoUrl != null &&
                    profile.profilePhotoUrl!.isNotEmpty
                ? Image.network(
                    profile.profilePhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackAvatarImage(),
                  )
                : _buildFallbackAvatarImage(),
          ),
        ),

        // Camera Action Button
        Positioned(
          bottom: -2,
          right: -2,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onChangeAvatar,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A), // Dark navy circle
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x25000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatarImage() {
    return Image.asset(
      'assets/images/student_profile_avatar.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF0284C7),
        alignment: Alignment.center,
        child: Text(
          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A',
          style: AppTypography.displayMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // USER DETAILS (Name, Edit Icon, Contact, Location, Role & Gold Member Badges)
  // ---------------------------------------------------------------------------
  Widget _buildUserDetails(BuildContext context, {bool compact = false}) {
    final displayName = profile.name.isNotEmpty ? profile.name : 'Aman Kumar';
    final displayEmail = profile.email.isNotEmpty
        ? profile.email
        : 'aman.kumar@example.com';
    final displayPhone = (profile.phone != null && profile.phone!.isNotEmpty)
        ? profile.phone!
        : '+91 98765 43210';
    final displayLocation = (profile.state != null && profile.state!.isNotEmpty)
        ? profile.state!
        : 'Patna, Bihar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name + Edit Button
        Row(
          children: [
            Flexible(
              child: Text(
                displayName,
                style: AppTypography.displayMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onEditProfile,
              borderRadius: AppRadii.borderSm,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(180),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.surface.withAlpha(240),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),

        // Email Address
        Text(
          displayEmail,
          style: AppTypography.supporting,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),

        // Phone Number Row
        Row(
          children: [
            const Icon(
              Icons.phone_rounded,
              size: 13,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                displayPhone,
                style: AppTypography.supporting.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Location Row
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 13,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                displayLocation,
                style: AppTypography.supporting.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Badges: Student Role Pill & Gold Member Badge
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Student Role Dropdown Pill
            InkWell(
              onTap: onSelectRole,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: AppShadows.subtle,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.examPreparingFor ?? 'Student',
                      style: AppTypography.captionBold,
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),

            // Membership Badge (Gold Member / Pro Member)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFACC15), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18CA8A04),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C3AED), // Purple crown background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    profile.isPro ? 'PRO Member' : 'Gold Member',
                    style: AppTypography.captionBold.copyWith(
                      color: const Color(0xFF78350F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // RANK CARD (Midnight Navy with 3D Shield, #1256, Green Progress Bar)
  // ---------------------------------------------------------------------------
  Widget _buildRankCard(BuildContext context, {bool compact = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRankTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14.0 : 18.0,
            vertical: compact ? 14.0 : 18.0,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E3A8A), // Royal navy blue
                Color(0xFF0F172A), // Deep midnight
                Color(0xFF172554), // Deep indigo
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF3B82F6).withAlpha(90),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x300F172A),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Glowing Shield + Rank Number + Chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3D Glowing Shield
                  _buildRankShieldBadge(size: compact ? 40 : 48),
                  const SizedBox(width: 12),

                  // Rank Header & Number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Rank',
                          style: AppTypography.metricLabel.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '#1256',
                          style: AppTypography.metricValue.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Trailing Chevron
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Neon Green Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.68,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF334155),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.brandGreen,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Next Rank & Points Remaining
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Rank: #1000',
                      style: AppTypography.microTag.copyWith(
                        color: AppColors.borderSubtle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '744 pts to go',
                      style: AppTypography.microTag.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3D GLOWING RANK SHIELD BADGE
  // ---------------------------------------------------------------------------
  Widget _buildRankShieldBadge({double size = 42}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8), Color(0xFF172554)],
        ),
        border: Border.all(color: const Color(0xFF60A5FA), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x403B82F6),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.shield_rounded, color: Color(0xFF2563EB), size: 26),
          Icon(
            Icons.star_rounded,
            color: Color(0xFFFFD700), // Gold star
            size: 16,
          ),
        ],
      ),
    );
  }
}
