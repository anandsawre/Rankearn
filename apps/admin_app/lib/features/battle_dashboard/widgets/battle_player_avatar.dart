import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Shared player avatar for the battle dashboard.
///
/// Renders user initials on a neutral surface when [avatarUrl] is empty or
/// invalid instead of hitting external placeholder image URLs.
class BattlePlayerAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double radius;

  const BattlePlayerAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.radius = 18,
  });

  bool get _hasValidUrl {
    final trimmed = avatarUrl.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = (radius * 0.72).clamp(9.0, 16.0);

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.brandPurpleLight,
      foregroundImage: _hasValidUrl ? NetworkImage(avatarUrl.trim()) : null,
      onForegroundImageError: _hasValidUrl ? (_, _) {} : null,
      child: Text(
        _initials,
        style: AppTypography.captionBold.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: AppColors.battleAdminPurple,
        ),
      ),
    );
  }
}

