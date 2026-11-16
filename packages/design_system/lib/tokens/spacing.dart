import 'package:flutter/widgets.dart';

/// Rankearn Visual Design System - Spacing Scale
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Layout page padding
  // On mobile (<640px), exactly 12.0px margin to match AppModalDialog horizontal width
  static const double pagePaddingMobile = 12.0;
  static const double pagePaddingDesktop = 24.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingMobile = 16.0;
  static const double maxContentWidth = 1200.0;

  /// Responsive horizontal page padding matching modal dialog horizontal width on mobile (12.0px)
  static double horizontalPagePadding(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 640 ? pagePaddingMobile : xxl;
  }

  /// Responsive page padding EdgeInsets matching modal dialog horizontal width on mobile
  static EdgeInsets pagePadding(BuildContext context, {double? top, double? bottom}) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;
    return EdgeInsets.fromLTRB(
      isMobile ? pagePaddingMobile : xxl,
      top ?? (isMobile ? 14.0 : xl),
      isMobile ? pagePaddingMobile : xxl,
      bottom ?? (isMobile ? 18.0 : xl),
    );
  }

  // --- Admin Dashboard Semantic Spacing Tokens ---
  /// The tokenized unified vertical height for admin hero banners across all modules.
  static const double adminHeroHeight = 124.0;

  /// The tokenized unified vertical height for all single-line form text inputs and dropdowns.
  static const double adminControlHeight = 44.0;
  static const double adminControlHeightDense = 38.0;

  static const EdgeInsets adminPagePadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0);
  static const EdgeInsets adminCardPadding = EdgeInsets.all(24.0);
  static const EdgeInsets adminCardPaddingCompact = EdgeInsets.all(22.0);
  static const double adminGapSection = 28.0;
  static const double adminGapCard = 24.0;
  static const double adminGapItem = 18.0;
  static const double adminGapSmall = 12.0;
  static const double adminGridSpacing = 16.0;
}
