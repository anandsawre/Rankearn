import 'package:flutter/material.dart';
import 'colors.dart';

/// Rankearn Visual Design System - Typography Tokens
/// Grounded strictly in the Rankearn Home Dashboard reference specifications.
class AppTypography {
  AppTypography._();

  static const List<String> fontFallbacks = [
    'Inter',
    'Roboto',
    'Noto Sans Devanagari',
    'sans-serif',
  ];

  // --- Display & Hero ---
  static const TextStyle displayHero = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  // --- Headings ---
  static const TextStyle pageHeading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle cardHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFallbacks,
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
}
