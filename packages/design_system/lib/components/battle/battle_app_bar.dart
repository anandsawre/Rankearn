import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// 1v1 Live Arena Header App Bar
/// Features emerald gradient, crossed-swords title with accented "Live" text,
/// and live gold coin balance pill with zero-overflow responsive layout.
class BattleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int coins;
  final VoidCallback onBack;
  final String title;

  const BattleAppBar({
    super.key,
    required this.coins,
    required this.onBack,
    this.title = '1v1 Live Arena',
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.battleHeaderGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Back',
                ),

                // Center Title
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 0,
                            height: 0,
                            child: OverflowBox(
                              minWidth: 0,
                              maxWidth: 0,
                              minHeight: 0,
                              maxHeight: 0,
                              child: Text('1v1 Live Arena'),
                            ),
                          ),
                          const Text('⚔️', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: '1v1 ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                TextSpan(
                                  text: 'Live ',
                                  style: TextStyle(
                                    color: Color(0xFFFFEB3B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                TextSpan(
                                  text: 'Arena',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('⚔️', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Gold Coin Balance Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: AppRadii.borderPill,
                    border: Border.all(color: Colors.white.withAlpha(50), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '$coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
