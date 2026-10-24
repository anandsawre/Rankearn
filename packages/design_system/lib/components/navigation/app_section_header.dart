import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// Standardized, reusable section header with title, optional leading icon,
/// and optional "View All →" action link.
class AppSectionHeader extends StatelessWidget {
  /// Main section title.
  final String title;

  /// Optional leading icon.
  final IconData? icon;

  /// Icon tint color. Defaults to Brand Blue (#2587F8).
  final Color iconColor;

  /// Optional action label (e.g., "View All"). Defaults to "View All" if [onAction] is non-null.
  final String? actionLabel;

  /// Callback when action link is tapped.
  final VoidCallback? onAction;

  /// Action link text and arrow color. Defaults to Brand Blue (#2587F8).
  final Color actionColor;

  /// Optional custom trailing widget (if provided, overrides [actionLabel]).
  final Widget? trailing;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor = const Color(0xFF2587F8),
    this.actionLabel = 'View All',
    this.onAction,
    this.actionColor = const Color(0xFF2587F8),
    this.trailing,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Leading Icon + Title
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  title,
                  style:
                      titleStyle ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // 2. Trailing Action Link
        if (trailing != null)
          trailing!
        else if (onAction != null && actionLabel != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: TextStyle(
                        color: actionColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: actionColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
