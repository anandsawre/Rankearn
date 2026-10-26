import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/question_item.dart';

class ImportQuestionsDialog extends StatefulWidget {
  final ValueChanged<List<QuestionItem>> onImport;

  const ImportQuestionsDialog({super.key, required this.onImport});

  @override
  State<ImportQuestionsDialog> createState() => _ImportQuestionsDialogState();
}

class _ImportQuestionsDialogState extends State<ImportQuestionsDialog> {
  final TextEditingController _rawInputController = TextEditingController();
  String _selectedFormat = 'Excel'; // 'Excel', 'CSV' or 'JSON'

  List<QuestionItem> _validQuestions = [];
  List<String> _errors = [];
  bool _isParsed = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadSampleTemplate();
  }

  void _loadSampleTemplate() {
    if (_selectedFormat == 'Excel') {
      _rawInputController.text =
          'question_text\tsubject\tdifficulty\toption_a\toption_b\toption_c\toption_d\tcorrect_answer\texplanation\n'
          'What is the chemical formula of water?\tChemistry\tEasy\tH2O\tCO2\tNaCl\tO2\tA\tWater is composed of two hydrogen atoms and one oxygen atom (H2O).\n'
          'Which planet is known as the Morning Star?\tGeneral Awareness\tEasy\tVenus\tMars\tJupiter\tMercury\tA\tVenus is called the Morning or Evening Star because of its high visibility.\n'
          'If 5x + 3 = 18, find x\tMathematics\tMedium\t2\t3\t4\t5\tB\tSubtracting 3 gives 5x = 15, hence x = 3.\n'
          'Which organelle is the powerhouse of the cell?\tBiology\tEasy\tRibosome\tMitochondria\tNucleus\tLysosome\tB\tMitochondria produce cellular ATP through cellular respiration.';
    } else if (_selectedFormat == 'CSV') {
      _rawInputController.text =
          'question_text,subject,difficulty,option_a,option_b,option_c,option_d,correct_answer,explanation\n'
          '"What is the chemical formula of water?",Chemistry,Easy,H2O,CO2,NaCl,O2,A,"Water is composed of two hydrogen atoms and one oxygen atom (H2O)."\n'
          '"Which planet is known as the Morning Star?",General Awareness,Easy,Venus,Mars,Jupiter,Mercury,A,"Venus is called the Morning or Evening Star because of its high visibility."\n'
          '"If 5x + 3 = 18, find x",Mathematics,Medium,2,3,4,5,B,"Subtracting 3 gives 5x = 15, hence x = 3."\n'
          '"Which organelle is the powerhouse of the cell?",Biology,Easy,Ribosome,Mitochondria,Nucleus,Lysosome,B,"Mitochondria produce cellular ATP through cellular respiration."';
    } else {
      _rawInputController.text = const JsonEncoder.withIndent('  ').convert([
        {
          "question_text": "What is the capital city of Japan?",
          "subject": "General Awareness",
          "difficulty": "Easy",
          "options": [
            {"label": "A", "text": "Seoul"},
            {"label": "B", "text": "Tokyo"},
            {"label": "C", "text": "Beijing"},
            {"label": "D", "text": "Bangkok"}
          ],
          "correct_answer": "B",
          "explanation": "Tokyo is the capital and largest city of Japan."
        },
        {
          "question_text": "If 5x + 3 = 18, find the value of x.",
          "subject": "Mathematics",
          "difficulty": "Medium",
          "options": [
            {"label": "A", "text": "2"},
            {"label": "B", "text": "3"},
            {"label": "C", "text": "4"},
            {"label": "D", "text": "5"}
          ],
          "correct_answer": "B",
          "explanation": "Subtracting 3 gives 5x = 15, therefore x = 3."
        },
        {
          "question_text": "What is the chemical symbol for Gold?",
          "subject": "Chemistry",
          "difficulty": "Easy",
          "options": [
            {"label": "A", "text": "Ag"},
            {"label": "B", "text": "Au"},
            {"label": "C", "text": "Fe"},
            {"label": "D", "text": "Pb"}
          ],
          "correct_answer": "B",
          "explanation": "Au comes from the Latin word 'Aurum', meaning shining dawn."
        }
      ]);
    }

    _parseData();
  }

  void _parseData() {
    final raw = _rawInputController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _errors = ['Please paste or enter data to import.'];
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
              errorList.add('Item #${i + 1} is not a valid JSON object.');
              continue;
            }
            final map = Map<String, dynamic>.from(obj);
            final qText = map['question_text'] ?? map['question_text_english'] ?? '';
            if (qText.toString().trim().isEmpty) {
              errorList.add('Item #${i + 1} has empty question text.');
              continue;
            }
            validList.add(QuestionItem.fromMap(map, i + 1));
          }
        }
      } catch (e) {
        errorList.add('JSON Parsing Error: $e');
      }
    } else {
      // Parse Excel (TSV) or CSV with intelligent header mapping
      final delimiter = (_selectedFormat == 'Excel' || raw.contains('\t')) ? '\t' : ',';
      final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

      if (lines.length <= 1) {
        errorList.add('Data must contain a header row and at least one question row.');
      } else {
        final headerParts = _parseCsvLine(lines[0], delimiter: delimiter)
            .map((h) => h.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_').trim())
            .toList();

        int findCol(List<String> aliases, int fallback) {
          for (final a in aliases) {
            final idx = headerParts.indexWhere((h) => h == a || h.contains(a));
            if (idx >= 0) return idx;
          }
          return fallback;
        }

        final qCol = findCol(['question_text', 'question', 'text', 'q'], 0);
        final subCol = findCol(['subject'], 1);
        final diffCol = findCol(['difficulty', 'diff', 'level'], 2);
        final aCol = findCol(['option_a', 'opt_a', 'opt1', 'a'], 3);
        final bCol = findCol(['option_b', 'opt_b', 'opt2', 'b'], 4);
        final cCol = findCol(['option_c', 'opt_c', 'opt3', 'c'], 5);
        final dCol = findCol(['option_d', 'opt_d', 'opt4', 'd'], 6);
        final ansCol = findCol(['correct_answer', 'correct', 'answer', 'ans'], 7);
        final expCol = findCol(['explanation', 'solution', 'reason', 'exp'], 8);

        for (int i = 1; i < lines.length; i++) {
          final line = lines[i];
          final parts = _parseCsvLine(line, delimiter: delimiter);
          if (parts.isEmpty) continue;

          String getPart(int idx) => idx >= 0 && idx < parts.length ? parts[idx].trim() : '';

          final qText = getPart(qCol);
          if (qText.isEmpty) {
            errorList.add('Row #$i: Question text is empty.');
            continue;
          }

          final subject = getPart(subCol).isNotEmpty ? getPart(subCol) : 'General Awareness';
          final difficulty = getPart(diffCol).isNotEmpty ? getPart(diffCol) : 'Easy';
          final optA = getPart(aCol).isNotEmpty ? getPart(aCol) : 'Option A';
          final optB = getPart(bCol).isNotEmpty ? getPart(bCol) : 'Option B';
          final optC = getPart(cCol).isNotEmpty ? getPart(cCol) : 'Option C';
          final optD = getPart(dCol).isNotEmpty ? getPart(dCol) : 'Option D';
          final correctChar = getPart(ansCol).toUpperCase();
          final explanation = getPart(expCol);

          final labels = ['A', 'B', 'C', 'D'];
          final cIdx = labels.indexOf(correctChar);

          validList.add(
            QuestionItem(
              id: 'imp-${DateTime.now().millisecondsSinceEpoch}-$i',
              questionNumber: i,
              questionText: qText,
              subject: subject,
              testSeriesTitle: 'Practice Series',
              questionType: 'MCQ',
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

  List<String> _parseCsvLine(String line, {String delimiter = ','}) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == delimiter && !inQuotes) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    if (isMobile) {
      return Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5636F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Import Questions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101A3A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
          ),
          body: _buildBody(true),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5636F5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: _isImporting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_rounded, size: 16),
                      label: Text(
                        _validQuestions.isNotEmpty
                            ? 'Confirm Import (${_validQuestions.length} Items)'
                            : 'Confirm Import',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: _validQuestions.isNotEmpty && !_isImporting ? _confirmImport : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: (MediaQuery.of(context).size.height * 0.90).clamp(450.0, 720.0),
        ),
        child: Container(
          width: 720,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5636F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Import Questions (Excel / CSV / JSON)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101A3A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Content
              Expanded(
                child: _buildBody(false),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5636F5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: _isImporting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_rounded, size: 16),
                      label: Text(
                        _validQuestions.isNotEmpty
                            ? 'Confirm Import (${_validQuestions.length} Items)'
                            : 'Confirm Import',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      onPressed: _validQuestions.isNotEmpty && !_isImporting ? _confirmImport : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Controls: Format Switch + Load Template
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              const Text(
                'File Format:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
              ),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFFEEF2FF),
                  selectedForegroundColor: const Color(0xFF5636F5),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                segments: const [
                  ButtonSegment(value: 'Excel', label: Text('Excel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  ButtonSegment(value: 'CSV', label: Text('CSV', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  ButtonSegment(value: 'JSON', label: Text('JSON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                ],
                selected: {_selectedFormat},
                onSelectionChanged: (set) {
                  setState(() {
                    _selectedFormat = set.first;
                  });
                  _loadSampleTemplate();
                },
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.description_outlined, size: 14, color: Color(0xFF5636F5)),
                label: const Text(
                  'Load Sample Template',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5636F5)),
                ),
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
              hintText: _selectedFormat == 'Excel'
                  ? 'Paste Excel spreadsheet rows here (columns: question_text, subject, difficulty, option_a, option_b, option_c, option_d, correct_answer, explanation)'
                  : (_selectedFormat == 'CSV'
                      ? 'Paste CSV content here with header: question_text,subject,difficulty,option_a,option_b,option_c,option_d,correct_answer,explanation'
                      : 'Paste JSON array of questions here...'),
              hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Parse Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.analytics_outlined, size: 16),
            label: const Text('Validate & Parse Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Text('${i + 1}.', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF101A3A))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validQuestions[i].questionText,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _validQuestions[i].subject,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }
}
