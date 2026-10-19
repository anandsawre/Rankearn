import 'package:flutter/material.dart';

/// Rankearn Visual Design System - Motion Curves & Durations
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticOut;
}
