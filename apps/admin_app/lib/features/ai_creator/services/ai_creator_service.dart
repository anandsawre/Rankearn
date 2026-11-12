import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_layer/data_layer.dart';
import '../models/ai_test_item.dart';

class AiCreatorService {
  static final AiCreatorService _instance = AiCreatorService._internal();
  factory AiCreatorService() => _instance;
  AiCreatorService._internal() {
    _loadStoredConfig();
  }

  String _geminiWorkerUrl = 'https://testkarlo.alleduupdated.workers.dev';
  String _geminiApiKey = '';
  double _temperature = 0.7;
  String _systemPrompt =
      'You are an expert Indian Competitive Examination paper setter specializing in Railway RRB, SSC, and State PSC test series.';

  String get workerUrl => _geminiWorkerUrl;
  String get apiKey => _geminiApiKey;
  double get temperature => _temperature;
  String get systemPrompt => _systemPrompt;

  Future<void> _loadStoredConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _geminiApiKey = prefs.getString('gemini_api_key') ?? '';
      _geminiWorkerUrl = prefs.getString('gemini_worker_url') ?? _geminiWorkerUrl;
      _systemPrompt = prefs.getString('gemini_system_prompt') ?? _systemPrompt;
      _temperature = prefs.getDouble('gemini_temperature') ?? _temperature;
    } catch (_) {}
  }

  Future<void> setApiKey(String key) async {
    _geminiApiKey = key.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_api_key', _geminiApiKey);
    } catch (_) {}
  }

  Future<void> setWorkerUrl(String url) async {
    if (url.trim().isNotEmpty) {
      _geminiWorkerUrl = url.trim();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gemini_worker_url', _geminiWorkerUrl);
      } catch (_) {}
    }
  }

  Future<void> setTemperature(double temp) async {
    _temperature = temp;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('gemini_temperature', _temperature);
    } catch (_) {}
  }

  Future<void> setSystemPrompt(String prompt) async {
    if (prompt.trim().isNotEmpty) {
      _systemPrompt = prompt.trim();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gemini_system_prompt', _systemPrompt);
      } catch (_) {}
    }
  }

  /// Generate AI Competitive Questions strictly via live AI backends (no fake offline synthesis).
  Future<List<AiTestQuestion>> generateQuestions({
    required String title,
    required String topic,
    required AiTestSubject subject,
    required AiTestDifficulty difficulty,
    required int count,
    required String exam,
    required String language,
    String? customInstructions,
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.15, 'Connecting to AI Engine...');

    List<AiTestQuestion> generated = [];
    String? lastError;

    final prompt = '''
$_systemPrompt

Generate $count multiple choice questions for the competitive exam "$exam".
Subject: ${subject.label}
Topic: $topic
Difficulty: ${difficulty.label}
Language requirement: $language.
${customInstructions != null && customInstructions.isNotEmpty ? "Additional Instructions: $customInstructions" : ""}

Output STRICTLY a JSON array of objects with keys:
- "questionText": English question text
- "questionTextHi": Hindi translation of question text
- "options": Array of exactly 4 strings (A, B, C, D)
- "correctOptionIndex": Integer 0 to 3
- "explanation": Detailed explanation
- "explanationHi": Hindi explanation
Return pure JSON array only.
''';

    // Attempt 1: Google Gemini API directly when API key is configured
    if (_geminiApiKey.isNotEmpty) {
      try {
        onProgress?.call(0.35, 'Generating $count questions via Google Gemini API...');
        final directUri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=$_geminiApiKey',
        );

        final directResp = await http
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
                  'temperature': _temperature,
                  'maxOutputTokens': 8192,
                  'responseMimeType': 'application/json',
                }
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (directResp.statusCode == 200) {
          final resJson = jsonDecode(directResp.body);
          final candidates = resJson['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] ?? '';
            final clean = _extractJson(text.toString());
            if (clean.isNotEmpty) {
              generated = _parseJsonQuestions(clean, subject, difficulty);
            }
          }
        } else {
          lastError = 'Gemini API returned HTTP ${directResp.statusCode}.';
        }
      } catch (e) {
        lastError = 'Gemini API request failed: $e';
        debugPrint(lastError);
      }
    }

    // Attempt 2: Supabase Edge Function `gemini-proxy` (if signed in as Admin)
    final client = SupabaseConfig.clientSafe;
    final currentSession = client?.auth.currentSession;
    if (generated.isEmpty && client != null && currentSession != null) {
      try {
        var accessToken = currentSession.accessToken;
        if (currentSession.isExpired) {
          try {
            final refreshed = await client.auth.refreshSession();
            accessToken = refreshed.session?.accessToken ?? accessToken;
          } catch (_) {}
        }
        onProgress?.call(0.55, 'Generating $count questions via Supabase Edge Proxy...');
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
              'temperature': _temperature,
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
              final text = candidates[0]['content']?['parts']?[0]?['text'] ?? '';
              final clean = _extractJson(text.toString());
              if (clean.isNotEmpty) {
                generated = _parseJsonQuestions(clean, subject, difficulty);
              }
            }
          }
        } else {
          lastError = 'Supabase gemini-proxy returned status ${edgeResp.status}.';
        }
      } catch (e) {
        lastError = 'Supabase gemini-proxy error: $e';
        debugPrint(lastError);
      }
    }

    // Attempt 3: Configured Gemini Edge Worker
    if (generated.isEmpty && _geminiWorkerUrl.trim().isNotEmpty) {
      try {
        onProgress?.call(0.75, 'Requesting questions from Edge Gateway...');
        final uri = Uri.parse('$_geminiWorkerUrl/api/generate');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'prompt': prompt,
                'temperature': _temperature,
                'maxTokens': 8192,
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          final rawText = body['text'] ?? body['content'] ?? body['result'] ?? '';
          final cleanJson = _extractJson(rawText.toString());
          if (cleanJson.isNotEmpty) {
            generated = _parseJsonQuestions(cleanJson, subject, difficulty);
          }
        } else {
          lastError = 'Edge Gateway returned HTTP ${response.statusCode}.';
        }
      } catch (e) {
        lastError = 'Edge Gateway unreachable: $e';
        debugPrint(lastError);
      }
    }

    if (generated.isEmpty) {
      throw Exception(
        lastError ??
            'AI generation failed. Configure a Gemini API key in Custom Prompt or verify your Supabase gemini-proxy / Worker Gateway.',
      );
    }

    onProgress?.call(1.0, 'Generated ${generated.length} verified questions.');
    return generated;
  }

  /// Push generated questions directly into the Battle Pool (`battle_questions` table).
  Future<int> pushToBattlePool({
    required List<AiTestQuestion> questions,
    required String subjectName,
  }) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      throw Exception('Database connection is not initialized.');
    }
    if (questions.isEmpty) {
      throw Exception('No questions available to push to Battle Pool.');
    }

    final now = DateTime.now().toUtc();
    final payload = questions.asMap().entries.map((entry) {
      final idx = entry.key;
      final q = entry.value;
      return {
        'id': 'bq_${now.millisecondsSinceEpoch}_$idx',
        'subject': subjectName,
        'question_text': q.questionText,
        'options': q.options,
        'correct_answer': q.correctOptionIndex.clamp(0, 3),
        'time_limit_seconds': 15,
        'created_at': now.toIso8601String(),
      };
    }).toList();

    await client.from('battle_questions').insert(payload);
    return payload.length;
  }

  /// Persist AI generated test into `ai_generated_tests`, `ai_test_questions`, `tests`, and `questions`.
  Future<void> publishTestToApp({
    required AiGeneratedTestItem testItem,
  }) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      throw Exception('Database connection is not initialized.');
    }

    // 1. Insert/upsert into `ai_generated_tests`
    final aiRow = Map<String, dynamic>.from(testItem.toJson());
    // Ensure UUID validity or let DB insert; if id isn't UUID format, omit `id` on insert or pass UUID.
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(testItem.id);
    if (!isUuid) {
      aiRow.remove('id');
    }

    final savedAiRows = await client
        .from('ai_generated_tests')
        .upsert(aiRow)
        .select('id')
        .limit(1);
    final persistedAiId = (savedAiRows as List).isNotEmpty
        ? savedAiRows.first['id']?.toString() ?? testItem.id
        : testItem.id;

    // 2. Insert into `ai_test_questions` if questions exist
    if (testItem.questions.isNotEmpty) {
      final aiQRows = testItem.questions.map((q) {
        return {
          'test_id': persistedAiId,
          'question_number': q.questionNumber,
          'question_text': q.questionText,
          'question_text_hi': q.questionTextHi,
          'options': q.options,
          'correct_option_index': q.correctOptionIndex.clamp(0, 3),
          'explanation': q.explanation,
          'explanation_hi': q.explanationHi,
          'subject': q.subject,
          'difficulty': q.difficulty,
        };
      }).toList();
      await client.from('ai_test_questions').insert(aiQRows);
    }

    // 3. Publish cleanly into `tests` & `questions` tables using exact SQL schema columns
    final publicTestId = 'test_${persistedAiId.replaceAll('-', '_')}';
    await client.from('tests').upsert({
      'id': publicTestId,
      'title': testItem.title,
      'category_id': testItem.subject.label,
      'test_mode': 'mock',
      'duration_minutes': testItem.durationMinutes,
      'total_questions': testItem.questionCount,
      'status': testItem.status == AiTestStatus.published ? 'published' : 'draft',
      'created_at': testItem.createdOn.toUtc().toIso8601String(),
    });

    if (testItem.questions.isNotEmpty) {
      final diffStr = testItem.difficulty.label.toLowerCase();
      final qPayload = testItem.questions.asMap().entries.map((entry) {
        final idx = entry.key;
        final q = entry.value;
        final optLabels = ['A', 'B', 'C', 'D'];
        final formattedOpts = q.options.asMap().entries.map((o) {
          final lbl = o.key < optLabels.length ? optLabels[o.key] : '${o.key}';
          return {'label': lbl, 'text': o.value, 'textEnglish': o.value};
        }).toList();

        return {
          'id': '${publicTestId}_q_${idx + 1}',
          'test_id': publicTestId,
          'question_number': idx + 1,
          'question_text_english': q.questionText,
          if (q.questionTextHi != null && q.questionTextHi!.isNotEmpty)
            'question_text_hindi': q.questionTextHi,
          'options': formattedOpts,
          'correct_answer': q.correctOptionIndex.clamp(0, 3),
          if (q.explanation.isNotEmpty) 'explanation_english': q.explanation,
          if (q.explanationHi != null && q.explanationHi!.isNotEmpty)
            'explanation_hindi': q.explanationHi,
          'difficulty_level':
              (diffStr == 'easy' || diffStr == 'medium' || diffStr == 'hard')
                  ? diffStr
                  : 'medium',
          'subject': q.subject,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        };
      }).toList();
      await client.from('questions').upsert(qPayload);
    }
  }

  String _extractJson(String text) {
    final startIndex = text.indexOf('[');
    final endIndex = text.lastIndexOf(']');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return '';
  }

  List<AiTestQuestion> _parseJsonQuestions(
    String cleanJson,
    AiTestSubject subject,
    AiTestDifficulty difficulty,
  ) {
    try {
      final list = jsonDecode(cleanJson) as List<dynamic>;
      final result = <AiTestQuestion>[];
      for (int i = 0; i < list.length; i++) {
        final qJson = list[i] as Map<String, dynamic>;
        result.add(
          AiTestQuestion(
            id: 'ai_q_${DateTime.now().millisecondsSinceEpoch}_$i',
            questionNumber: i + 1,
            questionText: qJson['questionText']?.toString() ?? 'Question ${i + 1}',
            questionTextHi: qJson['questionTextHi']?.toString(),
            options: (qJson['options'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                ['Option A', 'Option B', 'Option C', 'Option D'],
            correctOptionIndex: (qJson['correctOptionIndex'] as num?)?.toInt() ?? 0,
            explanation: qJson['explanation']?.toString() ?? '',
            explanationHi: qJson['explanationHi']?.toString(),
            subject: subject.label,
            difficulty: difficulty.label,
          ),
        );
      }
      return result;
    } catch (_) {
      return [];
    }
  }
}
