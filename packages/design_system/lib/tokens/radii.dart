import 'package:flutter/material.dart';

/// Rankearn Visual Design System - Corner Radii Tokens
class AppRadii {
  AppRadii._();

  static const double sm = 8.0;
  static const double md = 12.0; // rounded-xl
  static const double lg = 16.0; // rounded-2xl
  static const double xl = 24.0; // rounded-3xl
  static const double full = 999.0; // rounded-full

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(full),
  );

  // --- Directional Radii Tokens ---
  static const BorderRadius borderTopXl = BorderRadius.vertical(top: Radius.circular(xl));
  static const BorderRadius borderBottomXl = BorderRadius.vertical(bottom: Radius.circular(xl));
  static const BorderRadius borderTopLg = BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius borderBottomLg = BorderRadius.vertical(bottom: Radius.circular(lg));

  // --- Semantic Component Radii Tokens ---
  // In Rankearn Admin Design System, cards use 16px (borderLg) matching
  // overview, tests, and users dashboards, buttons use 8-12px, badges use 6px.
  static const BorderRadius card = borderLg;
  static const BorderRadius cardSubtle = borderMd;
  static const BorderRadius button = borderSm;
  static const BorderRadius buttonLg = borderMd;
  static const BorderRadius buttonPill = borderSm;
  static const BorderRadius input = borderMd;
  static const BorderRadius chip = borderSm;
  static const BorderRadius badge = BorderRadius.all(Radius.circular(6.0));
}
