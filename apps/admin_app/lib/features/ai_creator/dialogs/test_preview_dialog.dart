import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';
import '../services/ai_creator_service.dart';

class TestPreviewDialog extends StatefulWidget {
  final AiGeneratedTestItem test;
  final ValueChanged<AiGeneratedTestItem> onPublish;
  final VoidCallback onExport;

  const TestPreviewDialog({
    super.key,
    required this.test,
    required this.onPublish,
    required this.onExport,
  });

  @override
  State<TestPreviewDialog> createState() => _TestPreviewDialogState();
}

class _TestPreviewDialogState extends State<TestPreviewDialog> {
  late List<AiTestQuestion> _questions;
  bool _isPushingToBattle = false;
  bool _isPublishing = false;

  Future<void> _pushToBattlePool() async {
    setState(() => _isPushingToBattle = true);
    final count = await AiCreatorService().pushToBattlePool(
      questions: _questions,
      subjectName: widget.test.subject.label,
    );
    if (!mounted) return;
    setState(() => _isPushingToBattle = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Successfully pushed $count questions to the Live Battle Pool!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Future<void> _publishTest() async {
    setState(() => _isPublishing = true);
    final updatedTest = widget.test.copyWith(questions: _questions);
    await AiCreatorService().publishTestToApp(testItem: updatedTest);
    if (!mounted) return;
    setState(() => _isPublishing = false);
    Navigator.of(context).pop();
    widget.onPublish(updatedTest);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test "${widget.test.title}" published successfully to student mobile app!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.test.questions);
    if (_questions.isEmpty) {
      _questions = [
        AiTestQuestion(
          id: 'q_preview_1',
          questionNumber: 1,
          questionText: 'Which law of thermodynamics states that the entropy of an isolated system always increases over time?',
          questionTextHi: 'ऊष्मागतिकी का कौन सा नियम कहता है कि एक पृथक प्रणाली की एन्ट्रापी हमेशा समय के साथ बढ़ती है?',
          options: [
            'Zeroth Law of Thermodynamics',
            'First Law of Thermodynamics',
            'Second Law of Thermodynamics (द्वितीय नियम)',
            'Third Law of Thermodynamics',
          ],
          correctOptionIndex: 2,
          explanation: 'The Second Law of Thermodynamics establishes that the total entropy of an isolated system can never decrease over time.',
          subject: widget.test.subject.label,
          difficulty: widget.test.difficulty.label,
        ),
        AiTestQuestion(
          id: 'q_preview_2',
          questionNumber: 2,
          questionText: 'What is the escape velocity from the surface of the Earth approximately?',
          questionTextHi: 'पृथ्वी की सतह से पलायन वेग लगभग कितना है?',
          options: [
            '9.8 km/s',
            '11.2 km/s',
            '14.5 km/s',
            '25.0 km/s',
          ],
          correctOptionIndex: 1,
          explanation: 'The escape velocity from the Earth surface is approximately 11.2 km/s (or ~40,270 km/h), derived from v_e = sqrt(2GM/R).',
          subject: widget.test.subject.label,
          difficulty: widget.test.difficulty.label,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      iconData: widget.test.icon,
      gradientColors: const [Color(0xFF1E1B4B), Color(0xFF4338CA)],
      title: widget.test.title,
      subtitle:
          '${widget.test.subject.label} • ${widget.test.difficulty.label} • ${widget.test.questionCount} Questions • ${widget.test.durationMinutes} min',
      maxWidth: 740,
      footerLeft: Text(
        '${_questions.length} questions ready for publishing',
        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: widget.onExport,
          icon: const Icon(Icons.ios_share_rounded, size: 15),
          label: const Text('Export'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5636F5),
            side: const BorderSide(color: Color(0xFFC7D2FE)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isPushingToBattle ? null : _pushToBattlePool,
          icon: _isPushingToBattle
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.bolt_rounded, size: 16),
          label: Text(_isPushingToBattle ? 'Pushing...' : 'Push to Battle Pool'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isPublishing ? null : _publishTest,
          icon: _isPublishing
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.publish_rounded, size: 16),
          label: Text(_isPublishing ? 'Publishing...' : 'Publish Test'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
      child: ListView.separated(
        itemCount: _questions.length,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
        itemBuilder: (ctx, idx) => _buildQuestionItem(_questions[idx], idx),
      ),
    );
  }

  Widget _buildQuestionItem(AiTestQuestion q, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text & header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5).withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF5636F5)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.questionText,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                    ),
                    if (q.questionTextHi != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        q.questionTextHi!,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Options Grid
          ...List.generate(q.options.length, (optIdx) {
            final isCorrect = optIdx == q.correctOptionIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCorrect ? const Color(0xFFECFDF5) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                  width: isCorrect ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + optIdx),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      q.options[optIdx],
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                        color: isCorrect ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (isCorrect) ...[
                    const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                  ],
                ],
              ),
            );
          }),

          // Solution / Explanation
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFF5636F5)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Solution: ${q.explanation}',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF3730A3), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
