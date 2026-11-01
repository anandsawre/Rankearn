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
    return AppModalDialog(
      title: widget.title,
      subtitle: 'Admin Audit & Security Protocol',
      iconData: widget.isDestructive ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
      gradientColors: widget.isDestructive
          ? const [Color(0xFFDC2626), Color(0xFFEF4444)]
          : const [AppColors.battleAdminPurple, AppColors.battleAdminPurpleSecondary],
      maxWidth: 460,
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isDestructive ? const Color(0xFFDC2626) : AppColors.battleAdminPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45),
          ),
          const SizedBox(height: 14),

          if (widget.requiresReason) ...[
            const Text(
              'Administrative Reason *',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                hintText: 'e.g., Match disconnection abuse, server flush, cheating investigation...',
                hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isDestructive ? const Color(0xFFDC2626) : AppColors.battleAdminPurple,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
