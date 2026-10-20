import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';

/// Item data model for [AppDropdown]
class AppDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.leading,
    this.trailing,
    this.enabled = true,
  });
}

/// Centralized Rankearn Dropdown Component
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final Widget? prefixIcon;
  final bool isExpanded;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.prefixIcon,
    this.isExpanded = true,
    this.isDense = false,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          isExpanded: isExpanded,
          isDense: isDense,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: borderRadius ?? AppRadii.borderMd,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? AppColors.surface,
            prefixIcon: prefixIcon,
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            errorText: errorText,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: borderRadius ?? AppRadii.borderMd,
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? AppRadii.borderMd,
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? AppRadii.borderMd,
              borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? AppRadii.borderMd,
              borderSide: const BorderSide(color: AppColors.errorRose),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: Row(
                children: [
                  if (item.leading != null) ...[
                    item.leading!,
                    const SizedBox(width: AppSpacing.sm),
                  ] else if (item.icon != null) ...[
                    Icon(item.icon, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: item.enabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.trailing != null) item.trailing!,
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
