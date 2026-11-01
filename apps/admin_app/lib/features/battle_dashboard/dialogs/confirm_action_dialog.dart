import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ConfirmActionDialog extends StatefulWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final bool isDestructive;
  final bool requiresReason;
  final Future<void> Function(String reason) onConfirm;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Confirm Action',
    this.isDestructive = true,
    this.requiresReason = true,
    required this.onConfirm,
  });

  @override
  State<ConfirmActionDialog> createState() => _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends State<ConfirmActionDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final reason = _reasonController.text.trim();
    if (widget.requiresReason && reason.isEmpty) {
      setState(() => _error = 'Please provide an administrative reason for the audit log.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onConfirm(reason);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isDestructive ? AppColors.liveRedSubtle : AppColors.brandPurpleLight,
                    borderRadius: AppRadii.borderMd,
                  ),
                  child: Icon(
                    widget.isDestructive ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    color: widget.isDestructive ? AppColors.liveRed : AppColors.battleAdminPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Admin Audit & Security Protocol',
                        style: AppTypography.captionBold.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              widget.description,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Reason Input
            if (widget.requiresReason) ...[
              Text(
                'Administrative Reason *',
                style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Match disconnection abuse, server flush, cheating investigation...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.borderMd,
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadii.borderMd,
                    borderSide: const BorderSide(color: AppColors.battleAdminPurple, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.liveRedLight,
                  borderRadius: AppRadii.borderSm,
                  border: Border.all(color: AppColors.liveRedBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.liveRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTypography.captionBold.copyWith(color: AppColors.liveRedDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDestructive ? AppColors.liveRed : AppColors.battleAdminPurple,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                        )
                      : Text(
                          widget.confirmLabel,
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textOnPrimary),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
