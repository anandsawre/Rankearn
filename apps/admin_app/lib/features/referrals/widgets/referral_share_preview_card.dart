import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';

class ReferralSharePreviewCard extends StatelessWidget {
  final String referralCode;
  final String referralLink;
  final void Function(String channel)? onSocialShare;

  const ReferralSharePreviewCard({
    super.key,
    this.referralCode = 'RANK-WIN50',
    this.referralLink = 'https://rankearn.in/ref?code=RANK-WIN50',
    this.onSocialShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.fromBorderSide(BorderSide(color: AppColors.adminBorder)),
        boxShadow: AppShadows.adminCard,
      ),
      padding: AppSpacing.adminCardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.preview_rounded, size: 20, color: AppColors.adminPurple),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Referral Link & Share Preview',
                  style: AppTypography.adminSectionTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Promotional Banner Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5636F5), Color(0xFF7628E8), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadii.adminCardInner,
              boxShadow: AppShadows.adminBanner,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: AppRadii.adminBadge,
                      ),
                      child: const Text(
                        '🔥 LIMITED TIME OFFER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFD633), size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Invite Friends & Earn ₹50 Cash!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your friends get 25 bonus coins and you get ₹50 when they play their first quiz.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(220),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(40),
                    borderRadius: AppRadii.adminControl,
                    border: Border.all(color: Colors.white.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Referral Code: ',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Flexible(
                        child: Text(
                          referralCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD633),
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Referral Link Field with Copy
          const Text(
            'Master Campaign Link',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.adminPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.adminBackground,
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 18, color: AppColors.adminSecondaryText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    referralLink,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.adminPrimaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: referralLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📋 Referral link copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.adminControl),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Social Share Buttons
          const Text(
            'Share Campaign Via',
            style: AppTypography.adminFieldLabelSmall,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildShareButton(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: AppColors.socialWhatsApp,
                  onTap: () => onSocialShare?.call('whatsapp'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.send_rounded,
                  label: 'Telegram',
                  color: AppColors.socialTelegram,
                  onTap: () => onSocialShare?.call('telegram'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.facebook_rounded,
                  label: 'Facebook',
                  color: AppColors.socialFacebook,
                  onTap: () => onSocialShare?.call('facebook'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.share_rounded,
                  label: 'Native',
                  color: AppColors.adminViolet,
                  onTap: () => onSocialShare?.call('native'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.adminControl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: AppRadii.adminControl,
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
