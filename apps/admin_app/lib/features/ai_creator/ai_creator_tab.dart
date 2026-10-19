import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AiCreatorTab extends StatefulWidget {
  final VoidCallback onSavedToTests;

  const AiCreatorTab({
    super.key,
    required this.onSavedToTests,
  });

  @override
  State<AiCreatorTab> createState() => _AiCreatorTabState();
}

class _AiCreatorTabState extends State<AiCreatorTab> {
  final _titleController = TextEditingController(text: 'Modern History of Bihar Sprint');
  final _promptController = TextEditingController(text: 'Focus on 1857 Revolt in Bihar, Kunwar Singh leadership, Champaran Satyagraha, and Quit India movement events.');
  String _selectedExam = '70th BPSC';
  String _selectedSubject = 'History & Culture';
  String _selectedKnowledgeSource = 'topic'; // 'topic', 'youtube', 'file'
  String _languageMode = 'bilingual'; // 'english', 'hindi', 'bilingual'
  int _questionCount = 10;
  String _difficulty = 'moderate';
  bool _isGenerating = false;
  List<Map<String, dynamic>>? _generatedQuestions;

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _generateQuestions() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _isGenerating = false;
      _generatedQuestions = [
        {
          'qEn': 'Who was the primary leader of the 1857 Sepoy Mutiny in Jagdishpur, Bihar?',
          'qHi': 'बिहार के जगदीशपुर में 1857 के सिपाही विद्रोह के मुख्य नेता कौन थे?',
          'options': [
            {'text': 'Veer Kunwar Singh (वीर कुंवर सिंह)', 'isCorrect': true},
            {'text': 'Amar Singh (अमर सिंह)', 'isCorrect': false},
            {'text': 'Pir Ali Khan (पीर अली खान)', 'isCorrect': false},
            {'text': 'Hare Krishna Singh (हरे कृष्ण सिंह)', 'isCorrect': false},
          ],
          'explanation': 'Veer Kunwar Singh of Jagdishpur was an 80-year-old landlord who led the armed struggle against the British East India Company in Bihar during the 1857 rebellion.',
        },
        {
          'qEn': 'At whose invitation did Mahatma Gandhi visit Champaran in 1917?',
          'qHi': '1917 में किसके निमंत्रण पर महात्मा गांधी चंपारण पहुंचे थे?',
          'options': [
            {'text': 'Raj Kumar Shukla (राजकुमार शुक्ल)', 'isCorrect': true},
            {'text': 'Dr. Rajendra Prasad (डॉ. राजेंद्र प्रसाद)', 'isCorrect': false},
            {'text': 'J.B. Kripalani (जे.बी. कृपलानी)', 'isCorrect': false},
            {'text': 'Brajkishore Prasad (ब्रजकिशोर प्रसाद)', 'isCorrect': false},
          ],
          'explanation': 'Raj Kumar Shukla was an indigo farmer who relentlessly pursued Gandhi at the Lucknow Congress session in 1916 to investigate the Tinkathia system.',
        },
        {
          'qEn': 'During the Quit India Movement (1942), who established the underground resistance "Azad Dasta" in the forests of Nepal?',
          'qHi': 'भारत छोड़ो आंदोलन (1942) के दौरान नेपाल के जंगलों में भूमिगत प्रतिरोध "आजाद दस्ता" का गठन किसने किया था?',
          'options': [
            {'text': 'Jayaprakash Narayan (जयप्रकाश नारायण)', 'isCorrect': true},
            {'text': 'Ram Manohar Lohia (राम मनोहर लोहिया)', 'isCorrect': false},
            {'text': 'Aruna Asaf Ali (अरुणा आसफ अली)', 'isCorrect': false},
            {'text': 'Yogendra Shukla (योगेंद्र शुक्ल)', 'isCorrect': false},
          ],
          'explanation': 'Jayaprakash Narayan escaped from Hazaribagh Jail on Diwali night in 1942 and founded the guerrilla training network Azad Dasta in the Terai region of Nepal.',
        },
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✨ Gemini AI generation completed! Review questions below.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Unified Master Header
          _buildMasterHeader(),
          const SizedBox(height: 24),

          // 2. Step 1: Test Architecture
          _buildStep1Architecture(),
          const SizedBox(height: 24),

          // 3. Step 2: Knowledge Source & Generation Prompt
          _buildStep2KnowledgeSource(),
          const SizedBox(height: 24),

          // 4. Output Preview (if generated)
          if (_generatedQuestions != null) ...[
            _buildGeneratedQuestionsPreview(),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildMasterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: AppRadii.borderLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandPrimary.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Test Intelligence', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Neural Content Generation Engine Powered by Gemini 1.5 Flash', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Architecture() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('01', style: TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              const Text('TEST ARCHITECTURE & TARGET BLUEPRINT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF334155), letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 320,
                child: AppTextField(
                  controller: _titleController,
                  label: 'Test Series Title',
                  hintText: 'e.g. Modern History of Bihar Sprint',
                ),
              ),
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Exam', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.borderMd,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedExam,
                          isExpanded: true,
                          items: ['70th BPSC', 'SSC CGL', 'Railway NTPC', 'UPSC CSE'].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedExam = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Syllabus Subject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.borderMd,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSubject,
                          isExpanded: true,
                          items: ['History & Culture', 'General Science', 'Indian Polity', 'Current Affairs'].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSubject = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2KnowledgeSource() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('02', style: TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              const Text('KNOWLEDGE SOURCE & GENERATION PARAMETERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF334155), letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 20),

          // 3 Source Selector Cards
          Row(
            children: [
              _buildSourceCard('Prompt / Context', Icons.description_outlined, 'Generate from topics or notes', 'topic'),
              const SizedBox(width: 14),
              _buildSourceCard('YouTube Video', Icons.smart_display_outlined, 'Transcribe and quiz video', 'youtube'),
              const SizedBox(width: 14),
              _buildSourceCard('Document / PDF', Icons.upload_file_outlined, 'Scan textbook or notes file', 'file'),
            ],
          ),
          const SizedBox(height: 20),

          // Prompt or URL input
          AppTextField(
            controller: _promptController,
            label: _selectedKnowledgeSource == 'youtube' ? 'YouTube Video URL' : 'Topic Prompt / Syllabus Notes',
            hintText: _selectedKnowledgeSource == 'youtube' ? 'https://youtube.com/watch?v=...' : 'Enter syllabus topics, subtopics, or specific historical periods...',
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Language, Count, Difficulty selectors
          Wrap(
            spacing: 24,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Language
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Language Output', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildLangPill('Bilingual (Hindi + En)', 'bilingual'),
                      _buildLangPill('English Only', 'english'),
                      _buildLangPill('Hindi Only', 'hindi'),
                    ],
                  ),
                ],
              ),

              // Question count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Question Count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [10, 25, 50].map((c) {
                      final isSelected = _questionCount == c;
                      return ChoiceChip(
                        label: Text('$c Qs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                        selected: isSelected,
                        selectedColor: AppColors.brandPrimary,
                        backgroundColor: const Color(0xFFF8FAFC),
                        onSelected: (_) => setState(() => _questionCount = c),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Difficulty level
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Difficulty Level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ['easy', 'moderate', 'hard'].map((d) {
                      final isSelected = _difficulty == d;
                      return ChoiceChip(
                        label: Text(d.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                        selected: isSelected,
                        selectedColor: AppColors.brandPrimary,
                        backgroundColor: const Color(0xFFF8FAFC),
                        onSelected: (_) => setState(() => _difficulty = d),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Generate Action Button
          AppButton(
            label: _isGenerating ? 'Synthesizing with Gemini 1.5 Flash...' : '✨ Generate Test Paper with Gemini AI',
            isLoading: _isGenerating,
            onPressed: _isGenerating ? null : _generateQuestions,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(String title, IconData icon, String subtitle, String type) {
    final isSelected = _selectedKnowledgeSource == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedKnowledgeSource = type),
        borderRadius: AppRadii.borderLg,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: AppRadii.borderLg,
            border: Border.all(color: isSelected ? AppColors.brandPrimary : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: isSelected ? AppColors.brandPrimary : const Color(0xFF64748B)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isSelected ? AppColors.brandPrimaryDark : const Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangPill(String label, String code) {
    final isSelected = _languageMode == code;
    return InkWell(
      onTap: () => setState(() => _languageMode = code),
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : const Color(0xFFF1F5F9),
          borderRadius: AppRadii.borderSm,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedQuestionsPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.brandPrimary, size: 22),
                  const SizedBox(width: 10),
                  Text('Generated Questions (${_generatedQuestions!.length} Verified MCQs)', style: AppTypography.titleLarge),
                ],
              ),
              AppButton(
                label: '💾 Commit to Test Repository',
                size: AppButtonSize.small,
                onPressed: () {
                  widget.onSavedToTests();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Committed test paper to Test Repository!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Column(
            children: _generatedQuestions!.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              final options = q['options'] as List<dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: AppRadii.borderLg,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q${idx + 1}. ${q['qEn']}', style: AppTypography.titleMedium),
                    const SizedBox(height: 2),
                    Text(q['qHi'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 10),

                    // Options
                    ...options.map((opt) {
                      final isCorrect = opt['isCorrect'] == true;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(isCorrect ? Icons.check_circle : Icons.circle_outlined, size: 14, color: isCorrect ? AppColors.brandPrimary : const Color(0xFF94A3B8)),
                            const SizedBox(width: 8),
                            Text(
                              opt['text'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCorrect ? FontWeight.w800 : FontWeight.normal,
                                color: isCorrect ? AppColors.brandPrimaryDark : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: AppRadii.borderSm,
                      ),
                      child: Text(
                        '💡 Explanation: ${q['explanation']}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
