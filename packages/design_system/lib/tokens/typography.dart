import 'package:flutter/material.dart';
import 'colors.dart';

/// Rankearn Visual Design System - Typography Tokens
/// Grounded strictly in the Rankearn Home Dashboard reference specifications.
class AppTypography {
  AppTypography._();

  static const String fontHeading = 'Plus Jakarta Sans';
  static const String fontBody = 'Inter';
  static const String fontHindi = 'Noto Sans Devanagari';

  static const List<String> fontFallbacks = [
    'Inter',
    'Noto Sans Devanagari',
    'Roboto',
    'sans-serif',
  ];

  static const List<String> headingFallbacks = [
    'Plus Jakarta Sans',
    'Inter',
    'Noto Sans Devanagari',
    'Roboto',
    'sans-serif',
  ];

  // --- Display & Hero (Plus Jakarta Sans) ---
  static const TextStyle displayHero = TextStyle(
    fontFamily: fontHeading,
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontHeading,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontHeading,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  // --- Headings (Plus Jakarta Sans) ---
  static const TextStyle pageHeading = TextStyle(
    fontFamily: fontHeading,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontHeading,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle cardHeading = TextStyle(
    fontFamily: fontHeading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontHeading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontHeading,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  // --- Body & Supporting ---
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle supporting = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamilyFallback: fontFallbacks,
  );

  // --- Numeric Highlights & Metrics ---
  static const TextStyle numericHighlight = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle metricLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    fontFamilyFallback: fontFallbacks,
  );

  // --- Tags, Badges & Buttons ---
  static const TextStyle microTag = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.8,
    color: AppColors.brandPurple,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    color: AppColors.textOnPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  // --- Form & Input Tokens ---
  static const TextStyle formLabel = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: Color(0xFF94A3B8),
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle formFloatingLabel = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: AppColors.brandPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle formInput = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle formHint = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: Color(0xFF94A3B8),
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle formError = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
    fontFamilyFallback: fontFallbacks,
  );

  // --- Auth Specialized Typography Tokens ---
  static const TextStyle authHeroHeading = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.6,
    height: 1.14,
    color: AppColors.textPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle authHeroAccent = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.6,
    height: 1.14,
    color: AppColors.brandPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle authMobileHeroHeading = TextStyle(
    fontFamily: fontHeading,
    fontSize: 25,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.15,
    color: Color(0xFF0F172A),
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle authMobileHeroAccent = TextStyle(
    fontFamily: fontHeading,
    fontSize: 25,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.15,
    color: AppColors.brandPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle authMobileHeroHeadingNarrow = TextStyle(
    fontFamily: fontHeading,
    fontSize: 21,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.15,
    color: Color(0xFF0F172A),
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle authMobileHeroAccentNarrow = TextStyle(
    fontFamily: fontHeading,
    fontSize: 21,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.15,
    color: AppColors.brandPrimary,
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle authCardHeading = TextStyle(
    fontFamily: fontHeading,
    fontSize: 19,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.3,
    color: Color(0xFF0F172A),
    fontFamilyFallback: headingFallbacks,
  );

  static const TextStyle authSubtitle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),
    height: 1.25,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authPillBadge = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    color: Color(0xFF008C52),
    letterSpacing: -0.1,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColors.textOnPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authTermsText = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: Color(0xFF475569),
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authTermsLink = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.brandPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authRememberMe = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: Color(0xFF475569),
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authForgotPassword = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.brandPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authModeSwitchPrompt = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authModeSwitchAction = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    color: AppColors.brandPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authDividerText = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: Color(0xFF94A3B8),
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authModalTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authModalBody = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authModalError = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authDropdownValue = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle authDropdownHint = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: Color(0xFF94A3B8),
    fontFamilyFallback: fontFallbacks,
  );
}
