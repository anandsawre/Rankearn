import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// A professional, responsive, and attractive modal dialog component.
///
/// Provides a consistent UI across admin and user dashboards:
/// - Responsive screen-adaptive constraints (mobile, tablet, desktop).
/// - Premium header with gradient accent bar, icon badge, title, subtitle, and close button.
/// - Scroll-safe flexible body with optional single-child scroll view.
/// - Integrated footer with left-side metadata / status and right-side responsive action buttons.
/// - Smooth scale-fade entrance transition helper (`AppModalDialog.show`).
class AppModalDialog extends StatelessWidget {
  final Widget? icon;
  final IconData? iconData;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Color? accentColor;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final bool scrollable;
  final Widget child;
  final Widget? footerLeft;
  final List<Widget>? actions;

  const AppModalDialog({
    super.key,
    this.icon,
    this.iconData,
    this.iconColor,
    this.iconBgColor,
    required this.title,
    this.subtitle,
    this.headerTrailing,
    this.showCloseButton = true,
    this.onClose,
    this.accentColor,
    this.maxWidth = 620,
    this.maxHeight,
    this.contentPadding,
    this.scrollable = false,
    required this.child,
    this.footerLeft,
    this.actions,
  });

  /// Opens the dialog with an attractive scale-fade motion and backdrop tint.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: const Color(0x660F172A),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim1, anim2) => builder(ctx),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curve),
          child: FadeTransition(
            opacity: curve,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 640;

    final effectiveMaxWidth = isMobile ? math.max(300.0, media.size.width - 24) : maxWidth;
    final effectiveMaxHeight = maxHeight ?? (media.size.height * 0.88);

    final resolvedColor = iconColor ?? const Color(0xFF5636F5);
    final resolvedBgColor = iconBgColor ?? resolvedColor.withAlpha(22);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withAlpha(24),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: effectiveMaxWidth,
          maxHeight: effectiveMaxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Accent Bar (Gradient Highlight)
            Container(
              height: 3.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor ?? resolvedColor,
                    (accentColor ?? resolvedColor).withAlpha(90),
                    const Color(0xFF2587F8),
                  ],
                ),
              ),
            ),

            // Header Section
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 22,
                isMobile ? 14 : 18,
                isMobile ? 12 : 16,
                isMobile ? 12 : 14,
              ),
              child: Row(
                children: [
                  // Icon box
                  if (icon != null)
                    icon!
                  else if (iconData != null)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: resolvedBgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: resolvedColor.withAlpha(35), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Icon(iconData, color: resolvedColor, size: 20),
                    ),
                  if (icon != null || iconData != null) const SizedBox(width: 12),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget or status badge
                  if (headerTrailing != null) ...[
                    const SizedBox(width: 8),
                    headerTrailing!,
                  ],

                  // Close Button
                  if (showCloseButton) ...[
                    const SizedBox(width: 6),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        hoverColor: const Color(0xFFF1F5F9),
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Body Content
            if (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: contentPadding ?? EdgeInsets.all(isMobile ? 16 : 22),
                  child: child,
                ),
              )
            else
              Flexible(
                child: Padding(
                  padding: contentPadding ?? EdgeInsets.all(isMobile ? 16 : 22),
                  child: child,
                ),
              ),

            // Footer Section
            if ((actions != null && actions!.isNotEmpty) || footerLeft != null) ...[
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 22,
                  vertical: isMobile ? 12 : 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (footerLeft != null) ...[
                            footerLeft!,
                            const SizedBox(height: 10),
                          ],
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: actions ?? [],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (footerLeft != null)
                            Expanded(child: footerLeft!)
                          else
                            const SizedBox.shrink(),
                          const SizedBox(width: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.end,
                            children: actions ?? [],
                          ),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
