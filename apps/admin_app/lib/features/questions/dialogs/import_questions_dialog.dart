import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';

class ImportQuestionsDialog extends StatefulWidget {
  final ValueChanged<List<QuestionItem>> onImport;

  const ImportQuestionsDialog({super.key, required this.onImport});

  @override
  State<ImportQuestionsDialog> createState() => _ImportQuestionsDialogState();
}

class _ImportQuestionsDialogState extends State<ImportQuestionsDialog> {
  final TextEditingController _rawInputController = TextEditingController();
  String _selectedFormat = 'CSV'; // 'CSV' or 'JSON'

  List<QuestionItem> _validQuestions = [];
  List<String> _errors = [];
  bool _isParsed = false;
  bool _isImporting = false;

  void _loadSampleTemplate() {
    if (_selectedFormat == 'CSV') {
      _rawInputController.text =
          '''question_text,subject,test_series,type,difficulty,option_a,option_b,option_c,option_d,correct_answer,explanation
"What is the chemical formula of water?",Chemistry,"RRB Technician Grade 3",MCQ,Easy,"H2O","CO2","NaCl","O2",A,"Water is composed of two hydrogen atoms and one oxygen atom."
"Which planet is known as the Morning Star?",General Awareness,"Current Affairs Practice Series",MCQ,Easy,"Venus","Mars","Jupiter","Mercury",A,"Venus is called the Morning or Evening Star because of its visibility before sunrise or after sunset."
"If 5x + 3 = 18, find x",Mathematics,"Railway Maths Practice Series",MCQ,Medium,"2","3","4","5",B,"Subtracting 3 gives 5x = 15, hence x = 3."
"Which organelle is the powerhouse of the cell?",Biology,"Biology Marathon Series",MCQ,Easy,"Ribosome","Mitochondria","Nucleus","Lysosome",B,"Mitochondria produce cellular ATP through respiration."''';
    } else {
      _rawInputController.text = jsonEncode([
        {
          "question_text": "What is the capital of Japan?",
          "subject": "General Awareness",
          "test_series": "Current Affairs Practice Series",
          "type": "MCQ",
          "difficulty": "Easy",
          "options": [
            {"label": "A", "text": "Seoul"},
            {"label": "B", "text": "Tokyo"},
            {"label": "C", "text": "Beijing"},
            {"label": "D", "text": "Bangkok"}
          ],
          "correct_answer": "B",
          "explanation": "Tokyo is the capital city of Japan."
        },
        {
          "question_text": "Solve: 15% of 200",
          "subject": "Mathematics",
          "test_series": "Railway Maths Practice Series",
          "type": "MCQ",
          "difficulty": "Easy",
          "options": [
            {"label": "A", "text": "25"},
            {"label": "B", "text": "30"},
            {"label": "C", "text": "35"},
            {"label": "D", "text": "40"}
          ],
          "correct_answer": "B",
          "explanation": "15/100 * 200 = 30."
        }
      ]);
    }
    setState(() {
      _isParsed = false;
      _errors.clear();
      _validQuestions.clear();
    });
  }

  void _parseData() {
    final raw = _rawInputController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _errors = ['Please paste or enter CSV/JSON content to import.'];
        _validQuestions.clear();
        _isParsed = true;
      });
      return;
    }

    final validList = <QuestionItem>[];
    final errorList = <String>[];

    if (_selectedFormat == 'JSON') {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! List) {
          errorList.add('JSON must be an array of question objects.');
        } else {
          for (int i = 0; i < decoded.length; i++) {
            final obj = decoded[i];
            if (obj is! Map) {
              errorList.add('Item #$i is not a valid JSON object.');
              continue;
            }
            final map = Map<String, dynamic>.from(obj);
            final qText = map['question_text'] ?? map['question_text_english'] ?? '';
            if (qText.toString().trim().isEmpty) {
              errorList.add('Item #$i has empty question text.');
              continue;
            }
            validList.add(QuestionItem.fromMap(map, i + 1));
          }
        }
      } catch (e) {
        errorList.add('JSON Parsing Error: $e');
      }
    } else {
      // Parse CSV
      final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.length <= 1) {
        errorList.add('CSV must contain a header row and at least one data row.');
      } else {
        // Skip header
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i];
          final parts = _parseCsvLine(line);
          if (parts.length < 10) {
            errorList.add(
                'Row #$i: Insufficient columns (${parts.length}/10 expected).');
            continue;
          }

          final qText = parts[0];
          final subject = parts[1];
          final testSeries = parts[2];
          final type = parts[3];
          final difficulty = parts[4];
          final optA = parts[5];
          final optB = parts[6];
          final optC = parts[7];
          final optD = parts[8];
          final correctChar = parts[9].toUpperCase().trim();
          final explanation = parts.length > 10 ? parts[10] : '';

          if (qText.isEmpty) {
            errorList.add('Row #$i: Question text cannot be empty.');
            continue;
          }

          final labels = ['A', 'B', 'C', 'D'];
          final cIdx = labels.indexOf(correctChar);

          validList.add(
            QuestionItem(
              id: 'imp-${DateTime.now().millisecondsSinceEpoch}-$i',
              questionNumber: i,
              questionText: qText,
              subject: subject.isNotEmpty ? subject : 'General Awareness',
              testSeriesTitle: testSeries.isNotEmpty ? testSeries : 'Practice Series',
              questionType: type.isNotEmpty ? type : 'MCQ',
              difficulty: QuestionDifficulty.fromString(difficulty),
              correctAnswerIndex: cIdx >= 0 ? cIdx : 0,
              correctAnswerChar: correctChar.isNotEmpty ? correctChar : 'A',
              usageCount: 0,
              status: QuestionStatus.published,
              createdAt: DateTime.now(),
              options: [
                QuestionOptionItem(label: 'A', text: optA),
                QuestionOptionItem(label: 'B', text: optB),
                QuestionOptionItem(label: 'C', text: optC),
                QuestionOptionItem(label: 'D', text: optD),
              ],
              explanation: explanation.isNotEmpty ? explanation : null,
            ),
          );
        }
      }
    }

    setState(() {
      _validQuestions = validList;
      _errors = errorList;
      _isParsed = true;
    });
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }

  void _confirmImport() {
    if (_validQuestions.isEmpty) return;
    setState(() => _isImporting = true);

    widget.onImport(_validQuestions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.file_upload_outlined, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Import Questions (CSV / JSON)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Controls: Format Switch + Load Template
                    Row(
                      children: [
                        const Text(
                          'File Format:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        const SizedBox(width: 10),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'CSV', label: Text('CSV', style: TextStyle(fontSize: 11))),
                            ButtonSegment(value: 'JSON', label: Text('JSON', style: TextStyle(fontSize: 11))),
                          ],
                          selected: {_selectedFormat},
                          onSelectionChanged: (set) {
                            setState(() {
                              _selectedFormat = set.first;
                              _isParsed = false;
                            });
                          },
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.description_outlined, size: 14, color: Color(0xFF0284C7)),
                          label: const Text('Load Sample Template', style: TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                          onPressed: _loadSampleTemplate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Input Textarea
                    Text(
                      'Paste $_selectedFormat Data',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _rawInputController,
                      maxLines: 8,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: _selectedFormat == 'CSV'
                            ? 'Paste CSV content here with header: question_text,subject,test_series,type,difficulty,option_a,option_b,option_c,option_d,correct_answer,explanation'
                            : 'Paste JSON array of questions here...',
                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Parse Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.analytics_outlined, size: 16),
                      label: const Text('Validate & Parse Data'),
                      onPressed: _parseData,
                    ),

                    if (_isParsed) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 10),

                      // Validation Summary
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_validQuestions.length} Valid Records',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_errors.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE4E6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_errors.length} Errors Found',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE11D48)),
                              ),
                            ),
                        ],
                      ),

                      // Errors display
                      if (_errors.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _errors
                                .map((e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.error_outline, size: 13, color: Colors.red),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              e,
                                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF9F1239)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],

                      // Valid items preview list
                      if (_validQuestions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Previewing Valid Records:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        for (int i = 0; i < _validQuestions.length; i++) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Text('${i + 1}.', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _validQuestions[i].questionText,
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _validQuestions[i].subject,
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Ans: ${_validQuestions[i].correctAnswerChar}',
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: _isImporting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_rounded, size: 16),
                    label: Text('Confirm Import (${_validQuestions.length} Items)'),
                    onPressed: _validQuestions.isNotEmpty && !_isImporting ? _confirmImport : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
