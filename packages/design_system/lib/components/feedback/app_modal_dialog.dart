import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// A rich, responsive, and visually stunning modal dialog component.
///
/// Features:
/// - Full-width vibrant gradient hero header banner with glassmorphic icon pod.
/// - Crisp white typography with soft translucent subtitles.
/// - Responsive adaptive layout for mobile (<640px), tablet, and desktop.
/// - Soft shadow, rounded corners, and clean separation between header, content, and footer.
/// - Integrated standard input decoration helper for forms.
/// - Smooth scale-fade cubic transition animation (`AppModalDialog.show`).
class AppModalDialog extends StatelessWidget {
  final Widget? icon;
  final IconData? iconData;
  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Gradient? headerGradient;
  final List<Color>? gradientColors;
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
    required this.title,
    this.subtitle,
    this.headerTrailing,
    this.showCloseButton = true,
    this.onClose,
    this.headerGradient,
    this.gradientColors,
    this.maxWidth = 640,
    this.maxHeight,
    this.contentPadding,
    this.scrollable = false,
    required this.child,
    this.footerLeft,
    this.actions,
  });

  /// Opens the dialog with an attractive scale-fade motion and backdrop blur.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: const Color(0x730F172A),
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

  /// Default header gradient colors (vibrant orange gradient)
  static const List<Color> defaultGradientColors = [
    Color(0xFFFF9500),
    Color(0xFFF59E0B),
  ];

  /// Default primary action button color matching the orange header
  static const Color defaultPrimaryColor = Color(0xFFFF9500);

  /// Standard primary action button style matching the dialog's orange theme
  static ButtonStyle primaryButtonStyle({Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? defaultPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 0,
    );
  }

  /// Convenience factory for a dialog primary action button
  static Widget primaryButton({
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    Widget? icon,
  }) {
    final style = primaryButtonStyle(backgroundColor: backgroundColor);
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: icon,
        label: child,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }

  /// Standard input decoration matching Rankearn design system
  static InputDecoration inputDecoration(
    String hint, {
    String? labelText,
    TextStyle? hintStyle,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
    TextStyle? prefixStyle,
    String? suffixText,
    TextStyle? suffixStyle,
    Color? focusColor,
    Color? fillColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    bool? isDense,
  }) {
    final activeFocus = focusColor ?? defaultPrimaryColor;
    final effectiveRadius = borderRadius ?? AppRadii.borderSm;
    final effectiveBorderColor = borderColor ?? const Color(0xFFCBD5E1);
    return InputDecoration(
      labelText: labelText,
      hintText: hint.isEmpty ? null : hint,
      hintStyle: hintStyle ?? const TextStyle(fontSize: 12, color: AppColors.textMuted),
      prefixText: prefixText,
      prefixStyle: prefixStyle,
      suffixText: suffixText,
      suffixStyle: suffixStyle,
      filled: true,
      fillColor: fillColor ?? Colors.white,
      isDense: isDense ?? true,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(color: effectiveBorderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(color: effectiveBorderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(color: activeFocus, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 640;

    final effectiveMaxWidth = isMobile ? math.max(300.0, media.size.width - 24) : maxWidth;
    final effectiveMaxHeight = maxHeight ?? (media.size.height * 0.88);

    final resolvedGradient = headerGradient ??
        LinearGradient(
          colors: gradientColors ?? defaultGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withAlpha(35),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: effectiveMaxWidth,
          maxHeight: effectiveMaxHeight,
        ),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Rich Gradient Hero Header
            Container(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 22,
                isMobile ? 16 : 18,
                isMobile ? 12 : 16,
                isMobile ? 16 : 18,
              ),
              decoration: BoxDecoration(
                gradient: resolvedGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  // Glassmorphic Icon Pod
                  if (icon != null)
                    icon!
                  else if (iconData != null)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withAlpha(60), width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: Icon(iconData, color: Colors.white, size: 22),
                    ),
                  if (icon != null || iconData != null) const SizedBox(width: 14),

                  // Title & Subtitle in crisp white
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withAlpha(210),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget or badge
                  if (headerTrailing != null) ...[
                    const SizedBox(width: 8),
                    headerTrailing!,
                  ],

                  // Glass Close Button
                  if (showCloseButton) ...[
                    const SizedBox(width: 6),
                    Material(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        hoverColor: Colors.white.withAlpha(60),
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

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
              Theme(
                data: Theme.of(context).copyWith(
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: primaryButtonStyle(),
                  ),
                ),
                child: Container(
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
                            Flexible(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.end,
                                children: actions ?? [],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }
}
