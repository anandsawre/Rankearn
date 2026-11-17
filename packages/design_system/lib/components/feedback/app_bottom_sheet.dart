import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Reusable, fully tokenized bottom sheet component for Rankearn.
///
/// Features:
/// - Smooth slide-down gesture dismissal (`enableDrag: true`, `isDismissible: true`).
/// - Subtle drag handle pill at the top indicating slide-down interactivity.
/// - Flexible header support (custom widget or standard leading icon, title, subtitle & badges).
/// - Optional close button (disabled by default for a clean slide-down experience).
/// - Sticky bottom action CTA support.
/// - Responsive max-width constraints for tablet/desktop centering.
/// - Built with 100% centralized design system tokens.
class AppBottomSheet extends StatelessWidget {
  /// Custom header widget. If provided, overrides [title], [subtitle], and [leadingIcon].
  final Widget? header;

  /// Main title text for the standard header.
  final String? title;

  /// Subtitle or secondary caption text.
  final String? subtitle;

  /// Icon or graphic pod displayed on the left of the title.
  final Widget? leadingIcon;

  /// Additional trailing widget in the header (e.g. status badge, counter).
  final Widget? headerTrailing;

  /// Whether to display the top drag handle pill (slide down indicator). Defaults to true.
  final bool showDragHandle;

  /// Whether to display a close 'X' button in the header. Defaults to false.
  final bool showCloseButton;

  /// Callback when the sheet or close button is tapped.
  final VoidCallback? onClose;

  /// Ratio of screen height for maximum sheet expansion. Defaults to 0.88 (88%).
  final double maxHeightRatio;

  /// Maximum horizontal width for the sheet (centered on larger screens). Defaults to 640px.
  final double maxWidth;

  /// Custom padding around the sheet content.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether the body [child] should automatically be wrapped in a scroll view. Defaults to true.
  final bool scrollable;

  /// Main body content widget.
  final Widget child;

  /// Optional sticky bottom action widget (e.g. CTA button, primary submit).
  final Widget? bottomAction;

  const AppBottomSheet({
    super.key,
    this.header,
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.headerTrailing,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.onClose,
    this.maxHeightRatio = 0.88,
    this.maxWidth = AppSpacing.bottomSheetMaxWidth,
    this.contentPadding,
    this.scrollable = true,
    required this.child,
    this.bottomAction,
  });

  /// Opens the bottom sheet with standard modal configuration and dismiss gestures.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    bool useRootNavigator = true,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      barrierColor: barrierColor ?? AppColors.bottomSheetBarrier,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * maxHeightRatio,
          maxWidth: maxWidth,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bottomSheetBg,
          borderRadius: AppRadii.bottomSheet,
          boxShadow: AppShadows.bottomSheet,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: contentPadding ?? AppSpacing.bottomSheetPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Drag Handle Pill
                if (showDragHandle) ...[
                  Center(
                    child: Container(
                      width: AppSpacing.bottomSheetDragHandleWidth,
                      height: AppSpacing.bottomSheetDragHandleHeight,
                      margin: const EdgeInsets.only(top: 4, bottom: 14),
                      decoration: const BoxDecoration(
                        color: AppColors.bottomSheetDragHandle,
                        borderRadius: AppRadii.bottomSheetDragHandle,
                      ),
                    ),
                  ),
                ],

                // 2. Header Section
                if (header != null) ...[
                  header!,
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.bottomSheetBorder, height: 1),
                  const SizedBox(height: 14),
                ] else if (title != null) ...[
                  _buildStandardHeader(context),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.bottomSheetBorder, height: 1),
                  const SizedBox(height: 14),
                ],

                // 3. Scrollable or Flexible Body
                if (scrollable)
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: child,
                    ),
                  )
                else
                  Flexible(child: child),

                // 4. Sticky Bottom Action CTA
                if (bottomAction != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: bottomAction!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bottomSheetTitle,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bottomSheetSubtitle,
                ),
              ],
            ],
          ),
        ),
        if (headerTrailing != null) ...[
          const SizedBox(width: 10),
          headerTrailing!,
        ],
        if (showCloseButton) ...[
          const SizedBox(width: 6),
          IconButton(
            onPressed: onClose ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textSecondary,
            splashRadius: 20,
          ),
        ],
      ],
    );
  }
}
