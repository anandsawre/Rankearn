import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

enum AnswerTileState {
  defaultState,
  selected,
  submitted,
  correct,
  incorrect,
  disabled,
}

/// 1v1 Battle Answer Option Tile
/// Features letter badge (A/B/C/D), option text, and circular radio indicator.
class AnswerOptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final AnswerTileState state;
  final VoidCallback? onTap;

  const AnswerOptionTile({
    super.key,
    required this.letter,
    required this.text,
    this.state = AnswerTileState.defaultState,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = state == AnswerTileState.selected || state == AnswerTileState.submitted;
    final isCorrect = state == AnswerTileState.correct;
    final isIncorrect = state == AnswerTileState.incorrect;
    final isDisabled = state == AnswerTileState.disabled;

    Color bgColor = Colors.white;
    Color borderColor = AppColors.battleBorder;
    Color letterBg = const Color(0xFFEFF6FF);
    Color letterColor = AppColors.battleNavy;
    double borderWidth = 1.2;

    if (isSelected) {
      bgColor = const Color(0xFFE8FBF2);
      borderColor = const Color(0xFF00B96B);
      borderWidth = 2.0;
      letterBg = const Color(0xFF00B96B);
      letterColor = Colors.white;
    } else if (isCorrect) {
      bgColor = const Color(0xFFD1FAE5);
      borderColor = const Color(0xFF10B981);
      borderWidth = 2.0;
      letterBg = const Color(0xFF10B981);
      letterColor = Colors.white;
    } else if (isIncorrect) {
      bgColor = const Color(0xFFFFE4E6);
      borderColor = const Color(0xFFEF4444);
      borderWidth = 2.0;
      letterBg = const Color(0xFFEF4444);
      letterColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: AppRadii.borderLg,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 60.0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF00B96B).withAlpha(30)
                      : const Color(0x0A000000),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Left Circular Letter Badge (A, B, C, D)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: letterBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: letterColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Answer Text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF008C52) : AppColors.battleNavy,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 3. Right Circular Radio Indicator
                _buildRadioIndicator(isSelected, isCorrect, isIncorrect),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected, bool isCorrect, bool isIncorrect) {
    if (isCorrect) {
      return const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24);
    }
    if (isIncorrect) {
      return const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 24);
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF00B96B) : const Color(0xFFCBD5E1),
          width: isSelected ? 2.5 : 2.0,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Color(0xFF00B96B),
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
