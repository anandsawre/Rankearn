import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';

/// Rankearn Reusable Form & Text Field
/// Supports standard external labels, floating animated labels on border edge,
/// password visibility toggling, prefix text (+91), icons, and custom validation.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final int maxLines;
  final FocusNode? focusNode;
  final bool isFloatingLabel;
  final FloatingLabelBehavior floatingLabelBehavior;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? floatingLabelStyle;
  final TextStyle? hintStyle;
  final int? maxLength;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.prefixStyle,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.isFloatingLabel = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.never,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.isDense = false,
    this.style,
    this.labelStyle,
    this.floatingLabelStyle,
    this.hintStyle,
    this.maxLength,
    this.autofillHints,
  });

  /// Factory constructor for modern floating-label form inputs (e.g. Auth Screen).
  /// Animates the label directly to the input box edge on focus.
  const AppTextField.floating({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.prefixStyle,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.fillColor = Colors.white,
    this.borderRadius,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.isDense = true,
    this.style,
    this.labelStyle,
    this.floatingLabelStyle,
    this.hintStyle,
    this.maxLength,
    this.autofillHints,
  })  : isFloatingLabel = true,
        floatingLabelBehavior = FloatingLabelBehavior.auto;

  /// Factory constructor for tokenized search inputs across admin data tables.
  const AppTextField.search({
    super.key,
    this.hintText = 'Search...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon = const Icon(Icons.search_rounded, size: 18, color: AppColors.adminSecondaryText),
    this.suffixIcon,
    this.fillColor = AppColors.adminBackground,
    this.borderRadius,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.isDense = true,
    this.style,
    this.hintStyle,
    this.focusNode,
  })  : label = null,
        isPassword = false,
        keyboardType = TextInputType.text,
        textCapitalization = TextCapitalization.none,
        inputFormatters = null,
        prefixText = null,
        prefixStyle = null,
        validator = null,
        enabled = true,
        maxLines = 1,
        isFloatingLabel = false,
        floatingLabelBehavior = FloatingLabelBehavior.never,
        labelStyle = null,
        floatingLabelStyle = null,
        maxLength = null,
        autofillHints = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFloatingLabel) {
      return _buildFloatingField(context);
    }
    return _buildStandardField(context);
  }

  /// Modern floating-label variant with smooth border animation
  Widget _buildFloatingField(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadii.adminControl;
    final effectiveStyle = widget.style ?? AppTypography.formInput;
    final effectiveLabelStyle = widget.labelStyle ?? AppTypography.formLabel;
    final effectiveFloatingStyle = widget.floatingLabelStyle ?? AppTypography.formFloatingLabel;
    final effectivePrefixStyle = widget.prefixStyle ?? AppTypography.formFloatingLabel.copyWith(color: AppColors.textPrimary);

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      style: effectiveStyle,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ?? AppTypography.formHint,
        floatingLabelBehavior: widget.floatingLabelBehavior,
        labelStyle: effectiveLabelStyle,
        floatingLabelStyle: effectiveFloatingStyle,
        prefixIcon: widget.prefixIcon,
        prefixText: widget.prefixText,
        prefixStyle: effectivePrefixStyle,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffixIcon,
        filled: true,
        isDense: widget.isDense,
        fillColor: widget.enabled
            ? (widget.fillColor ?? Colors.white)
            : (widget.fillColor ?? Colors.white).withValues(alpha: 0.6),
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(color: AppColors.adminBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(color: AppColors.adminBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(
            color: AppColors.adminPurple,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(
            color: AppColors.adminDanger,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(
            color: AppColors.adminDanger,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Standard variant with external top label (used across Admin & Showcase)
  Widget _buildStandardField(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadii.adminControl;
    final effectiveStyle = widget.style ?? AppTypography.adminTablePrimary;
    final effectiveHintStyle = widget.hintStyle ?? AppTypography.adminTableSecondary;
    final effectiveLabelStyle = widget.labelStyle ?? AppTypography.adminFieldLabel;
    final effectiveFillColor = widget.enabled
        ? (widget.fillColor ?? Colors.white)
        : (widget.fillColor ?? Colors.white).withAlpha(128);

    final field = TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      style: effectiveStyle,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: effectiveHintStyle,
        prefixIcon: widget.prefixIcon,
        prefixText: widget.prefixText,
        prefixStyle: widget.prefixStyle,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffixIcon,
        filled: true,
        isDense: widget.isDense,
        fillColor: effectiveFillColor,
        contentPadding: widget.contentPadding ??
            (widget.isDense
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        border: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(color: AppColors.adminBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(color: AppColors.adminBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(
            color: AppColors.adminPurple,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(color: AppColors.adminDanger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: const BorderSide(color: AppColors.adminDanger, width: 1.5),
        ),
      ),
    );

    if (widget.label == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: effectiveLabelStyle,
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
