import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';

class AiGenerateQuestionsDialog extends StatefulWidget {
  final ValueChanged<List<QuestionItem>> onSaveGenerated;

  const AiGenerateQuestionsDialog({super.key, required this.onSaveGenerated});

  @override
  State<AiGenerateQuestionsDialog> createState() => _AiGenerateQuestionsDialogState();
}

class _AiGenerateQuestionsDialogState extends State<AiGenerateQuestionsDialog> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  List<String> _subjects = ['General'];
  String _selectedSubject = 'General';

  final Map<String, String> _testTitleToId = {};
  List<String> _testTitles = ['Unassigned (General Bank)'];
  String _selectedTestTitle = 'Unassigned (General Bank)';

  QuestionDifficulty _selectedDifficulty = QuestionDifficulty.medium;
  int _questionCount = 5;
  String _language = 'English';
  String? _workerUrl;

  bool _isGenerating = false;
  String? _errorMessage;
  List<QuestionItem> _generatedQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString('gemini_api_key') ?? '';
      final savedWorker = prefs.getString('gemini_worker_url');
      if (savedKey.isNotEmpty && mounted) {
        _apiKeyController.text = savedKey;
      }
      if (savedWorker != null && savedWorker.isNotEmpty) {
        _workerUrl = savedWorker;
      }

      final client = SupabaseConfig.clientSafe;
      if (client != null) {
        final results = await Future.wait([
          client.from('categories').select('name').order('display_order', ascending: true),
          client.from('tests').select('id, title').order('created_at', ascending: false),
        ]);

        final catRows = List<Map<String, dynamic>>.from(results[0] as List);
        final testRows = List<Map<String, dynamic>>.from(results[1] as List);

        final loadedSubjects = catRows
            .map((r) => r['name']?.toString().trim() ?? '')
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList();

        final loadedTests = <String>['Unassigned (General Bank)'];
        for (final t in testRows) {
          final id = t['id']?.toString() ?? '';
          final title = t['title']?.toString().trim() ?? '';
          if (title.isNotEmpty) {
            loadedTests.add(title);
            if (id.isNotEmpty) _testTitleToId[title] = id;
          }
        }

        if (!mounted) return;
        setState(() {
          if (loadedSubjects.isNotEmpty) {
            _subjects = loadedSubjects;
            _selectedSubject = loadedSubjects.first;
          }
          _testTitles = loadedTests;
          if (loadedTests.length > 1) {
            _selectedTestTitle = loadedTests[1];
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _topicController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestions() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() => _errorMessage = 'Please enter a topic or syllabus area.');
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedQuestions = [];
    });

    final prompt = '''
Generate $_questionCount multiple choice questions in valid JSON array format ONLY (no markdown fences).
Subject: $_selectedSubject
Topic: $topic
Difficulty: ${_selectedDifficulty.label.toLowerCase()}
Language: $_language

Each array element MUST match:
{
  "question_text_english": "Clear question stem",
  "question_text_hindi": ${_language == 'English' ? 'null' : '"Hindi translation"'},
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correct_answer": 0,
  "explanation_english": "Concise solution",
  "subject": "$_selectedSubject"
}
Return ONLY the JSON array.
''';

    String rawResponseText = '';
    String? apiError;

    // 1. Direct Google Gemini API if API Key provided
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gemini_api_key', apiKey);

        final directUri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=$apiKey',
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
                (candidates[0]['content']?['parts']?[0]?['text'] ?? '').toString();
          }
        } else {
          apiError = 'Gemini API returned HTTP ${resp.statusCode}.';
        }
      } catch (e) {
        apiError = 'Gemini API request failed: $e';
      }
    }

    // 2. Try Supabase Edge Function gemini-proxy when authenticated
    final client = SupabaseConfig.clientSafe;
    final currentSession = client?.auth.currentSession;
    if (rawResponseText.isEmpty && client != null && currentSession != null) {
      try {
        var accessToken = currentSession.accessToken;
        if (currentSession.isExpired) {
          try {
            final refreshed = await client.auth.refreshSession();
            accessToken = refreshed.session?.accessToken ?? accessToken;
          } catch (_) {}
        }
        final edgeResp = await client.functions.invoke(
          'gemini-proxy',
          headers: {'Authorization': 'Bearer $accessToken'},
          body: {
            'model': 'gemini-3.8-flash',
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
            },
          },
        );
        if (edgeResp.status == 200 && edgeResp.data != null) {
          final data = edgeResp.data is String
              ? jsonDecode(edgeResp.data as String)
              : edgeResp.data;
          if (data is Map) {
            final candidates = data['candidates'] as List<dynamic>?;
            if (candidates != null && candidates.isNotEmpty) {
              rawResponseText =
                  (candidates[0]['content']?['parts']?[0]?['text'] ?? '').toString();
            }
          }
        } else {
          apiError =
              '${apiError != null ? '$apiError ' : ''}Supabase gemini-proxy returned status ${edgeResp.status}.';
        }
      } catch (e) {
        apiError =
            '${apiError != null ? '$apiError ' : ''}Supabase gemini-proxy error: $e';
      }
    }

    // 3. Try configured worker gateway if set in preferences
    if (rawResponseText.isEmpty && _workerUrl != null && _workerUrl!.isNotEmpty) {
      try {
        final resp = await http
            .post(
              Uri.parse('$_workerUrl/api/generate'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'prompt': prompt, 'temperature': 0.7, 'maxTokens': 8192}),
            )
            .timeout(const Duration(seconds: 45));

        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          rawResponseText =
              (body['text'] ?? body['content'] ?? body['result'] ?? '').toString();
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

    final parsed = _parseQuestionsFromJson(rawResponseText);
    if (parsed.isEmpty) {
      setState(() {
        _isGenerating = false;
        _errorMessage = apiError ??
            'No valid questions returned. Provide a Gemini API key or ensure Supabase gemini-proxy Edge Function is configured.';
      });
      return;
    }

    setState(() {
      _isGenerating = false;
      _generatedQuestions = parsed;
    });
  }

  List<QuestionItem> _parseQuestionsFromJson(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      String cleaned = raw.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned
            .replaceFirst(RegExp(r'^```json\s*', caseSensitive: false), '')
            .replaceFirst(RegExp(r'^```\s*'), '')
            .replaceFirst(RegExp(r'\s*```$'), '')
            .trim();
      }
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) return [];
      cleaned = cleaned.substring(start, end + 1);

      final decoded = jsonDecode(cleaned);
      if (decoded is! List) return [];

      final labels = ['A', 'B', 'C', 'D'];
      final targetTestId = _selectedTestTitle == 'Unassigned (General Bank)'
          ? null
          : _testTitleToId[_selectedTestTitle];
      final now = DateTime.now();

      final items = <QuestionItem>[];
      for (int i = 0; i < decoded.length; i++) {
        final obj = decoded[i];
        if (obj is! Map) continue;
        final textEn = obj['question_text_english']?.toString().trim() ??
            obj['question_text']?.toString().trim() ??
            '';
        if (textEn.isEmpty) continue;

        final rawOpts = obj['options'];
        final opts = <QuestionOptionItem>[];
        if (rawOpts is List) {
          for (int k = 0; k < rawOpts.length && k < 4; k++) {
            final item = rawOpts[k];
            final optText = item is Map
                ? (item['text'] ?? item['text_english'] ?? '').toString()
                : item.toString();
            opts.add(QuestionOptionItem(label: labels[k], text: optText));
          }
        }
        while (opts.length < 4) {
          opts.add(QuestionOptionItem(label: labels[opts.length], text: 'Option ${labels[opts.length]}'));
        }

        final ansIdx = ((obj['correct_answer'] as num?)?.toInt() ?? 0).clamp(0, 3);
        items.add(
          QuestionItem(
            id: 'q_${now.microsecondsSinceEpoch}_$i',
            questionNumber: i + 1,
            questionText: textEn,
            questionTextHindi: obj['question_text_hindi']?.toString(),
            subject: obj['subject']?.toString().trim().isNotEmpty == true
                ? obj['subject'].toString().trim()
                : _selectedSubject,
            testSeriesTitle: _selectedTestTitle,
            testId: targetTestId,
            questionType: 'MCQ',
            difficulty: _selectedDifficulty,
            options: opts,
            correctAnswerIndex: ansIdx,
            correctAnswerChar: labels[ansIdx],
            usageCount: 0,
            status: QuestionStatus.published,
            createdAt: now,
            explanation: obj['explanation_english']?.toString() ??
                obj['explanation']?.toString(),
          ),
        );
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  void _confirmSave() {
    if (_generatedQuestions.isEmpty) return;
    widget.onSaveGenerated(_generatedQuestions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final subjValue = _subjects.contains(_selectedSubject) ? _selectedSubject : _subjects.first;
    final testValue = _testTitles.contains(_selectedTestTitle) ? _selectedTestTitle : _testTitles.first;

    return AppModalDialog(
      title: 'AI Question Generator',
      subtitle: 'Generate syllabus-aligned questions using Gemini / Supabase Edge Proxy',
      iconData: Icons.auto_awesome_rounded,
      gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
      maxWidth: 680,
      scrollable: true,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          onPressed: _generatedQuestions.isNotEmpty ? _confirmSave : null,
          child: Text(
            _generatedQuestions.isNotEmpty
                ? 'Save ${_generatedQuestions.length} Questions to Bank'
                : 'Save to Bank',
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
              margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildField(
                  label: 'Subject',
                  child: AppDropdown<String>(
                    value: subjValue,
                    items: _subjects.map((s) => AppDropdownItem(value: s, label: s)).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubject = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: _buildField(
                  label: 'Target Test Series',
                  child: AppDropdown<String>(
                    value: testValue,
                    items: _testTitles.map((t) => AppDropdownItem(value: t, label: t)).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTestTitle = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'Topic / Syllabus Area *',
            child: TextFormField(
              controller: _topicController,
              style: const TextStyle(fontSize: 12.5),
              decoration: _inputDecoration(hint: 'Enter topic or syllabus area...'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Difficulty',
                  child: AppDropdown<QuestionDifficulty>(
                    value: _selectedDifficulty,
                    items: [
                      QuestionDifficulty.easy,
                      QuestionDifficulty.medium,
                      QuestionDifficulty.hard,
                    ].map((d) => AppDropdownItem(value: d, label: d.label)).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDifficulty = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Questions Count',
                  child: AppDropdown<int>(
                    value: _questionCount,
                    items: const [3, 5, 10, 20]
                        .map((c) => AppDropdownItem(value: c, label: '$c Questions'))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _questionCount = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Language',
                  child: AppDropdown<String>(
                    value: _language,
                    items: const ['English', 'Hindi', 'Bilingual']
                        .map((l) => AppDropdownItem(value: l, label: l))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _language = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'Gemini API Key (optional if Supabase Edge Proxy is active)',
            child: TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              style: const TextStyle(fontSize: 12.5),
              decoration: _inputDecoration(hint: 'AIza...'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                _isGenerating ? 'Generating Questions...' : 'Generate Questions with AI',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              onPressed: _isGenerating ? null : _generateQuestions,
            ),
          ),
          if (_generatedQuestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generated Questions (${_generatedQuestions.length})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                ),
                const Text(
                  'Review before saving to Question Bank',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < _generatedQuestions.length; i++) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Q#${i + 1}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF5636F5)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _generatedQuestions[i].questionText,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          onPressed: () {
                            setState(() => _generatedQuestions.removeAt(i));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    for (final opt in _generatedQuestions[i].options)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Row(
                          children: [
                            Text('${opt.label}. ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            Expanded(
                              child: Text(
                                opt.text,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: opt.label == _generatedQuestions[i].correctAnswerChar
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: opt.label == _generatedQuestions[i].correctAnswerChar
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) =>
      AppModalDialog.inputDecoration(hint ?? '', focusColor: const Color(0xFF10B981));
}
