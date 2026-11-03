import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';

class ViewQuestionDialog extends StatelessWidget {
  final QuestionItem item;

  const ViewQuestionDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Question #${item.questionNumber}',
      subtitle: '${item.subject} • ${item.testSeriesTitle.replaceAll('\n', ' ')}',
      iconData: item.subjectIcon,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 600,
      maxHeight: 700,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildBadge(item.subject, item.subjectBgColor, item.subjectTextColor),
              _buildBadge(item.difficulty.label, item.difficultyBgColor, item.difficultyTextColor),
              _buildBadge(item.questionType, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
              _buildBadge(item.status.label, item.statusBgColor, item.statusTextColor),
              _buildBadge('+${item.marks} / -${item.negativeMarks} Marks', const Color(0xFFF1F5F9), const Color(0xFF475569)),
              _buildBadge('${_formatNumber(item.usageCount)} Attempts', const Color(0xFFF1F5F9), const Color(0xFF475569)),
            ],
          ),
          const SizedBox(height: 16),

          // Question Text
          const Text(
            'QUESTION',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          Text(
            item.questionText,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101A3A),
              height: 1.35,
            ),
          ),
          if (item.questionTextHindi != null && item.questionTextHindi!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.questionTextHindi!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.3),
            ),
          ],
          const SizedBox(height: 18),

          // Options
          const Text(
            'OPTIONS',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),

          for (int i = 0; i < item.options.length; i++) ...[
            _buildOptionRow(item.options[i], item.correctAnswerIndex == i),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 16),

          // Explanation
          if (item.explanation != null && item.explanation!.isNotEmpty) ...[
            const Text(
              'EXPLANATION & REASONING',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                item.explanation!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionRow(QuestionOptionItem opt, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
          width: isCorrect ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              opt.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isCorrect ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              opt.text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w500,
                color: isCorrect ? const Color(0xFF14532D) : const Color(0xFF1E293B),
              ),
            ),
          ),
          if (isCorrect) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'CORRECT',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor)),
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      final part1 = s.substring(0, len - 3);
      final part2 = s.substring(len - 3);
      return '$part1,$part2';
    }
    return n.toString();
  }
}
