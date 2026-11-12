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

  String _buildPrompt({
    required int chunkCount,
    required String exam,
    required String effectiveSubject,
    required String topic,
    required AiTestDifficulty difficulty,
    required String language,
    String? customInstructions,
    int chunkIndex = 0,
    List<String> existingStems = const [],
  }) {
    final avoidBlock = existingStems.isEmpty
        ? ''
        : '\nDo NOT repeat or paraphrase any of these already generated questions:\n- ${existingStems.take(15).join('\n- ')}';
    return '''
$_systemPrompt

Generate EXACTLY $chunkCount unique multiple choice questions for the competitive exam "$exam"${chunkIndex > 0 ? " (Batch ${chunkIndex + 1})" : ""}.
Subject: $effectiveSubject
Topic: $topic
Difficulty: ${difficulty.label}
Language requirement: $language.
${customInstructions != null && customInstructions.isNotEmpty ? "Additional Instructions: $customInstructions" : ""}$avoidBlock

CRITICAL: You MUST return EXACTLY $chunkCount objects in the JSON array — no more, no less.
Output STRICTLY a JSON array of objects with keys:
- "questionText": English question text
- "questionTextHi": Hindi translation of question text
- "options": Array of exactly 4 strings (A, B, C, D)
- "correctOptionIndex": Integer 0 to 3
- "explanation": Detailed explanation
- "explanationHi": Hindi explanation
Return pure JSON array only.
''';
  }

  /// Generate AI Competitive Questions strictly via live AI backends (no fake offline synthesis).
  Future<List<AiTestQuestion>> generateQuestions({
    required String title,
    required String topic,
    required AiTestSubject subject,
    String? subjectLabel,
    required AiTestDifficulty difficulty,
    required int count,
    required String exam,
    required String language,
    String? customInstructions,
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.10, 'Connecting to AI Engine...');

    final effectiveSubject = (subjectLabel != null && subjectLabel.trim().isNotEmpty)
        ? subjectLabel.trim()
        : subject.label;

    const int chunkSize = 20;
    final maxBatches = ((count / chunkSize).ceil() + 3).clamp(3, 12);
    final allGenerated = <AiTestQuestion>[];
    final seenStems = <String>{};
    String? lastError;

    for (int chunkIdx = 0; chunkIdx < maxBatches && allGenerated.length < count; chunkIdx++) {
      final remaining = count - allGenerated.length;
      final currentChunkCount = remaining > chunkSize ? chunkSize : remaining;
      if (currentChunkCount <= 0) break;

      final prompt = _buildPrompt(
        chunkCount: currentChunkCount,
        exam: exam,
        effectiveSubject: effectiveSubject,
        topic: topic,
        difficulty: difficulty,
        language: language,
        customInstructions: customInstructions,
        chunkIndex: chunkIdx,
        existingStems: allGenerated
            .map((q) => q.questionText.replaceAll('\n', ' ').trim())
            .map((s) => s.length > 90 ? '${s.substring(0, 90)}...' : s)
            .toList(),
      );

      List<AiTestQuestion> chunkQuestions = [];
      final baseProgress = 0.12 + (allGenerated.length / count) * 0.78;

      // Attempt 1: Google Gemini API directly when API key is configured
      if (_geminiApiKey.isNotEmpty) {
        try {
          onProgress?.call(
            baseProgress,
            'Generating ${allGenerated.length + 1}-${(allGenerated.length + currentChunkCount).clamp(1, count)} of $count questions via Gemini API...',
          );
          final directUri = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent?key=$_geminiApiKey',
          );

          final directResp = await http
              .post(
                directUri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'contents': [
                    {
                      'role': 'user',
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
              .timeout(const Duration(seconds: 60));

          if (directResp.statusCode == 200) {
            final resJson = jsonDecode(directResp.body);
            final candidates = resJson['candidates'] as List<dynamic>?;
            if (candidates != null && candidates.isNotEmpty) {
              final text = (candidates[0]['content']?['parts']?[0]?['text'] ?? '').toString();
              final clean = _extractJson(text);
              if (clean.isNotEmpty) {
                chunkQuestions = _parseJsonQuestions(clean, subject, difficulty);
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

      // Attempt 2: Cloudflare Edge Worker (matches React Admin protocol)
      if (chunkQuestions.isEmpty && _geminiWorkerUrl.trim().isNotEmpty) {
        try {
          onProgress?.call(
            baseProgress + 0.08,
            'Generating ${allGenerated.length + 1}-${(allGenerated.length + currentChunkCount).clamp(1, count)} of $count questions via Edge Gateway...',
          );
          final workerUri = Uri.parse(_geminiWorkerUrl.trim());
          final response = await http
              .post(
                workerUri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'model': 'gemini-2.5-flash',
                  'contents': [
                    {
                      'role': 'user',
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
                }),
              )
              .timeout(const Duration(seconds: 60));

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            String rawText = '';
            if (body is Map) {
              final candidates = body['candidates'] as List<dynamic>?;
              if (candidates != null && candidates.isNotEmpty) {
                rawText = (candidates[0]['content']?['parts']?[0]?['text'] ?? '').toString();
              } else {
                rawText = (body['text'] ?? body['content'] ?? body['result'] ?? '').toString();
              }
              if (rawText.isEmpty && body['error'] != null) {
                lastError = 'Edge Gateway Gemini error: ${body['error']}';
              }
            }
            final cleanJson = _extractJson(rawText);
            if (cleanJson.isNotEmpty) {
              chunkQuestions = _parseJsonQuestions(cleanJson, subject, difficulty);
            }
            if (chunkQuestions.isEmpty) {
              lastError ??= 'Edge Gateway returned 200 but no valid questions were parsed.';
            }
          } else {
            lastError = 'Edge Gateway returned HTTP ${response.statusCode}: ${response.body}';
          }
        } catch (e) {
          lastError = 'Edge Gateway unreachable: $e';
          debugPrint(lastError);
        }
      }

      // Attempt 3: Supabase Edge Function `gemini-proxy` fallback (if signed in as Admin)
      final client = SupabaseConfig.clientSafe;
      final currentSession = client?.auth.currentSession;
      if (chunkQuestions.isEmpty && client != null && currentSession != null) {
        try {
          var accessToken = currentSession.accessToken;
          if (currentSession.isExpired) {
            try {
              final refreshed = await client.auth.refreshSession();
              accessToken = refreshed.session?.accessToken ?? accessToken;
            } catch (_) {}
          }
          onProgress?.call(
            baseProgress + 0.12,
            'Generating ${allGenerated.length + 1}-${(allGenerated.length + currentChunkCount).clamp(1, count)} of $count questions via Supabase Edge Proxy...',
          );
          final edgeResp = await client.functions.invoke(
            'gemini-proxy',
            headers: {'Authorization': 'Bearer $accessToken'},
            body: {
              'model': 'gemini-flash-lite-latest',
              'contents': [
                {
                  'role': 'user',
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
                final text = (candidates[0]['content']?['parts']?[0]?['text'] ?? '').toString();
                final finishReason = candidates[0]['finishReason']?.toString() ?? '';
                final clean = _extractJson(text);
                if (clean.isNotEmpty) {
                  chunkQuestions = _parseJsonQuestions(clean, subject, difficulty);
                }
                if (chunkQuestions.isEmpty) {
                  lastError =
                      'Supabase gemini-proxy returned ${text.length} chars (finishReason: $finishReason), but no valid MCQ JSON could be parsed.';
                }
              } else {
                lastError = 'Supabase gemini-proxy returned 200 with no candidates: ${data['error'] ?? data}';
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

      if (chunkQuestions.isEmpty) {
        if (allGenerated.isEmpty) {
          throw Exception(
            lastError ??
                'AI generation failed. Configure a Gemini API key in Custom Prompt or verify your Edge Gateway / Supabase gemini-proxy.',
          );
        }
        continue;
      }

      for (final q in chunkQuestions) {
        if (allGenerated.length >= count) break;
        final stemKey = q.questionText.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
        if (stemKey.isEmpty || seenStems.contains(stemKey)) continue;
        seenStems.add(stemKey);
        allGenerated.add(q);
      }
    }

    if (allGenerated.length < count) {
      throw Exception(
        'Generated ${allGenerated.length}/$count unique questions. ${lastError ?? "Please retry to complete all $count questions."}',
      );
    }

    // Renumber sequentially (guaranteed exact count)
    final numbered = allGenerated.take(count).toList().asMap().entries.map((entry) {
      final idx = entry.key;
      final q = entry.value;
      return AiTestQuestion(
        id: 'ai_q_${DateTime.now().millisecondsSinceEpoch}_$idx',
        questionNumber: idx + 1,
        questionText: q.questionText,
        questionTextHi: q.questionTextHi,
        options: q.options,
        correctOptionIndex: q.correctOptionIndex,
        explanation: q.explanation,
        explanationHi: q.explanationHi,
        subject: q.subject,
        difficulty: q.difficulty,
      );
    }).toList();

    onProgress?.call(1.0, 'Generated ${numbered.length} verified questions.');
    return numbered;
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
      'category_id': testItem.displaySubject,
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
    var trimmed = text.trim();
    if (trimmed.startsWith('```')) {
      trimmed = trimmed
          .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    final startArray = trimmed.indexOf('[');
    final endArray = trimmed.lastIndexOf(']');
    if (startArray != -1 && endArray != -1 && endArray > startArray) {
      return trimmed.substring(startArray, endArray + 1);
    }
    if (startArray != -1) {
      return trimmed.substring(startArray);
    }
    final startObj = trimmed.indexOf('{');
    final endObj = trimmed.lastIndexOf('}');
    if (startObj != -1 && endObj != -1 && endObj > startObj) {
      return trimmed.substring(startObj, endObj + 1);
    }
    return trimmed;
  }

  List<AiTestQuestion> _parseJsonQuestions(
    String cleanJson,
    AiTestSubject subject,
    AiTestDifficulty difficulty,
  ) {
    List<dynamic> list = [];
    try {
      final decoded = jsonDecode(cleanJson);
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        final nested = decoded['questions'] ?? decoded['items'] ?? decoded['data'];
        if (nested is List) list = nested;
      }
    } catch (_) {
      // Recover complete JSON objects even if trailing output was truncated
      list = _recoverObjectsFromTruncatedArray(cleanJson);
    }

    final result = <AiTestQuestion>[];
    for (int i = 0; i < list.length; i++) {
      final rawItem = list[i];
      if (rawItem is! Map) continue;
      final qJson = Map<String, dynamic>.from(rawItem);
      final qText = qJson['questionText']?.toString().trim() ?? '';
      if (qText.isEmpty) continue;
      result.add(
        AiTestQuestion(
          id: 'ai_q_${DateTime.now().millisecondsSinceEpoch}_$i',
          questionNumber: result.length + 1,
          questionText: qText,
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
  }

  List<dynamic> _recoverObjectsFromTruncatedArray(String text) {
    final recovered = <dynamic>[];
    var depth = 0;
    var inString = false;
    var escaped = false;
    int? objStart;

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (ch == r'\' && inString) {
        escaped = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (ch == '{') {
        if (depth == 0) objStart = i;
        depth++;
      } else if (ch == '}') {
        if (depth > 0) depth--;
        if (depth == 0 && objStart != null) {
          final slice = text.substring(objStart, i + 1);
          try {
            final parsed = jsonDecode(slice);
            if (parsed is Map) recovered.add(parsed);
          } catch (_) {}
          objStart = null;
        }
      }
    }
    return recovered;
  }
}
