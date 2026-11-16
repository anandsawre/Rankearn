import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PlatformInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController taglineController;
  final TextEditingController emailController;
  final TextEditingController whatsappController;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const PlatformInfoCard({
    super.key,
    required this.nameController,
    required this.taglineController,
    required this.emailController,
    required this.whatsappController,
    required this.onReset,
    required this.onSave,
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
                child: const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.adminPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Platform Information',
                  style: AppTypography.adminCardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Platform Name *', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: nameController,
            hintText: 'Platform Name *',
          ),
          const SizedBox(height: 12),

          Text('Tagline', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: taglineController,
            hintText: 'India\'s 1st Learning with Earning Platform',
          ),
          const SizedBox(height: 12),

          Text('Support Email', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: emailController,
            hintText: 'support@rankearn.app',
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.adminSecondaryText),
          ),
          const SizedBox(height: 12),

          Text('Support WhatsApp', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: whatsappController,
            hintText: '+91 9876543210',
            prefixIcon: const Icon(Icons.chat_rounded, size: 18, color: AppColors.adminSuccess),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('App Version', style: AppTypography.adminFieldLabelSmall, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.borderPill,
                ),
                child: const Text(
                  'Latest',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.adminPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: AppButton.adminGhost(
                  label: 'Reset',
                  onPressed: onReset,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppButton.adminPrimary(
                  label: 'Save Changes',
                  leadingIcon: const Icon(Icons.save_rounded, size: 16),
                  onPressed: onSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

