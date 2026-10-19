import 'package:flutter/material.dart';

/// Rankearn Visual Design System - Corner Radii Tokens
class AppRadii {
  AppRadii._();

  static const double sm = 8.0;
  static const double md = 12.0;    // rounded-xl
  static const double lg = 16.0;    // rounded-2xl
  static const double xl = 24.0;    // rounded-3xl
  static const double full = 999.0; // rounded-full

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(full));
}
