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

/// Centralized, theme-tokenized Rankearn Dropdown Form Component.
///
/// Features rich UI styling, custom borders, prefix/suffix icons,
/// tokenized typography and colors, and versatile item configurations.
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final Widget? labelWidget;
  final TextStyle? labelStyle;
  final String? hint;
  final Widget? hintWidget;
  final TextStyle? hintStyle;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final AutovalidateMode? autovalidateMode;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isExpanded;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? dropdownColor;
  final BorderRadius? borderRadius;
  final TextStyle? style;
  final double? menuMaxHeight;
  final int elevation;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    this.labelWidget,
    this.labelStyle,
    this.hint,
    this.hintWidget,
    this.hintStyle,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isExpanded = true,
    this.isDense = false,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.dropdownColor,
    this.borderRadius,
    this.style,
    this.menuMaxHeight = 320,
    this.elevation = 4,
    this.enabled = true,
  });

  /// Convenience constructor for raw items (e.g. List<T> or List<String>)
  /// with an optional item label mapper function.
  factory AppDropdown.simple({
    Key? key,
    String? label,
    Widget? labelWidget,
    TextStyle? labelStyle,
    String? hint,
    Widget? hintWidget,
    TextStyle? hintStyle,
    required T? value,
    required List<T> items,
    String Function(T item)? itemLabel,
    required ValueChanged<T?>? onChanged,
    FormFieldValidator<T>? validator,
    FormFieldSetter<T>? onSaved,
    AutovalidateMode? autovalidateMode,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isExpanded = true,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? dropdownColor,
    BorderRadius? borderRadius,
    TextStyle? style,
    double? menuMaxHeight = 320,
    int elevation = 4,
    bool enabled = true,
  }) {
    return AppDropdown<T>(
      key: key,
      label: label,
      labelWidget: labelWidget,
      labelStyle: labelStyle,
      hint: hint,
      hintWidget: hintWidget,
      hintStyle: hintStyle,
      value: value,
      items: items.map((item) {
        final labelStr = itemLabel != null ? itemLabel(item) : item.toString();
        return AppDropdownItem<T>(
          value: item,
          label: labelStr,
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isExpanded: isExpanded,
      isDense: isDense,
      contentPadding: contentPadding,
      fillColor: fillColor,
      borderColor: borderColor,
      focusedBorderColor: focusedBorderColor,
      errorBorderColor: errorBorderColor,
      dropdownColor: dropdownColor,
      borderRadius: borderRadius,
      style: style,
      menuMaxHeight: menuMaxHeight,
      elevation: elevation,
      enabled: enabled,
    );
  }

  /// Convenience constructor specifically for String dropdowns
  static AppDropdown<String> strings({
    Key? key,
    String? label,
    Widget? labelWidget,
    TextStyle? labelStyle,
    String? hint,
    Widget? hintWidget,
    TextStyle? hintStyle,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
    AutovalidateMode? autovalidateMode,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isExpanded = true,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? dropdownColor,
    BorderRadius? borderRadius,
    TextStyle? style,
    double? menuMaxHeight = 320,
    int elevation = 4,
    bool enabled = true,
  }) {
    return AppDropdown<String>.simple(
      key: key,
      label: label,
      labelWidget: labelWidget,
      labelStyle: labelStyle,
      hint: hint,
      hintWidget: hintWidget,
      hintStyle: hintStyle,
      value: value,
      items: items,
      itemLabel: (item) => item,
      onChanged: onChanged,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isExpanded: isExpanded,
      isDense: isDense,
      contentPadding: contentPadding,
      fillColor: fillColor,
      borderColor: borderColor,
      focusedBorderColor: focusedBorderColor,
      errorBorderColor: errorBorderColor,
      dropdownColor: dropdownColor,
      borderRadius: borderRadius,
      style: style,
      menuMaxHeight: menuMaxHeight,
      elevation: elevation,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppRadii.borderMd;
    final effectiveFillColor = fillColor ?? (enabled ? AppColors.surfaceSubtle : AppColors.surfaceMuted);
    final effectiveBorderColor = borderColor ?? AppColors.borderSubtle;
    final effectiveFocusedBorderColor = focusedBorderColor ?? AppColors.brandPrimary;
    final effectiveErrorBorderColor = errorBorderColor ?? AppColors.errorRose;
    final effectiveDropdownColor = dropdownColor ?? AppColors.surface;

    final effectiveTextStyle = style ??
        AppTypography.bodyMedium.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          fontWeight: FontWeight.w600,
        );

    final effectiveHintStyle = hintStyle ??
        AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        );

    final effectiveContentPadding = contentPadding ??
        (isDense
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 12));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelWidget != null) ...[
          labelWidget!,
          const SizedBox(height: AppSpacing.xs),
        ] else if (label != null) ...[
          Text(
            label!,
            style: labelStyle ??
                AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 11.5,
                ),
          ),
          const SizedBox(height: 4),
        ],
        DropdownButtonFormField<T>(
          key: key,
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          onSaved: onSaved,
          autovalidateMode: autovalidateMode,
          isExpanded: isExpanded,
          isDense: isDense,
          hint: hintWidget ?? (hint != null ? Text(hint!, style: effectiveHintStyle) : null),
          elevation: elevation,
          menuMaxHeight: menuMaxHeight,
          dropdownColor: effectiveDropdownColor,
          borderRadius: effectiveBorderRadius,
          style: effectiveTextStyle,
          icon: suffixIcon ??
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
          decoration: InputDecoration(
            filled: true,
            isDense: isDense,
            fillColor: effectiveFillColor,
            prefixIcon: prefixIcon,
            errorText: errorText,
            contentPadding: effectiveContentPadding,
            border: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveErrorBorderColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveErrorBorderColor, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveBorderColor.withAlpha(100)),
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
                      style: effectiveTextStyle.copyWith(
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

/// Compact, theme-tokenized Dropdown component ideal for table toolbars,
/// filter bars, and header action controls.
class AppDropdownFilter<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T item)? itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final Widget? prefixIcon;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const AppDropdownFilter({
    super.key,
    required this.value,
    required this.items,
    this.itemLabel,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.height = 34,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(8);
    final effectiveBgColor = backgroundColor ?? AppColors.surfaceSubtle;
    final effectiveBorderColor = borderColor ?? AppColors.borderSubtle;
    final effectiveTextStyle = textStyle ??
        AppTypography.bodyMedium.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
    final effectiveHintStyle = hintStyle ??
        AppTypography.bodyMedium.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        );

    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorderColor, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null ? Text(hint!, style: effectiveHintStyle) : null,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: effectiveRadius,
          style: effectiveTextStyle,
          onChanged: onChanged,
          items: items.map((item) {
            final label = itemLabel != null ? itemLabel!(item) : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 6),
                  ],
                  Text(label, style: effectiveTextStyle),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
