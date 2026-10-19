import 'package:flutter/material.dart';

/// Rankearn Visual Design System - Elevation & Shadows
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> emeraldGlow = [
    BoxShadow(
      color: Color(0x4010B981), // 25% emerald
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
