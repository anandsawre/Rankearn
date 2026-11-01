import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../services/ai_creator_service.dart';

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
  late final TextEditingController _apiKeyController;
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
    _temperature = AiCreatorService().temperature;
    _apiKeyController = TextEditingController(text: AiCreatorService().apiKey);
    _systemPromptController = TextEditingController(
      text: AiCreatorService().systemPrompt,
    );
    _antiHallucinationController = TextEditingController(
      text: 'Rule 1: Always verify numerical facts against NCERT textbooks.\nRule 2: Never produce ambiguous or disputed questions.\nRule 3: Ensure 3 plausible distractor options per question.',
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _systemPromptController.dispose();
    _antiHallucinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      iconData: Icons.tune_rounded,
      gradientColors: const [Color(0xFF2587F8), Color(0xFF0D9488)],
      title: 'Custom Prompt & Model Config',
      subtitle: 'Configure Gemini system prompt, temperature & cognitive depth',
      maxWidth: 640,
      scrollable: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            AiCreatorService().setApiKey(_apiKeyController.text.trim());
            AiCreatorService().setSystemPrompt(_systemPromptController.text.trim());
            AiCreatorService().setTemperature(_temperature);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AI configuration & API Key saved successfully to AI Engine'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Google Gemini API Key
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Google Gemini API Key (Direct Cloud AI)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(
                _apiKeyController.text.isNotEmpty ? '● Key Active' : 'Optional (Fallback Gateway)',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: _apiKeyController.text.isNotEmpty ? const Color(0xFF10B981) : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: 'AIzaSy... (Paste Google AI Studio Key for direct 0-delay generation)',
              hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.key_rounded, size: 16, color: Color(0xFF5636F5)),
            ),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),

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
        ],
      ),
    );
  }
}
