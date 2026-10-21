import 'package:flutter/material.dart';

/// Data model for a single quick action item.
class QuickActionItemData {
  /// Label text displayed below the icon (supports \n for line breaks).
  final String label;

  /// Icon displayed inside the colored square.
  final IconData icon;

  /// Solid background color of the icon container (icon itself is white).
  final Color iconColor;

  /// Pastel background color of the action card.
  final Color cardColor;

  /// Callback when the action is tapped.
  final VoidCallback onTap;

  const QuickActionItemData({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.cardColor,
    required this.onTap,
  });
}

/// A reusable Quick Actions card component.
///
/// Displays a header with a ⚡ icon, "Quick Actions" title, and an optional
/// "Customize" button, followed by a row of action tiles. Each tile has a
/// pastel card background with a solid-colored icon square (white icon).
///
/// Usage:
/// ```dart
/// QuickActionsCard(
///   actions: [
///     QuickActionItemData(
///       label: 'Add\nQuestion',
///       icon: Icons.add_circle_outline_rounded,
///       iconColor: Color(0xFF5636F5),
///       cardColor: Color(0xFFF5F3FF),
///       onTap: () => {},
///     ),
///     // ...
///   ],
///   onCustomize: () => {},
/// )
/// ```
class QuickActionsCard extends StatelessWidget {
  /// List of quick action items to display.
  final List<QuickActionItemData> actions;

  /// Optional callback for the "Customize" button. If null, button is still
  /// shown but does nothing.
  final VoidCallback? onCustomize;

  /// Screen width threshold below which actions scroll horizontally.
  final double smallBreakpoint;

  /// Explicit height for the card (e.g. 124 to match adjacent hero cards).
  final double? height;

  /// Whether to render in compact mode (optimized for ~124px height matching hero banners).
  final bool compact;

  const QuickActionsCard({
    super.key,
    required this.actions,
    this.onCustomize,
    this.smallBreakpoint = 480,
    this.height,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = compact || (height != null && height! <= 140);

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFF), Color(0xFFF1F5FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: isCompact
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: isCompact ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: isCompact ? 20 : 24,
                    height: isCompact ? 20 : 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(isCompact ? 5 : 7),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: isCompact ? 13 : 16,
                    ),
                  ),
                  SizedBox(width: isCompact ? 6 : 8),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: isCompact ? 13 : 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101A3A),
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: onCustomize,
                child: Container(
                  padding: isCompact
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5)
                      : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: isCompact ? 12 : 13,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Customize',
                        style: TextStyle(
                          fontSize: isCompact ? 11 : 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isCompact) const SizedBox(height: 14),
          if (isCompact) const SizedBox(height: 6),

          // ── Action Tiles ──
          Builder(
            builder: (context) {
              final isSmall = MediaQuery.sizeOf(context).width < smallBreakpoint;

              final tiles = actions
                  .map((a) => _QuickActionTile(data: a, compact: isCompact))
                  .toList();

              if (isSmall) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tiles
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SizedBox(width: isCompact ? 72 : 80, child: t),
                            ))
                        .toList(),
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: tiles
                    .map((t) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isCompact ? 2.5 : 4),
                            child: t,
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Single Action Tile
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionTile extends StatefulWidget {
  final QuickActionItemData data;
  final bool compact;

  const _QuickActionTile({required this.data, this.compact = false});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final compact = widget.compact;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: d.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: compact
              ? const EdgeInsets.symmetric(vertical: 4, horizontal: 2)
              : const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: _hovering ? d.cardColor : d.cardColor.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
            border: Border.all(
              color: _hovering
                  ? d.iconColor.withValues(alpha: 0.25)
                  : d.cardColor.withValues(alpha: 0.7),
              width: 1.1,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: d.iconColor.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Solid icon square with white icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: compact ? 32 : 44,
                height: compact ? 32 : 44,
                decoration: BoxDecoration(
                  color: d.iconColor,
                  borderRadius: BorderRadius.circular(compact ? 9 : 12),
                  boxShadow: [
                    BoxShadow(
                      color: d.iconColor.withValues(alpha: _hovering ? 0.35 : 0.20),
                      blurRadius: _hovering ? 8 : 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  d.icon,
                  color: Colors.white,
                  size: compact ? 17 : 22,
                ),
              ),
              SizedBox(height: compact ? 3 : 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  d.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 9.5 : 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                    height: compact ? 1.12 : 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
