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
  final bool fullScreenOnMobile;
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
    this.fullScreenOnMobile = true,
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
        final isMobile = MediaQuery.sizeOf(ctx).width < 640;
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        if (isMobile) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(curve),
            child: FadeTransition(
              opacity: curve,
              child: child,
            ),
          );
        }
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
    BoxConstraints? constraints,
    bool isMultiline = false,
  }) {
    final activeFocus = focusColor ?? defaultPrimaryColor;
    final effectiveRadius = borderRadius ?? AppRadii.borderSm;
    final effectiveBorderColor = borderColor ?? const Color(0xFFCBD5E1);

    final isActuallyMultiline = isMultiline ||
        (constraints != null && (constraints.maxHeight > 40.0 || constraints.minHeight > 40.0));

    final effectiveConstraints = constraints ??
        (isActuallyMultiline ? null : const BoxConstraints(minHeight: 40.0, maxHeight: 40.0));

    final effectiveSuffixConstraints = isActuallyMultiline
        ? (suffixIcon != null ? const BoxConstraints(minWidth: 36, minHeight: 36) : null)
        : (suffixIcon != null
            ? const BoxConstraints(minWidth: 36, minHeight: 40, maxHeight: 40)
            : const BoxConstraints(minWidth: 0, maxWidth: 0, minHeight: 40, maxHeight: 40));

    final effectiveSuffix = suffixIcon ??
        (isActuallyMultiline ? null : const SizedBox(width: 0, height: 40));

    final effectiveContentPadding = contentPadding ??
        (isActuallyMultiline
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 0));

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
      contentPadding: effectiveContentPadding,
      constraints: effectiveConstraints,
      prefixIconConstraints: isActuallyMultiline
          ? (prefixIcon != null ? const BoxConstraints(minWidth: 36, minHeight: 36) : null)
          : const BoxConstraints(minWidth: 36, minHeight: 40, maxHeight: 40),
      suffixIconConstraints: effectiveSuffixConstraints,
      prefixIcon: prefixIcon,
      suffixIcon: effectiveSuffix,
      border: OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(color: effectiveBorderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(color: effectiveBorderColor, width: 1.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(color: effectiveBorderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(color: activeFocus, width: 1.5),
      ),
    );
  }

  /// Checks whether a dialog header gradient is explicitly destructive (danger/delete)
  static bool _isDestructiveGradient(List<Color>? colors) {
    if (colors == null || colors.isEmpty) return false;
    final c0 = colors[0].toARGB32();
    return c0 == 0xFFDC2626 || c0 == 0xFFEF4444 || c0 == 0xFFE11D48;
  }

  /// Checks whether a button color is explicitly destructive (danger/delete)
  static bool _isDestructiveButton(Color bg) {
    final argb = bg.toARGB32();
    return argb == 0xFFDC2626 || argb == 0xFFEF4444 || argb == 0xFFE11D48;
  }

  /// Automatically standardizes action buttons to the unified orange theme
  /// Safely filters out any [Spacer] or [Expanded] widgets that could crash inside [Wrap].
  static List<Widget>? _processActions(List<Widget>? rawActions) {
    if (rawActions == null) return null;
    return rawActions
        .where((w) => w is! Spacer && w is! Expanded)
        .map((widget) {
      if (widget is ElevatedButton) {
        final bg = widget.style?.backgroundColor?.resolve({WidgetState.selected}) ??
            widget.style?.backgroundColor?.resolve({});
        if (bg != null && _isDestructiveButton(bg)) {
          return widget; // Preserve red destructive button
        }
        return ElevatedButton(
          key: widget.key,
          onPressed: widget.onPressed,
          onLongPress: widget.onLongPress,
          onHover: widget.onHover,
          onFocusChange: widget.onFocusChange,
          clipBehavior: widget.clipBehavior,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          style: (widget.style ?? ElevatedButton.styleFrom()).copyWith(
            backgroundColor: const WidgetStatePropertyAll(defaultPrimaryColor),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
          ),
          child: widget.child,
        );
      }
      return widget;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = fullScreenOnMobile && (media.size.width < 640);

    final effectiveMaxWidth = isMobile ? media.size.width : maxWidth;
    final effectiveMaxHeight = isMobile ? media.size.height : (maxHeight ?? (media.size.height * 0.88));

    final topPadding = isMobile ? media.padding.top : 0.0;
    final bottomPadding = (isMobile && media.viewInsets.bottom == 0) ? media.padding.bottom : 0.0;

    // If actions contains a Spacer/Expanded and footerLeft is not provided, split left items to footerLeft
    Widget? effectiveFooterLeft = footerLeft;
    List<Widget>? processedActionInput = actions;
    if (actions != null && actions!.any((w) => w is Spacer || w is Expanded)) {
      final spacerIdx = actions!.indexWhere((w) => w is Spacer || w is Expanded);
      if (effectiveFooterLeft == null && spacerIdx > 0) {
        final leftList = actions!.sublist(0, spacerIdx);
        effectiveFooterLeft = leftList.length == 1
            ? leftList.first
            : Row(mainAxisSize: MainAxisSize.min, children: leftList);
      }
      processedActionInput = actions!.sublist(spacerIdx + 1);
    }

    final effectiveActions = _processActions(processedActionInput);

    // Standardize all non-destructive dialogs to the unified orange gradient
    final effectiveGradientColors = (gradientColors == null || !_isDestructiveGradient(gradientColors))
        ? defaultGradientColors
        : gradientColors!;

    final resolvedGradient = headerGradient ??
        LinearGradient(
          colors: effectiveGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final hasFooter = (effectiveActions != null && effectiveActions.isNotEmpty) || effectiveFooterLeft != null;
    final bodyBottomPadding = (!hasFooter && isMobile && media.viewInsets.bottom == 0)
        ? (16.0 + bottomPadding)
        : (isMobile ? 16.0 : 22.0);

    final effectiveContentPadding = contentPadding ??
        EdgeInsets.fromLTRB(
          isMobile ? 16 : 22,
          isMobile ? 16 : 22,
          isMobile ? 16 : 22,
          bodyBottomPadding,
        );

    return Dialog(
      shape: isMobile
          ? const RoundedRectangleBorder()
          : const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: Colors.transparent,
      insetPadding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: isMobile ? double.infinity : null,
        height: isMobile ? double.infinity : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
          boxShadow: isMobile
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withAlpha(35),
                    blurRadius: 36,
                    offset: const Offset(0, 18),
                  ),
                ],
        ),
        constraints: isMobile
            ? const BoxConstraints.expand()
            : BoxConstraints(
                maxWidth: effectiveMaxWidth,
                maxHeight: effectiveMaxHeight,
              ),
        child: Material(
          color: Colors.white,
          shape: isMobile
              ? const RoundedRectangleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rich Gradient Hero Header
              Container(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 22,
                  (isMobile ? 12 : 18) + topPadding,
                  isMobile ? 12 : 16,
                  isMobile ? 14 : 18,
                ),
                decoration: BoxDecoration(
                  gradient: resolvedGradient,
                  borderRadius: isMobile
                      ? BorderRadius.zero
                      : const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    // Glassmorphic Icon Pod
                    if (icon != null)
                      icon!
                    else if (iconData != null)
                      Container(
                        width: isMobile ? 36 : 40,
                        height: isMobile ? 36 : 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(45),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withAlpha(60), width: 1.2),
                        ),
                        alignment: Alignment.center,
                        child: Icon(iconData, color: Colors.white, size: isMobile ? 20 : 22),
                      ),
                    if (icon != null || iconData != null) SizedBox(width: isMobile ? 10 : 14),

                    // Title & Subtitle in crisp white
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 16.5,
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
                                fontSize: isMobile ? 11 : 11.5,
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
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 8 : 6),
                            child: Icon(Icons.close_rounded, size: isMobile ? 20 : 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Body Content
              if (scrollable)
                isMobile
                    ? Expanded(
                        child: SingleChildScrollView(
                          padding: effectiveContentPadding,
                          child: child,
                        ),
                      )
                    : Flexible(
                        child: SingleChildScrollView(
                          padding: effectiveContentPadding,
                          child: child,
                        ),
                      )
              else
                isMobile
                    ? Expanded(
                        child: Padding(
                          padding: effectiveContentPadding,
                          child: child,
                        ),
                      )
                    : Flexible(
                        child: Padding(
                          padding: effectiveContentPadding,
                          child: child,
                        ),
                      ),

              // Footer Section
              if (hasFooter) ...[
                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                Theme(
                  data: Theme.of(context).copyWith(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: primaryButtonStyle(),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 16 : 22,
                      isMobile ? 12 : 14,
                      isMobile ? 16 : 22,
                      (isMobile ? 12 : 14) + bottomPadding,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: isMobile
                          ? BorderRadius.zero
                          : const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                    ),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (effectiveFooterLeft != null) ...[
                                effectiveFooterLeft,
                                const SizedBox(height: 10),
                              ],
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: effectiveActions ?? [],
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (effectiveFooterLeft != null)
                                Expanded(child: effectiveFooterLeft)
                              else
                                const SizedBox.shrink(),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.end,
                                  children: effectiveActions ?? [],
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
