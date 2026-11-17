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

  static const List<BoxShadow> purpleGlow = [
    BoxShadow(
      color: Color(0x335636F5), // 20% purple
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x33FFB800), // 20% gold
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> leaderboardCard = [
    BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // --- Live Poll Semantic Shadow Tokens ---
  static const List<BoxShadow> pollCard = [
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> pollCanvas = [
    BoxShadow(
      color: Color(0x504C1D95),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // --- Admin Dashboard Shadow Tokens ---
  static const List<BoxShadow> adminCard = [
    BoxShadow(
      color: Color(0x0810143A),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> adminPrimaryButton = [
    BoxShadow(
      color: Color(0x407628E8),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> adminHero = [
    BoxShadow(
      color: Color(0x334C16A8),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> adminSubtle = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> adminBanner = [
    BoxShadow(
      color: Color(0x285636F5),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // --- Contest & Tournament Semantic Shadow Tokens ---
  static const List<BoxShadow> contestHero = [
    BoxShadow(
      color: Color(0x286B21A8),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> contestCard = [
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> contestCardMobile = [
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> contestPillActive = [
    BoxShadow(
      color: Color(0x2410B981),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> contestTag = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // --- Bottom Sheet Shadow Tokens ---
  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];
}
