import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../../tokens/shadows.dart';

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
  final double? height;
  final Color? focusedBorderColor;
  final Color? cursorColor;

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
    this.height,
    this.focusedBorderColor,
    this.cursorColor,
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
    this.fillColor = AppColors.adminCardBackground,
    this.borderRadius,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.isDense = true,
    this.style,
    this.labelStyle,
    this.floatingLabelStyle,
    this.hintStyle,
    this.maxLength,
    this.autofillHints,
    this.height = AppSpacing.adminControlHeight,
    this.focusedBorderColor,
    this.cursorColor,
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
    this.height = AppSpacing.adminControlHeightDense,
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
        autofillHints = null,
        focusedBorderColor = null,
        cursorColor = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;
  late FocusNode _focusNode;
  bool _internalFocusNode = false;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused && mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_internalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
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
      focusNode: _focusNode,
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
      cursorColor: widget.cursorColor,
      style: effectiveStyle,
      decoration: InputDecoration(
        constraints: widget.height != null
            ? BoxConstraints(minHeight: widget.height!)
            : null,
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
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffixIcon,
        filled: true,
        isDense: widget.isDense,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        fillColor: widget.enabled
            ? (widget.fillColor ?? AppColors.adminCardBackground)
            : (widget.fillColor ?? AppColors.adminCardBackground).withValues(alpha: 0.6),
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
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? AppColors.adminPurple,
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
  /// Uses a matching AnimatedContainer, BoxDecoration, Border.all and BoxConstraints
  /// identical to [AppDropdown] to guarantee 100% pixel-perfect equal height (44.0px).
  Widget _buildStandardField(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadii.adminControl;
    final effectiveStyle = widget.style ?? AppTypography.adminInput;
    final effectiveHintStyle = widget.hintStyle ?? AppTypography.adminHint;
    final effectiveLabelStyle = widget.labelStyle ?? AppTypography.adminFieldLabel;
    final effectiveFillColor = widget.enabled
        ? (widget.fillColor ?? AppColors.adminCardBackground)
        : (widget.fillColor ?? AppColors.adminCardBackground).withAlpha(128);
    final isMultiline = (widget.maxLines > 1);
    final effectiveHeight = widget.height ?? (isMultiline ? null : AppSpacing.adminControlHeight);

    final effectiveFocusedColor = widget.focusedBorderColor ?? AppColors.adminPurple;
    final borderColor = _isFocused
        ? effectiveFocusedColor
        : (_isHovered
            ? effectiveFocusedColor.withAlpha(120)
            : AppColors.adminBorder);

    // ── Prefix icon inside InputDecoration ──────────────────────────────────
    Widget? prefixIconWidget;
    if (widget.prefixIcon != null && !isMultiline) {
      prefixIconWidget = Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: widget.prefixIcon,
      );
    }

    // ── Suffix / password toggle inside InputDecoration ─────────────────────
    Widget? suffixIconWidget;
    if (widget.isPassword) {
      suffixIconWidget = IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
          size: 20,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    } else if (widget.suffixIcon != null) {
      suffixIconWidget = Padding(
        padding: const EdgeInsets.only(right: 8),
        child: widget.suffixIcon,
      );
    }

    // ── Content padding ──────────────────────────────────────────────────────
    // Balanced vertical padding ensures text is vertically centered inside 44px container
    EdgeInsetsGeometry contentPadding;
    if (widget.contentPadding != null) {
      contentPadding = widget.contentPadding!;
    } else if (isMultiline) {
      contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
    } else {
      contentPadding = EdgeInsets.only(
        left: widget.prefixIcon != null ? 0 : 14,
        right: (widget.suffixIcon != null || widget.isPassword) ? 0 : 14,
        top: 11,
        bottom: 11,
      );
    }

    Widget box = MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.text : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.enabled && !_isHovered && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isHovered = true);
          });
        }
      },
      onExit: (_) {
        if (widget.enabled && _isHovered && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isHovered = false);
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: effectiveHeight,
        constraints: effectiveHeight != null
            ? BoxConstraints.tightFor(height: effectiveHeight)
            : const BoxConstraints(minHeight: 44.0),
        alignment: isMultiline ? Alignment.topLeft : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: effectiveFillColor,
          borderRadius: effectiveRadius,
          border: Border.all(
            color: borderColor,
            width: _isFocused ? 1.5 : 1.0,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.adminPurple.withValues(alpha: 0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppShadows.subtle,
        ),
        // ── Single TextFormField fills the entire box ────────────────────────
        // isCollapsed: false  → Flutter Web properly centers RenderEditable
        // prefixIcon inside InputDecoration → icon shares the same baseline
        // No outer Row, no Transform.translate hacks needed
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
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
          cursorColor: widget.cursorColor,
          style: effectiveStyle,
          textAlignVertical: isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
          decoration: InputDecoration(
            prefixIcon: prefixIconWidget,
            prefixIconConstraints: prefixIconWidget != null
                ? BoxConstraints(
                    minWidth: 42,
                    minHeight: effectiveHeight ?? AppSpacing.adminControlHeight,
                    maxHeight: effectiveHeight ?? AppSpacing.adminControlHeight,
                  )
                : null,
            suffixIcon: suffixIconWidget,
            suffixIconConstraints: suffixIconWidget != null
                ? BoxConstraints(
                    minWidth: 36,
                    minHeight: effectiveHeight ?? AppSpacing.adminControlHeight,
                    maxHeight: effectiveHeight ?? AppSpacing.adminControlHeight,
                  )
                : null,
            hintText: widget.hintText,
            hintStyle: effectiveHintStyle,
            prefixText: widget.prefixText,
            prefixStyle: widget.prefixStyle,
            isDense: true,
            isCollapsed: false, // KEY: false = Flutter Web centers text properly
            filled: false,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: contentPadding,
          ),
        ),
      ),
    );

    if (widget.label == null) {
      return box;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: effectiveLabelStyle,
        ),
        const SizedBox(height: AppSpacing.sm),
        box,
      ],
    );
  }
}
