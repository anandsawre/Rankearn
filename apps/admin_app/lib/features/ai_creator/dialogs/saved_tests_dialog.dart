import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';

class SavedTestsDialog extends StatelessWidget {
  final List<AiGeneratedTestItem> tests;
  final ValueChanged<AiGeneratedTestItem> onResumeTest;

  const SavedTestsDialog({
    super.key,
    required this.tests,
    required this.onResumeTest,
  });

  @override
  Widget build(BuildContext context) {
    final savedTests = tests.where((t) => t.status != AiTestStatus.processing).toList();

    return AppModalDialog(
      iconData: Icons.bookmark_outline_rounded,
      iconColor: const Color(0xFFFF9F0A),
      title: 'Saved AI Tests (${savedTests.length})',
      subtitle: 'Inspect, review or resume publishing drafted tests',
      maxWidth: 620,
      scrollable: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (savedTests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No saved AI tests available.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ...savedTests.map((t) => _buildSavedTestTile(context, t)),
        ],
      ),
    );
  }

  Widget _buildSavedTestTile(BuildContext context, AiGeneratedTestItem t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: t.iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(t.icon, color: t.iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${t.subject.label} • ${t.questionCount} Questions • ${t.durationMinutes} min',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: t.status.backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              t.status.label,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.status.color),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF5636F5)),
            tooltip: 'Inspect / Resume',
            onPressed: () {
              Navigator.of(context).pop();
              onResumeTest(t);
            },
          ),
        ],
      ),
    );
  }
}
