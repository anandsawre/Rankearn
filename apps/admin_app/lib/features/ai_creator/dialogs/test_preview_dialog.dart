import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
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
  bool _isLoadingQuestions = false;
  bool _isPushingToBattle = false;
  bool _isPublishing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.test.questions);
    if (_questions.isEmpty) {
      _loadQuestionsFromSupabase();
    }
  }

  Future<void> _loadQuestionsFromSupabase() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    setState(() => _isLoadingQuestions = true);
    try {
      final rows = await client
          .from('ai_test_questions')
          .select()
          .eq('test_id', widget.test.id)
          .order('question_number', ascending: true);

      if (mounted) {
        setState(() {
          _questions = (rows as List)
              .map((r) => AiTestQuestion.fromJson(Map<String, dynamic>.from(r as Map)))
              .toList();
          _isLoadingQuestions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingQuestions = false);
    }
  }

  Future<void> _pushToBattlePool() async {
    setState(() {
      _isPushingToBattle = true;
      _errorMessage = null;
    });

    try {
      final count = await AiCreatorService().pushToBattlePool(
        questions: _questions,
        subjectName: widget.test.displaySubject,
      );
      if (!mounted) return;
      setState(() => _isPushingToBattle = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pushed $count questions to the Live Battle Pool!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPushingToBattle = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _publishTest() async {
    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });

    try {
      final updatedTest = widget.test.copyWith(
        questions: _questions,
        status: AiTestStatus.published,
      );
      await AiCreatorService().publishTestToApp(testItem: updatedTest);
      if (!mounted) return;
      setState(() => _isPublishing = false);
      Navigator.of(context).pop();
      widget.onPublish(updatedTest);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test "${widget.test.title}" published to Supabase!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPublishing = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      iconData: widget.test.icon,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF7C3AED)],
      title: widget.test.title,
      subtitle:
          '${widget.test.displaySubject} • ${_questions.isNotEmpty ? _questions.length : widget.test.questionCount} Questions • ${widget.test.durationMinutes} min • ${widget.test.difficulty.label}',
      maxWidth: 740,
      maxHeight: 680,
      footerLeft: OutlinedButton.icon(
        onPressed: _isPushingToBattle || _questions.isEmpty ? null : _pushToBattlePool,
        icon: _isPushingToBattle
            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF59E0B)),
        label: Text(
          _isPushingToBattle ? 'Pushing...' : 'Push to Battle Pool',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFDE68A)),
          backgroundColor: const Color(0xFFFFFBEB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onExport,
          child: const Text('Export Paper'),
        ),
        const SizedBox(width: 8),
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
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
              ),
            ),
          ],
          Expanded(
            child: _isLoadingQuestions
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                    ? const Center(
                        child: Text(
                          'No questions stored in `ai_test_questions` for this test.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _questions.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
                        itemBuilder: (ctx, idx) => _buildQuestionItem(_questions[idx], idx),
                      ),
          ),
        ],
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
                        color: isCorrect ? const Color(0xFF047857) : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF10B981)),
                ],
              ),
            );
          }),
          if (q.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF5636F5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      q.explanation,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
