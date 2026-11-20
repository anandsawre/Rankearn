import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AppearanceBrandingCard extends StatelessWidget {
  final TextEditingController primaryColorController;
  final TextEditingController secondaryColorController;
  final TextEditingController logoUrlController;
  final TextEditingController faviconUrlController;
  final VoidCallback onSave;

  const AppearanceBrandingCard({
    super.key,
    required this.primaryColorController,
    required this.secondaryColorController,
    required this.logoUrlController,
    required this.faviconUrlController,
    required this.onSave,
  });

  Color _parseHexColor(String hex, Color fallback) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      }
      if (clean.length == 8) {
        return Color(int.parse('0x$clean'));
      }
    } catch (_) {}
    return fallback;
  }

  void _showUrlInputDialog(BuildContext context, String title, TextEditingController controller) {
    final tempController = TextEditingController(text: controller.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: AppTypography.adminCardTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter direct image CDN or Supabase Storage URL:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: tempController,
              hintText: 'https://...',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.text = tempController.text.trim();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set URL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _parseHexColor(primaryColorController.text, AppColors.adminPurple);
    final secondaryColor = _parseHexColor(secondaryColorController.text, AppColors.adminViolet);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.adminPurpleLight,
                      borderRadius: AppRadii.adminControl,
                    ),
                    child: const Icon(Icons.palette_outlined, size: 18, color: AppColors.adminPurple),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Appearance & Branding',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Primary Color
              Row(
                children: [
                  SizedBox(
                    width: 95,
                    child: Text('Primary Color', style: AppTypography.adminTableSecondary.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      controller: primaryColorController,
                      hintText: '#7C3AED',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Secondary Color
              Row(
                children: [
                  SizedBox(
                    width: 95,
                    child: Text('Secondary Color', style: AppTypography.adminTableSecondary.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      controller: secondaryColorController,
                      hintText: '#A855F7',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // App Logo & Favicon
              Row(
                children: [
                  // Logo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('App Logo URL', style: AppTypography.adminFieldLabelSmall),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.adminBackground,
                            borderRadius: AppRadii.adminControl,
                            border: Border.all(color: AppColors.adminBorder),
                          ),
                          child: Row(
                            children: [
                              if (logoUrlController.text.trim().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    logoUrlController.text.trim(),
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_outlined, size: 18, color: AppColors.adminSecondaryText),
                                  ),
                                )
                              else
                                const Icon(Icons.image_outlined, color: AppColors.adminSecondaryText, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  logoUrlController.text.trim().isEmpty ? 'No Logo URL' : logoUrlController.text.trim(),
                                  style: AppTypography.adminBadge.copyWith(color: AppColors.adminPrimaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () => _showUrlInputDialog(context, 'Set App Logo URL', logoUrlController),
                                child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.adminPurple),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Favicon
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Favicon URL', style: AppTypography.adminFieldLabelSmall),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.adminBackground,
                            borderRadius: AppRadii.adminControl,
                            border: Border.all(color: AppColors.adminBorder),
                          ),
                          child: Row(
                            children: [
                              if (faviconUrlController.text.trim().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    faviconUrlController.text.trim(),
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined, size: 18, color: AppColors.adminSecondaryText),
                                  ),
                                )
                              else
                                const Icon(Icons.star_outline_rounded, color: AppColors.adminSecondaryText, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  faviconUrlController.text.trim().isEmpty ? 'No Favicon' : faviconUrlController.text.trim(),
                                  style: AppTypography.adminBadge.copyWith(color: AppColors.adminPrimaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () => _showUrlInputDialog(context, 'Set Favicon URL', faviconUrlController),
                                child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.adminPurple),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              child: AppButton.adminPrimary(
                label: 'Save Appearance',
                leadingIcon: const Icon(Icons.save_rounded, size: 16),
                onPressed: onSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
