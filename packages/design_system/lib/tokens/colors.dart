import 'package:flutter/material.dart';

/// Rankearn Visual Design System - Brand Color Palette
/// Grounded strictly in existing React UI tokens (Emerald #10b981, Canvas #F8FAF9).
class AppColors {
  AppColors._();

  // --- Brand Emerald Scale ---
  static const Color brandPrimary = Color(0xFF10B981);       // Emerald 500
  static const Color brandPrimaryHover = Color(0xFF059669);  // Emerald 600
  static const Color brandPrimaryDark = Color(0xFF047857);   // Emerald 700
  static const Color brandPrimaryLight = Color(0xFFECFDF5);  // Emerald 50
  static const Color brandPrimaryMuted = Color(0xFFA7F3D0);  // Emerald 200

  // Standard Aliases
  static const Color primary = brandPrimary;
  static const Color primaryHover = brandPrimaryHover;
  static const Color primaryDark = brandPrimaryDark;
  static const Color primaryLight = brandPrimaryLight;
  static const Color primarySubtle = brandPrimaryLight;
  static const Color canvasDark = surfaceSubtle;

  // --- Canvas & Surfaces ---
  static const Color background = Color(0xFFF8FAF9);         // Canvas background
  static const Color surface = Color(0xFFFFFFFF);            // Primary card white
  static const Color surfaceSubtle = Color(0xFFF1F5F9);      // Slate 100
  static const Color surfaceDark = Color(0xFF0F172A);        // Slate 900
  static const Color surfaceDarkCard = Color(0xFF1E293B);    // Slate 800

  // --- Typography & Text ---
  static const Color textPrimary = Color(0xFF0F172A);        // Slate 900
  static const Color textSecondary = Color(0xFF475569);      // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);          // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);      // White on Brand

  // --- Borders & Dividers ---
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFE2E8F0);       // Slate 200
  static const Color borderStrong = Color(0xFFCBD5E1);       // Slate 300
  static const Color borderFocus = Color(0xFF10B981);        // Emerald 500

  // --- Accent & Semantic Status ---
  static const Color coinGold = Color(0xFFF59E0B);           // Amber 500
  static const Color coinGoldLight = Color(0xFFFEF3C7);      // Amber 100
  static const Color errorRose = Color(0xFFF43F5E);          // Rose 500
  static const Color errorRoseLight = Color(0xFFFFF1F2);     // Rose 50
  static const Color infoBlue = Color(0xFF3B82F6);           // Blue 500
  static const Color infoBlueLight = Color(0xFFEFF6FF);      // Blue 50

  // --- Gradients ---
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0C1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
