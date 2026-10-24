import 'package:flutter/material.dart';

/// Rankearn Visual Design System - Centralized Brand Color Palette
/// Grounded strictly in the Rankearn Home Dashboard reference specifications.
class AppColors {
  AppColors._();

  // --- Brand Purple Tokens (Primary Navigation & Accents) ---
  static const Color brandPurple = Color(0xFF5636F5);
  static const Color brandPurpleDark = Color(0xFF3920C9);
  static const Color brandPurpleLight = Color(0xFFEEE9FF);

  // --- Brand Green / Emerald Tokens (Earnings & Success) ---
  static const Color brandGreen = Color(0xFF10B981);
  static const Color brandGreenDark = Color(0xFF07884F);
  static const Color brandGreenLight = Color(0xFFECFDF5);
  static const Color brandGreenMuted = Color(0xFFA7F3D0);

  // --- Brand Yellow / Gold Tokens (Coins, Rewards, Trophies) ---
  static const Color brandYellow = Color(0xFFFFD633);
  static const Color brandYellowLight = Color(0xFFFFF9DB);
  static const Color coinGold = Color(0xFFFFB800);
  static const Color coinGoldLight = Color(0xFFFEF3C7);
  static const Color coinBadgeBackground = Color(0xFFFFF6D8);

  // --- Brand Blue & Sky Tokens (Informational & Tests) ---
  static const Color brandBlue = Color(0xFF2587F8);
  static const Color brandBlueDark = Color(0xFF1B6BD8);
  static const Color brandBlueLight = Color(0xFFEFF6FF);

  // --- Brand Pink & Magenta Tokens ---
  static const Color brandPink = Color(0xFFF04483);
  static const Color brandPinkDark = Color(0xFFD8286A);
  static const Color brandPinkLight = Color(0xFFFDF2F8);

  // --- Brand Orange & Amber Tokens ---
  static const Color brandOrange = Color(0xFFFF9F0A);
  static const Color brandOrangeLight = Color(0xFFFFF7ED);

  // --- Brand Red & Live Contest Tokens ---
  static const Color liveRed = Color(0xFFE5252A);
  static const Color liveRedDark = Color(0xFFC91E23);
  static const Color liveRedLight = Color(0xFFFFF1F2);
  static const Color liveRedBorder = Color(0xFFFFE4E6);
  static const Color liveRedSubtle = Color(0xFFFEE2E2);

  // --- Backward Compatibility & Standard Aliases ---
  static const Color brandPrimary = brandGreen;
  static const Color brandPrimaryHover = brandGreenDark;
  static const Color brandPrimaryDark = brandGreenDark;
  static const Color brandPrimaryLight = brandGreenLight;
  static const Color brandPrimaryMuted = brandGreenMuted;
  static const Color primary = brandPurple;
  static const Color primaryHover = brandPurpleDark;
  static const Color primaryDark = brandPurpleDark;
  static const Color primaryLight = brandPurpleLight;
  static const Color primarySubtle = brandPurpleLight;
  static const Color canvasDark = surfaceSubtle;

  // --- Canvas & Surfaces ---
  static const Color background = Color(
    0xFFF4F7FF,
  ); // Crisp pale blue/lavender canvas
  static const Color surface = Color(0xFFFFFFFF); // Primary card surface
  static const Color surfaceSubtle = Color(
    0xFFF8FAFF,
  ); // Soft secondary surface
  static const Color surfaceMuted = Color(0xFFEEF2F9);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceDarkCard = Color(0xFF1E293B);

  // --- Typography & Neutral Text ---
  static const Color textPrimary = Color(0xFF101A3A); // Deep navy
  static const Color textSecondary = Color(0xFF536789); // Muted slate
  static const Color textMuted = Color(0xFF8290AA); // Subtle text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on brand colors

  // --- Borders & Dividers ---
  static const Color border = Color(0xFFE3EAF7);
  static const Color borderSubtle = Color(0xFFE9EEF8);
  static const Color borderStrong = Color(0xFFCBD5E1);
  static const Color borderFocus = brandPurple;

  // --- Semantic & Status Colors ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorRose = Color(0xFFF43F5E);
  static const Color errorRoseLight = Color(0xFFFFF1F2);
  static const Color info = Color(0xFF2587F8);
  static const Color infoBlue = Color(0xFF2587F8);
  static const Color infoBlueLight = Color(0xFFEFF6FF);
  static const Color infoBlueBorder = Color(0xFFDBEAFE);
  static const Color disabled = Color(0xFFCBD5E1);

  // --- Gradients ---
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF2A1594), Color(0xFF4C27D5), Color(0xFF673BF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dailyChallengeGradient = LinearGradient(
    colors: [Color(0xFF421E9C), Color(0xFF5D2DC2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient fortuneWheelGradient = LinearGradient(
    colors: [Color(0xFF0A6352), Color(0xFF108770)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandPurpleDark, brandPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD633), Color(0xFFFFB800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0C1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- 1v1 Quiz Battle Arena Tokens ---
  static const Color battleGreen = Color(0xFF00B96B);
  static const Color battleGreenDark = Color(0xFF008C52);
  static const Color battleMintBg = Color(0xFFE3FFF2);
  static const Color battlePageBg = Color(0xFFF2F8FF);
  static const Color battleNavy = Color(0xFF10194F);
  static const Color battleGold = Color(0xFFFFC928);
  static const Color battleGoldDark = Color(0xFFE6A700);
  static const Color battleErrorRed = Color(0xFFFF385C);
  static const Color battlePurple = Color(0xFF702FFF);
  static const Color battleSecondaryText = Color(0xFF637394);
  static const Color battleBorder = Color(0xFFDFE9FA);
  static const Color battleCardBg = Color(0xFFFFFFFF);

  static const LinearGradient battleHeaderGradient = LinearGradient(
    colors: [Color(0xFF00B96B), Color(0xFF008C52)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient battleVictoryGradient = LinearGradient(
    colors: [Color(0xFF00D277), Color(0xFF009C59), Color(0xFF00683B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Leaderboard Design System Tokens ---
  static const Color leaderboardBg = Color(0xFFF2F8FF);
  static const Color leaderboardGreen = Color(0xFF00B96B);
  static const Color leaderboardGreenDark = Color(0xFF008C52);
  static const Color leaderboardMintBg = Color(0xFFE8FDF5);
  static const Color leaderboardNavy = Color(0xFF10194F);
  static const Color leaderboardGold = Color(0xFFFFD32A);
  static const Color leaderboardGoldDark = Color(0xFFB45309);
  static const Color leaderboardSilver = Color(0xFF94A3B8);
  static const Color leaderboardBronze = Color(0xFFD97706);
  static const Color leaderboardBorder = Color(0xFFE2ECFA);
  static const Color leaderboardMuted = Color(0xFF64748B);
  static const Color leaderboardSubtle = Color(0xFF586B9B);
  static const Color leaderboardRibbonRed = Color(0xFFDC2626);

  // Surface & Slate Grays
  static const Color leaderboardDarkSlate = Color(0xFF0F172A);
  static const Color leaderboardSlate800 = Color(0xFF1E293B);
  static const Color leaderboardSlate700 = Color(0xFF334155);
  static const Color leaderboardSlate300 = Color(0xFFCBD5E1);
  static const Color leaderboardSlate200 = Color(0xFFE2E8F0);
  static const Color leaderboardSlate100 = Color(0xFFF1F5F9);
  static const Color leaderboardSlate50 = Color(0xFFF8FAFC);

  // Semantic & Accents for Leaderboard
  static const Color leaderboardAmber500 = Color(0xFFF59E0B);
  static const Color leaderboardAmber100 = Color(0xFFFEF3C7);
  static const Color leaderboardAmber50 = Color(0xFFFFFBEB);
  static const Color leaderboardOrange100 = Color(0xFFFFEDD5);
  static const Color leaderboardOrange300 = Color(0xFFFDBA74);
  static const Color leaderboardOrange900 = Color(0xFF78350F);
  static const Color leaderboardSky600 = Color(0xFF0284C7);
  static const Color leaderboardSky100 = Color(0xFFE0F2FE);
  static const Color leaderboardBlue600 = Color(0xFF2563EB);
  static const Color leaderboardBlue100 = Color(0xFFDBEAFE);
  static const Color leaderboardGreen100 = Color(0xFFD1FAE5);
  static const Color leaderboardRed100 = Color(0xFFFEE2E2);
  static const Color leaderboardPurple100 = Color(0xFFEDE9FE);
  static const Color leaderboardPink100 = Color(0xFFFCE7F3);
  static const Color leaderboardIndigo100 = Color(0xFFE0E7FF);

  // Avatar Pastel Palette
  static const Color avatarPastelBlue = Color(0xFFDCEBFE);
  static const Color avatarPastelRed = Color(0xFFFEE2E2);
  static const Color avatarPastelPurple = Color(0xFFEDE9FE);
  static const Color avatarPastelGreen = Color(0xFFD1FAE5);
  static const Color avatarPastelPink = Color(0xFFFCE7F3);
  static const Color avatarPastelIndigo = Color(0xFFE0E7FF);
  static const Color avatarPastelYellow = Color(0xFFFEF3C7);
  static const Color avatarPastelOrange = Color(0xFFFFEDD5);
  static const Color avatarPastelSky = Color(0xFFE0F2FE);

  static const LinearGradient leaderboardHeroGradient = LinearGradient(
    colors: [Color(0xFF00B96B), Color(0xFF008C52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient leaderboardPodiumGold = LinearGradient(
    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient leaderboardPodiumSilver = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient leaderboardPodiumBronze = LinearGradient(
    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient leaderboardStepGold = LinearGradient(
    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient leaderboardStepSilver = LinearGradient(
    colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient leaderboardStepBronze = LinearGradient(
    colors: [Color(0xFFFFEDD5), Color(0xFFFDBA74)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Wallet Design System Tokens ---
  static const Color walletPrimaryGreen = Color(0xFF00B96B);
  static const Color walletDarkGreen = Color(0xFF008C52);
  static const Color walletNavy = Color(0xFF10194F);
  static const Color walletBackground = Color(0xFFF2F8FF);
  static const Color walletCardBg = Color(0xFFFFFFFF);
  static const Color walletGold = Color(0xFFFFC928);
  static const Color walletGoldDark = Color(0xFFE6A700);
  static const Color walletSecondaryText = Color(0xFF586B9B);
  static const Color walletBorder = Color(0xFFE2ECFA);
  static const Color walletBorderSubtle = Color(0xFFEDF4FD);
  static const Color walletErrorRed = Color(0xFFF52245);
  static const Color walletMintBg = Color(0xFFE8FDF2);
  static const Color walletMintBorder = Color(0xFFC6F0DC);
  static const Color walletPurple = Color(0xFF8B5CF6);
  static const Color walletPurpleBg = Color(0xFFF5F3FF);

  static const LinearGradient walletHeroGradient = LinearGradient(
    colors: [Color(0xFFE8FDF2), Color(0xFFD6F8E7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
