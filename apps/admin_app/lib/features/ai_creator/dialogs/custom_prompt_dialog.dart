import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CustomPromptDialog extends StatefulWidget {
  final VoidCallback onOpenGenerate;

  const CustomPromptDialog({
    super.key,
    required this.onOpenGenerate,
  });

  @override
  State<CustomPromptDialog> createState() => _CustomPromptDialogState();
}

class _CustomPromptDialogState extends State<CustomPromptDialog> {
  late final TextEditingController _systemPromptController;
  late final TextEditingController _antiHallucinationController;
  double _temperature = 0.4;
  String _bloomsLevel = 'Application & Analytical (Standard)';

  static const List<String> _bloomsLevels = [
    'Knowledge & Recall (Direct)',
    'Understanding & Conceptual',
    'Application & Analytical (Standard)',
    'Critical Evaluation & Assertion-Reason',
  ];

  @override
  void initState() {
    super.initState();
    _systemPromptController = TextEditingController(
      text: 'You are an expert Indian Competitive Examination paper setter specializing in Railway RRB, SSC, and State PSC test series. Synthesize high-quality multiple choice questions strictly based on the prescribed syllabus with 4 distinct plausible options and detailed bilingual solutions.',
    );
    _antiHallucinationController = TextEditingController(
      text: 'Rule 1: Always verify numerical facts against NCERT textbooks.\nRule 2: Never produce ambiguous or disputed questions.\nRule 3: Ensure 3 plausible distractor options per question.',
    );
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    _antiHallucinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2587F8).withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.edit_note_rounded, color: Color(0xFF2587F8), size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Custom Prompt & Model Config',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                                ),
                                Text(
                                  'Configure Gemini system prompt, temperature & cognitive depth',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.borderSubtle),

                // System Instruction Prompt
                const Text('AI System Prompt (Role Definition)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                TextField(
                  controller: _systemPromptController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),

                // Temperature Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Model Temperature (Creativity vs Determinism)',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_temperature.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5636F5))),
                  ],
                ),
                Slider(
                  value: _temperature,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  activeColor: const Color(0xFF5636F5),
                  onChanged: (val) => setState(() => _temperature = val),
                ),
                const SizedBox(height: 10),

                // Cognitive Depth
                const Text("Bloom's Taxonomy Cognitive Level", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _bloomsLevel,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: _bloomsLevels.map((l) {
                    return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _bloomsLevel = val);
                  },
                ),
                const SizedBox(height: 14),

                // Anti-hallucination Rules
                const Text('Anti-Hallucination & Quality Rules', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                TextField(
                  controller: _antiHallucinationController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 18),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Custom AI prompt configuration saved successfully'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5636F5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Save Configuration'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
