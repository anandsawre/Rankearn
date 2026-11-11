import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';
import '../../questions/models/question_item.dart';

class AiGenerateTestSeriesDialog extends StatefulWidget {
  final Function(TestSeriesItem test, List<QuestionItem> questions)
      onSaveGenerated;

  const AiGenerateTestSeriesDialog({
    super.key,
    required this.onSaveGenerated,
  });

  @override
  State<AiGenerateTestSeriesDialog> createState() =>
      _AiGenerateTestSeriesDialogState();
}

class _AiGenerateTestSeriesDialogState
    extends State<AiGenerateTestSeriesDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _topicsController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  List<ExamCategoryModel> _examList = [];
  List<String> _subjects = [];
  String? _targetExam;
  String? _subject;
  String _difficulty = 'Medium';
  int _questionCount = 20;
  int _duration = 60;
  String _language = 'Bilingual (English + Hindi)';
  String _workerUrl = 'https://testkarlo.alleduupdated.workers.dev';

  bool _isLoadingMeta = true;
  bool _isGenerating = false;
  double _progress = 0.0;
  String _statusText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicsController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString('gemini_api_key') ?? '';
      final savedWorker = prefs.getString('gemini_worker_url');
      if (savedKey.isNotEmpty) {
        _apiKeyController.text = savedKey;
      }
      if (savedWorker != null && savedWorker.isNotEmpty) {
        _workerUrl = savedWorker;
      }

      final client = SupabaseConfig.clientSafe;
      if (client != null) {
        final results = await Future.wait<dynamic>([
          TestsRepository().getExamCategoryList(),
          client.from('categories').select('name').order('display_order'),
        ]);
        final examsRes = results[0] as Result<List<ExamCategoryModel>>;
        final catRows = List<Map<String, dynamic>>.from(results[1] as List);

        if (mounted) {
          setState(() {
            _examList = examsRes is Success<List<ExamCategoryModel>>
                ? examsRes.data
                : [];
            _targetExam = _examList.isNotEmpty ? _examList.first.id : null;
            _subjects = catRows
                .map((r) => r['name']?.toString().trim() ?? '')
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList();
            _subject = _subjects.isNotEmpty ? _subjects.first : null;
            _isLoadingMeta = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingMeta = false);
  }

  Future<void> _startGeneration() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Please enter a Test Series Title.');
      return;
    }

    final topics = _topicsController.text.trim().isNotEmpty
        ? _topicsController.text.trim()
        : (_subject ?? 'General Competitive Syllabus');
    final examName = _examList
        .where((e) => e.id == _targetExam)
        .map((e) => e.name)
        .firstOrNull ??
        'Competitive Exam';
    final subjectName = _subject ?? 'General';
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gemini_api_key', apiKey);
      } catch (_) {}
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _progress = 0.15;
      _statusText = 'Connecting to Gemini AI service...';
    });

    final prompt = '''
Generate $_questionCount unique multiple-choice questions for "$examName".
Subject: $subjectName
Topics: $topics
Difficulty: $_difficulty
Language: $_language

Output STRICTLY a valid JSON array of objects, each with:
- "questionText": string
- "questionTextHi": string (Hindi translation if bilingual/Hindi, else empty string)
- "options": array of exactly 4 strings
- "correctOptionIndex": integer 0..3
- "explanation": string
Do not wrap in markdown code fences. Return pure JSON only.
''';

    String rawResponseText = '';
    String? apiError;

    // 1. Direct Google Gemini API if API Key provided
    if (apiKey.isNotEmpty) {
      try {
        setState(() {
          _progress = 0.40;
          _statusText =
              'Generating $_questionCount unique questions via Google Gemini API...';
        });
        final directUri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
        );
        final resp = await http
            .post(
              directUri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt}
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.7,
                  'maxOutputTokens': 8192,
                  'responseMimeType': 'application/json',
                }
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (resp.statusCode == 200) {
          final decoded = jsonDecode(resp.body);
          final candidates = decoded['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            rawResponseText =
                (candidates[0]['content']?['parts']?[0]?['text'] ?? '')
                    .toString();
          }
        } else {
          apiError = 'Gemini API returned HTTP ${resp.statusCode}.';
        }
      } catch (e) {
        apiError = 'Gemini API request failed: $e';
      }
    }

    // 2. Fallback to configured Worker Gateway if direct key not used or failed
    if (rawResponseText.isEmpty) {
      try {
        if (mounted) {
          setState(() {
            _progress = 0.60;
            _statusText = 'Requesting questions from Gemini Edge Gateway...';
          });
        }
        final resp = await http
            .post(
              Uri.parse('$_workerUrl/api/generate'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'prompt': prompt,
                'temperature': 0.7,
                'maxTokens': 8192,
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          rawResponseText =
              (body['text'] ?? body['content'] ?? body['result'] ?? '')
                  .toString();
        } else {
          apiError =
              '${apiError != null ? '$apiError ' : ''}Worker gateway returned HTTP ${resp.statusCode}.';
        }
      } catch (e) {
        apiError =
            '${apiError != null ? '$apiError ' : ''}Worker gateway unreachable: $e';
      }
    }

    if (!mounted) return;

    final parsedQuestions = _parseQuestionsFromJson(
      rawResponseText: rawResponseText,
      subjectName: subjectName,
      testTitle: title,
    );

    if (parsedQuestions.isEmpty) {
      setState(() {
        _isGenerating = false;
        _progress = 0.0;
        _statusText = '';
        _errorMessage = apiKey.isEmpty
            ? 'AI generation failed. Configure a valid Gemini API key above or ensure the Edge Worker is reachable. ${apiError ?? ''}'
            : 'Unable to generate valid questions from Gemini response. ${apiError ?? ''}';
      });
      return;
    }

    setState(() {
      _progress = 1.0;
      _statusText = 'Generated ${parsedQuestions.length} verified questions!';
    });

    final now = DateTime.now();
    final testId = 'ai_test_${now.millisecondsSinceEpoch}';

    final testItem = TestSeriesItem(
      id: testId,
      title: title,
      description: 'AI generated test covering: $topics',
      examCategoryId: _targetExam,
      totalTests: 1,
      totalQuestions: parsedQuestions.length,
      durationMinutes: _duration,
      negativeMarking: 0.25,
      priceInr: 0,
      entryFeeCoins: 0,
      enrollments: 0,
      status: TestSeriesStatus.published,
      testMode: 'mock',
      subject: subjectName,
      topic: topics,
      createdAt: now,
      icon: Icons.auto_awesome_rounded,
      iconColor: const Color(0xFFFF3385),
    );

    final linkedQuestions = parsedQuestions
        .asMap()
        .entries
        .map((e) => e.value.copyWith(
              id: 'q_${testId}_${e.key + 1}',
              testId: testId,
              questionNumber: e.key + 1,
            ))
        .toList();

    widget.onSaveGenerated(testItem, linkedQuestions);
    Navigator.of(context).pop();
  }

  List<QuestionItem> _parseQuestionsFromJson({
    required String rawResponseText,
    required String subjectName,
    required String testTitle,
  }) {
    if (rawResponseText.trim().isEmpty) return [];

    String cleaned = rawResponseText.trim();
    final startIdx = cleaned.indexOf('[');
    final endIdx = cleaned.lastIndexOf(']');
    if (startIdx == -1 || endIdx == -1 || endIdx <= startIdx) return [];
    cleaned = cleaned.substring(startIdx, endIdx + 1);

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! List) return [];

      final difficulty = switch (_difficulty.toLowerCase()) {
        'easy' => QuestionDifficulty.easy,
        'hard' => QuestionDifficulty.hard,
        _ => QuestionDifficulty.medium,
      };
      const letters = ['A', 'B', 'C', 'D'];
      final now = DateTime.now();

      final list = <QuestionItem>[];
      for (int i = 0; i < decoded.length; i++) {
        final raw = decoded[i];
        if (raw is! Map) continue;
        final qText = raw['questionText']?.toString().trim() ?? '';
        final optsRaw = raw['options'];
        if (qText.isEmpty || optsRaw is! List || optsRaw.length < 4) continue;

        final correctIdx =
            ((raw['correctOptionIndex'] as num?)?.toInt() ?? 0).clamp(0, 3);
        final options = List<QuestionOptionItem>.generate(
          4,
          (idx) => QuestionOptionItem(
            label: letters[idx],
            text: optsRaw[idx].toString().trim(),
          ),
        );

        list.add(
          QuestionItem(
            id: 'ai_q_${now.microsecondsSinceEpoch}_$i',
            questionNumber: i + 1,
            questionText: qText,
            questionTextHindi: raw['questionTextHi']?.toString().trim(),
            subject: subjectName,
            testSeriesTitle: testTitle,
            questionType: 'MCQ',
            difficulty: difficulty,
            correctAnswerIndex: correctIdx,
            correctAnswerChar: letters[correctIdx],
            usageCount: 0,
            status: QuestionStatus.published,
            createdAt: now,
            options: options,
            explanation: raw['explanation']?.toString().trim(),
            marks: 1.0,
            negativeMarks: 0.25,
          ),
        );
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'AI Generate Test Series',
      subtitle: 'Synthesize exam-standard mock tests using live Gemini AI',
      iconData: Icons.auto_awesome_rounded,
      gradientColors: const [Color(0xFFFF3385), Color(0xFFEC4899)],
      maxWidth: 620,
      scrollable: true,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3385),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: _isGenerating ? null : _startGeneration,
          icon: _isGenerating
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.auto_awesome_rounded, size: 16),
          label: Text(
            _isGenerating ? 'Generating...' : 'Generate Test Series',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.errorRoseLight,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Row 1: Target Exam & Subject
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Exam', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _examList.any((e) => e.id == _targetExam)
                          ? _targetExam
                          : null,
                      hint: _isLoadingMeta
                          ? 'Loading exams...'
                          : 'Select Target Exam...',
                      items: _examList
                          .map((e) => AppDropdownItem(
                                value: e.id,
                                label: '${e.iconUrl ?? "🎯"} ${e.name}',
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _targetExam = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subject Focus', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _subjects.contains(_subject) ? _subject : null,
                      hint: _isLoadingMeta
                          ? 'Loading subjects...'
                          : 'Select Subject...',
                      items: _subjects
                          .map((s) => AppDropdownItem(value: s, label: s))
                          .toList(),
                      onChanged: (val) => setState(() => _subject = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Test Title
          const Text('Test Series Title *', style: _labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 13),
            decoration:
                _inputDecoration('e.g. RRB ALP CBT 1 - Rapid Science Mock 01'),
          ),
          const SizedBox(height: 14),

          // Row 2: Questions Count, Duration & Difficulty
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Questions *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<int>(
                      value: _questionCount,
                      items: const [
                        AppDropdownItem(value: 10, label: '10 Questions'),
                        AppDropdownItem(value: 20, label: '20 Questions'),
                        AppDropdownItem(value: 30, label: '30 Questions'),
                        AppDropdownItem(value: 50, label: '50 Questions'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _questionCount = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Duration *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<int>(
                      value: _duration,
                      items: const [
                        AppDropdownItem(value: 30, label: '30 Minutes'),
                        AppDropdownItem(value: 45, label: '45 Minutes'),
                        AppDropdownItem(value: 60, label: '60 Minutes'),
                        AppDropdownItem(value: 90, label: '90 Minutes'),
                        AppDropdownItem(value: 120, label: '120 Minutes'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _duration = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Difficulty *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _difficulty,
                      items: const [
                        AppDropdownItem(value: 'Easy', label: 'Easy Level'),
                        AppDropdownItem(
                            value: 'Medium', label: 'Standard Medium'),
                        AppDropdownItem(value: 'Hard', label: 'Advanced Hard'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _difficulty = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Language & Topic Coverage
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Language *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _language,
                      items: const [
                        AppDropdownItem(
                            value: 'Bilingual (English + Hindi)',
                            label: '🌐 Bilingual (Eng + Hindi)'),
                        AppDropdownItem(
                            value: 'English Only', label: '🇬🇧 English Only'),
                        AppDropdownItem(
                            value: 'Hindi Only', label: '🇮🇳 Hindi Only'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _language = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Syllabus / Topics Focus', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _topicsController,
                      style: const TextStyle(fontSize: 12),
                      decoration: _inputDecoration(
                          'e.g. Physics, Chemistry, Indian Polity'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Optional Direct Gemini API Key
          const Text('Gemini API Key (saved locally for direct API calls)',
              style: _labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            style: const TextStyle(fontSize: 12),
            decoration:
                _inputDecoration('AIza... (Optional if Edge Worker is active)'),
          ),

          // Progress indicator during generation
          if (_isGenerating) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFBCFE8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Color(0xFFFF3385), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusText,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9D174D)),
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF3385)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: const Color(0xFFFCE7F3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFF3385)),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: const Color(0xFFFF3385));
}
