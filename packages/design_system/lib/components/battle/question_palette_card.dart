import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../buttons/app_button.dart';
import 'battle_leave_dialog.dart';

/// Question Palette Card for 1v1 Live Arena Quiz Battle
/// Matches Reference Image 2:
/// - Grid of numbered questions with 3 distinct states: Answered (green), Current (blue outline), Not Answered (grey)
/// - Bottom state legend
/// - "Surrender Battle" action button with confirmation
class QuestionPaletteCard extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final Set<int> answeredIndices;
  final ValueChanged<int>? onQuestionSelected;
  final VoidCallback? onSurrender;
  final int entryFee;

  const QuestionPaletteCard({
    super.key,
    this.totalQuestions = 20,
    required this.currentQuestionIndex,
    this.answeredIndices = const {0, 1, 2},
    this.onQuestionSelected,
    this.onSurrender,
    this.entryFee = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10194F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header Title
          Row(
            children: const [
              Icon(Icons.grid_view_rounded, color: Color(0xFF00B96B), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Question Palette',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.battleNavy,
                    letterSpacing: -0.2,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Numbered Questions Grid (5 columns)
          LayoutBuilder(
            builder: (context, constraints) {
              const columns = 5;
              const spacing = 6.0;
              final itemWidth = ((constraints.maxWidth - (spacing * (columns - 1))) / columns).clamp(28.0, 42.0);
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(totalQuestions, (index) {
                  final isAnswered = answeredIndices.contains(index);
                  final isCurrent = index == currentQuestionIndex;

                  Color bgColor;
                  Color textColor;
                  Border? border;

                  if (isAnswered) {
                    bgColor = const Color(0xFF00B96B);
                    textColor = Colors.white;
                    border = null;
                  } else if (isCurrent) {
                    bgColor = Colors.white;
                    textColor = const Color(0xFF2587F8);
                    border = Border.all(color: const Color(0xFF2587F8), width: 2.0);
                  } else {
                    bgColor = const Color(0xFFF1F5F9);
                    textColor = const Color(0xFF64748B);
                    border = null;
                  }

                  return InkWell(
                    onTap: () => onQuestionSelected?.call(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: itemWidth,
                      height: itemWidth,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: border,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: itemWidth < 34 ? 12 : 13.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),

          // 3. Legend Row
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem(
                dot: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B96B),
                    shape: BoxShape.circle,
                  ),
                ),
                label: 'Answered',
              ),
              _buildLegendItem(
                dot: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2587F8), width: 1.5),
                  ),
                ),
                label: 'Current',
              ),
              _buildLegendItem(
                dot: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                ),
                label: 'Not Answered',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Surrender Battle Button (Standardized with AppButton)
          AppButton(
            label: 'Surrender Battle',
            variant: AppButtonVariant.outlined,
            size: AppButtonSize.medium,
            fullWidth: true,
            foregroundColor: AppColors.errorRose,
            borderColor: AppColors.errorRose,
            leadingIcon: const Icon(
              Icons.flag_rounded,
              color: AppColors.errorRose,
              size: 18,
            ),
            onPressed: () async {
              if (onSurrender != null) {
                onSurrender!();
              } else {
                await BattleLeaveDialog.show(context, entryFee: entryFee);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Widget dot, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.battleSecondaryText,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
