import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Refer & Earn Banner Card matching the reference design in Rewards tab
class ReferEarnCard extends StatelessWidget {
  final String referralCode;
  final VoidCallback? onInviteNow;
  final String? mascotAssetPath;

  const ReferEarnCard({
    super.key,
    this.referralCode = 'RANK123',
    this.onInviteNow,
    this.mascotAssetPath = 'assets/images/refer_earn_mascot.jpg',
  });

  void _copyReferralCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text('Referral code "$referralCode" copied to clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF00B96B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8FDF3), Color(0xFFDCFCE7), Color(0xFFE2FBE9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A00B96B),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;
          final isVeryNarrow = constraints.maxWidth < 460;

          if (isCompact) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMascot(),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextContent()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (isVeryNarrow) ...[
                    _buildReferralCodeBox(context, isFullWidth: true),
                    const SizedBox(height: 10),
                    _buildInviteButton(isFullWidth: true),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildReferralCodeBox(
                            context,
                            isFullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildInviteButton(),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Mascot image
                _buildMascot(),
                const SizedBox(width: 16),

                // Text Content
                Expanded(child: _buildTextContent()),
                const SizedBox(width: 14),

                // Referral Code Box
                _buildReferralCodeBox(context),
                const SizedBox(width: 12),

                // Invite Now Button
                _buildInviteButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMascot() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        mascotAssetPath!,
        width: 72,
        height: 64,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.campaign_rounded,
              color: Color(0xFF00B96B),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'Refer & Earn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF064E3B),
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Invite your friends and earn 100 coins for each successful signup!',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF047857),
            height: 1.25,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildReferralCodeBox(
    BuildContext context, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: isFullWidth
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Referral Code',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                referralCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111A4B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (!isFullWidth) const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyReferralCode(context),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: Color(0xFF00B96B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton({bool isFullWidth = false}) {
    return Material(
      color: const Color(0xFF00B96B), // Reference emerald green
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: const Color(0xFF00B96B).withValues(alpha: 0.35),
      child: InkWell(
        onTap: onInviteNow,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: isFullWidth
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: const [
              Text(
                'Invite Now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
