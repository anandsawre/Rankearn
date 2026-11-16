import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AppearanceBrandingCard extends StatelessWidget {
  final TextEditingController primaryColorController;
  final TextEditingController secondaryColorController;
  final VoidCallback onUploadLogo;
  final VoidCallback onUploadFavicon;

  const AppearanceBrandingCard({
    super.key,
    required this.primaryColorController,
    required this.secondaryColorController,
    required this.onUploadLogo,
    required this.onUploadFavicon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(
                width: 90,
                child: Text('Primary Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminSecondaryText)),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(4),
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
              const SizedBox(
                width: 90,
                child: Text('Secondary Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminSecondaryText)),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7),
                  borderRadius: BorderRadius.circular(4),
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
                    Text('App Logo', style: AppTypography.adminFieldLabelSmall),
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
                          const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 20),
                          const Spacer(),
                          InkWell(
                            onTap: onUploadLogo,
                            child: const Icon(Icons.file_upload_outlined, size: 18, color: AppColors.adminPurple),
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
                    Text('Favicon', style: AppTypography.adminFieldLabelSmall),
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
                          const Text(
                            'Rankearn',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.adminPrimaryText),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: onUploadFavicon,
                            child: const Icon(Icons.file_upload_outlined, size: 18, color: AppColors.adminPurple),
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
    );
  }
}

