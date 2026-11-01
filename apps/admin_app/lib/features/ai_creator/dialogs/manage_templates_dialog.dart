import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';

class ManageTemplatesDialog extends StatelessWidget {
  final ValueChanged<AiTestTemplate> onUseTemplate;

  const ManageTemplatesDialog({
    super.key,
    required this.onUseTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      iconData: Icons.folder_special_rounded,
      gradientColors: const [Color(0xFF047857), Color(0xFF10B981)],
      title: 'Manage Test Templates',
      subtitle: 'Rapid 1-click test generation blueprints for competitive exams',
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
        children: kPrebuiltTemplates.map((tpl) => _buildTemplateCard(context, tpl)).toList(),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, AiTestTemplate tpl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tpl.color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(tpl.icon, color: tpl.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tpl.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                ),
                Text(
                  '${tpl.targetExam} • ${tpl.defaultQuestionCount} Qs • ${tpl.defaultDurationMinutes} min • ${tpl.defaultDifficulty.label}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUseTemplate(tpl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Use Template', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
