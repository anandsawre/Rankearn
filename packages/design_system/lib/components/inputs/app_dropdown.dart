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

/// Centralized, theme-tokenized Rankearn Professional Dropdown Component.
///
/// Features a modern, anchored popover menu that opens smoothly directly
/// beneath the field without covering the input or label, complete with
/// hover effects, active emerald badge, rotating chevron, and token styling.
class AppDropdown<T> extends StatefulWidget {
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
  final Color? selectedItemColor;
  final Color? selectedItemBackgroundColor;

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
    this.menuMaxHeight = 240,
    this.elevation = 4,
    this.enabled = true,
    this.selectedItemColor,
    this.selectedItemBackgroundColor,
  });

  /// Convenience factory for simple lists of items with optional label mapping
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
    double? menuMaxHeight = 240,
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
        return AppDropdownItem<T>(value: item, label: labelStr);
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

  /// Convenience helper specifically for strings
  static Widget strings({
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
    double? menuMaxHeight = 240,
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
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isHovered = false;

  late final AnimationController _animationController;
  late final Animation<double> _chevronAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _chevronAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _closeDropdown(animated: false);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen || !widget.enabled) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox? ??
        context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - (offset.dy + size.height);
    final openUpward = spaceBelow < 200 && offset.dy > spaceBelow;

    final effectiveRadius = widget.borderRadius ?? AppRadii.borderMd;
    final effectiveDropdownColor = widget.dropdownColor ?? AppColors.surface;
    final effectiveBorderColor = widget.borderColor ?? AppColors.borderSubtle;
    final effectiveTextStyle =
        widget.style ??
        AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Full-screen backdrop to dismiss on outside tap
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
              ),
            ),
            // Positioned Anchored Dropdown Menu directly flush beneath the input box
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: openUpward
                    ? Offset(0, -(widget.menuMaxHeight ?? 240) - 1)
                    : Offset(0, size.height + 1),
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      alignment: openUpward
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: widget.menuMaxHeight ?? 240,
                        ),
                        decoration: BoxDecoration(
                          color: effectiveDropdownColor,
                          borderRadius: effectiveRadius,
                          border: Border.all(
                            color: effectiveBorderColor,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF10194F,
                              ).withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: const Color(
                                0xFF10194F,
                              ).withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: effectiveRadius,
                          child: RawScrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 4,
                            radius: const Radius.circular(4),
                            thumbColor: AppColors.textMuted.withValues(
                              alpha: 0.35,
                            ),
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              shrinkWrap: true,
                              itemCount: widget.items.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                thickness: 0.5,
                                color: AppColors.borderSubtle.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              itemBuilder: (context, index) {
                                final item = widget.items[index];
                                final isSelected = item.value == widget.value;

                                return _AppDropdownItemWidget<T>(
                                  item: item,
                                  isSelected: isSelected,
                                  textStyle: effectiveTextStyle,
                                  selectedColor: widget.selectedItemColor,
                                  selectedBackgroundColor: widget.selectedItemBackgroundColor,
                                  onTap: () {
                                    _closeDropdown();
                                    widget.onChanged?.call(item.value);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward(from: 0.0);
  }

  void _closeDropdown({bool animated = true}) {
    if (!_isOpen) return;

    if (animated) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        if (mounted) setState(() => _isOpen = false);
      });
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? AppRadii.borderMd;
    final effectiveFillColor =
        widget.fillColor ??
        (widget.enabled ? AppColors.surfaceSubtle : AppColors.surfaceMuted);
    final effectiveBorderColor = _isOpen
        ? (widget.focusedBorderColor ?? AppColors.brandPrimary)
        : _isHovered
        ? (widget.borderColor ?? AppColors.borderSubtle).withValues(alpha: 0.8)
        : (widget.borderColor ?? AppColors.borderSubtle);

    final effectiveTextStyle =
        widget.style ??
        AppTypography.bodyMedium.copyWith(
          color: widget.enabled ? AppColors.textPrimary : AppColors.textMuted,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        );

    final effectiveHintStyle =
        widget.hintStyle ??
        AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        );

    final effectiveContentPadding =
        widget.contentPadding ??
        (widget.isDense
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 12));

    // Find current selected label
    String? selectedLabel;
    Widget? selectedLeading;
    IconData? selectedIcon;
    for (final item in widget.items) {
      if (item.value == widget.value) {
        selectedLabel = item.label;
        selectedLeading = item.leading;
        selectedIcon = item.icon;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelWidget != null) ...[
          widget.labelWidget!,
          const SizedBox(height: AppSpacing.xs),
        ] else if (widget.label != null) ...[
          Text(
            widget.label!,
            style:
                widget.labelStyle ??
                AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 11.5,
                ),
          ),
          const SizedBox(height: 4),
        ],
        CompositedTransformTarget(
          key: _fieldKey,
          link: _layerLink,
          child: MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: (_) {
              if (widget.enabled && !_isHovered) {
                setState(() => _isHovered = true);
              }
            },
            onExit: (_) {
              if (widget.enabled && _isHovered) {
                setState(() => _isHovered = false);
              }
            },
            child: GestureDetector(
              onTap: widget.enabled ? _toggleDropdown : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: effectiveContentPadding,
                decoration: BoxDecoration(
                  color: effectiveFillColor,
                  borderRadius: effectiveBorderRadius,
                  border: Border.all(
                    color: _isOpen
                        ? (widget.focusedBorderColor ?? AppColors.brandPrimary)
                        : (widget.errorText != null)
                        ? (widget.errorBorderColor ?? AppColors.errorRose)
                        : effectiveBorderColor,
                    width: _isOpen ? 1.5 : 1.0,
                  ),
                  boxShadow: _isOpen
                      ? [
                          BoxShadow(
                            color:
                                (widget.focusedBorderColor ??
                                        AppColors.brandPrimary)
                                    .withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      widget.prefixIcon!,
                      const SizedBox(width: 8),
                    ],
                    if (selectedLeading != null) ...[
                      selectedLeading,
                      const SizedBox(width: 8),
                    ] else if (selectedIcon != null) ...[
                      Icon(
                        selectedIcon,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: selectedLabel != null
                          ? Text(
                              selectedLabel,
                              style: effectiveTextStyle,
                              overflow: TextOverflow.ellipsis,
                            )
                          : widget.hintWidget ??
                                Text(
                                  widget.hint ?? '',
                                  style: effectiveHintStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                    ),
                    const SizedBox(width: 6),
                    RotationTransition(
                      turns: _chevronAnimation,
                      child:
                          widget.suffixIcon ??
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: 11,
              color: widget.errorBorderColor ?? AppColors.errorRose,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom item widget with mouse hover transitions and selected emerald state
class _AppDropdownItemWidget<T> extends StatefulWidget {
  final AppDropdownItem<T> item;
  final bool isSelected;
  final TextStyle textStyle;
  final Color? selectedColor;
  final Color? selectedBackgroundColor;
  final VoidCallback onTap;

  const _AppDropdownItemWidget({
    required this.item,
    required this.isSelected,
    required this.textStyle,
    this.selectedColor,
    this.selectedBackgroundColor,
    required this.onTap,
  });

  @override
  State<_AppDropdownItemWidget<T>> createState() =>
      _AppDropdownItemWidgetState<T>();
}

class _AppDropdownItemWidgetState<T> extends State<_AppDropdownItemWidget<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isEnabled = widget.item.enabled;

    final primaryAccent = widget.selectedColor ?? const Color(0xFF00B96B);
    final primaryAccentBg = widget.selectedBackgroundColor ?? const Color(0xFFECFDF5);

    final bgColor = isSelected
        ? primaryAccentBg
        : _isHovered
        ? const Color(0xFFF8FAFC) // Crisp subtle hover
        : Colors.transparent;

    final textColor = isSelected
        ? primaryAccent
        : !isEnabled
        ? AppColors.textMuted
        : AppColors.textPrimary;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isEnabled && !_isHovered) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isEnabled && _isHovered) setState(() => _isHovered = false);
      },
      child: InkWell(
        onTap: isEnabled ? widget.onTap : null,
        hoverColor: Colors.transparent,
        splashColor: primaryAccent.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: bgColor,
          child: Row(
            children: [
              if (widget.item.leading != null) ...[
                widget.item.leading!,
                const SizedBox(width: AppSpacing.sm),
              ] else if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 18,
                  color: isSelected
                      ? primaryAccent
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: widget.textStyle.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: primaryAccent,
                )
              else if (widget.item.trailing != null)
                widget.item.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact, theme-tokenized Dropdown component ideal for table toolbars,
/// filter bars, and header action controls.
class AppDropdownFilter<T> extends StatefulWidget {
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
  State<AppDropdownFilter<T>> createState() => _AppDropdownFilterState<T>();
}

class _AppDropdownFilterState<T> extends State<AppDropdownFilter<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late final AnimationController _animationController;
  late final Animation<double> _chevronAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _chevronAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _closeDropdown(animated: false);
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox? ??
        context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final minWidth = size.width < 140 ? 140.0 : size.width;
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(8);
    final effectiveTextStyle =
        widget.textStyle ??
        AppTypography.bodyMedium.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
              ),
            ),
            Positioned(
              width: minWidth,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 1),
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: effectiveRadius,
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF10194F,
                            ).withValues(alpha: 0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: effectiveRadius,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: widget.items.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.borderSubtle.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            final isSelected = item == widget.value;
                            final label = widget.itemLabel != null
                                ? widget.itemLabel!(item)
                                : item.toString();

                            return InkWell(
                              onTap: () {
                                _closeDropdown();
                                widget.onChanged?.call(item);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                color: isSelected
                                    ? const Color(0xFFECFDF5)
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: effectiveTextStyle.copyWith(
                                          color: isSelected
                                              ? const Color(0xFF00B96B)
                                              : AppColors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Color(0xFF00B96B),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward(from: 0.0);
  }

  void _closeDropdown({bool animated = true}) {
    if (!_isOpen) return;

    if (animated) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        if (mounted) setState(() => _isOpen = false);
      });
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(8);
    final effectiveBgColor = widget.backgroundColor ?? AppColors.surfaceSubtle;
    final effectiveBorderColor = _isOpen
        ? AppColors.brandPrimary
        : (widget.borderColor ?? AppColors.borderSubtle);
    final effectiveTextStyle =
        widget.textStyle ??
        AppTypography.bodyMedium.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
    final effectiveHintStyle =
        widget.hintStyle ??
        AppTypography.bodyMedium.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        );

    final displayLabel = widget.value != null
        ? (widget.itemLabel != null
              ? widget.itemLabel!(widget.value as T)
              : widget.value.toString())
        : widget.hint;

    return CompositedTransformTarget(
      key: _fieldKey,
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: widget.height,
            padding:
                widget.padding ?? const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: effectiveBgColor,
              borderRadius: effectiveRadius,
              border: Border.all(
                color: effectiveBorderColor,
                width: _isOpen ? 1.3 : 1.0,
              ),
              boxShadow: _isOpen
                  ? [
                      BoxShadow(
                        color: AppColors.brandPrimary.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  const SizedBox(width: 6),
                ],
                Text(
                  displayLabel ?? '',
                  style: widget.value != null
                      ? effectiveTextStyle
                      : effectiveHintStyle,
                ),
                const SizedBox(width: 4),
                RotationTransition(
                  turns: _chevronAnimation,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
