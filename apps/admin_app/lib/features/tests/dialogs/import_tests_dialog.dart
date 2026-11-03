import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';

class ImportTestsDialog extends StatefulWidget {
  final List<TestSeriesItem> existingTests;
  final ValueChanged<List<TestSeriesItem>> onImportTests;

  const ImportTestsDialog({
    super.key,
    required this.existingTests,
    required this.onImportTests,
  });

  @override
  State<ImportTestsDialog> createState() => _ImportTestsDialogState();
}

class _ImportTestsDialogState extends State<ImportTestsDialog> {
  final TextEditingController _rawInputController = TextEditingController();
  String _selectedFormat = 'CSV'; // 'Excel', 'CSV', 'JSON'
  String _targetExam = 'rrb_alp';

  List<TestSeriesItem> _parsedTests = [];
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _loadSampleTemplate();
  }

  void _loadSampleTemplate() {
    if (_selectedFormat == 'CSV') {
      _rawInputController.text =
          'title,subject,topic,duration_minutes,total_questions,price_inr,status\n'
          '"RRB ALP Basic Science & Engg Mock 01",Basic Science & Engg,Levers & Pulleys,60,75,0,published\n'
          '"RRB Technician Physics Special 02",General Science,Electricity & Magnetism,45,50,0,published\n'
          '"SSC CGL Tier 1 Full Practice Paper 04",General Awareness,Modern Indian History,60,100,50,published\n'
          '"BPSC Civil Services General Studies Paper",General Studies,Bihar History & Economy,120,150,0,draft';
    } else if (_selectedFormat == 'Excel') {
      _rawInputController.text =
          'title\tsubject\ttopic\tduration_minutes\ttotal_questions\tprice_inr\tstatus\n'
          'RRB ALP Basic Science & Engg Mock 01\tBasic Science & Engg\tLevers & Pulleys\t60\t75\t0\tpublished\n'
          'RRB Technician Physics Special 02\tGeneral Science\tElectricity & Magnetism\t45\t50\t0\tpublished\n'
          'SSC CGL Tier 1 Full Practice Paper 04\tGeneral Awareness\tModern Indian History\t60\t100\t50\tpublished';
    } else {
      _rawInputController.text = const JsonEncoder.withIndent('  ').convert([
        {
          "title": "RRB ALP Basic Science & Engg Mock 01",
          "subject": "Basic Science & Engg",
          "topic": "Levers & Pulleys",
          "duration_minutes": 60,
          "total_questions": 75,
          "price_inr": 0,
          "status": "published"
        },
        {
          "title": "RRB Technician Physics Special 02",
          "subject": "General Science",
          "topic": "Electricity & Magnetism",
          "duration_minutes": 45,
          "total_questions": 50,
          "price_inr": 0,
          "status": "published"
        }
      ]);
    }
  }

  void _parseData() {
    setState(() {
      _parseError = null;
      _parsedTests.clear();
    });

    final text = _rawInputController.text.trim();
    if (text.isEmpty) {
      setState(() => _parseError = 'Please paste import data first.');
      return;
    }

    try {
      final List<TestSeriesItem> results = [];
      if (_selectedFormat == 'JSON') {
        final dynamic decoded = jsonDecode(text);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              results.add(_mapToTestItem(item));
            }
          }
        }
      } else {
        // Delimited (CSV or Tab)
        final isTab = _selectedFormat == 'Excel';
        final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
        if (lines.length > 1) {
          for (int i = 1; i < lines.length; i++) {
            final row = _parseDelimitedLine(lines[i], isTab ? '\t' : ',');
            if (row.length >= 4) {
              results.add(TestSeriesItem(
                id: 'imp_${DateTime.now().microsecondsSinceEpoch}_$i',
                title: row[0],
                description: 'Bulk imported test paper for $_targetExam',
                examCategoryId: _targetExam,
                totalTests: 1,
                totalQuestions: int.tryParse(row.length > 4 ? row[4] : '50') ?? 50,
                durationMinutes: int.tryParse(row.length > 3 ? row[3] : '60') ?? 60,
                negativeMarking: 0.33,
                priceInr: int.tryParse(row.length > 5 ? row[5] : '0') ?? 0,
                entryFeeCoins: 0,
                enrollments: 0,
                status: (row.length > 6 && row[6].toLowerCase().contains('draft'))
                    ? TestSeriesStatus.draft
                    : TestSeriesStatus.published,
                testMode: 'mock',
                subject: row.length > 1 ? row[1] : 'General Science',
                topic: row.length > 2 ? row[2] : 'Complete Syllabus',
                createdAt: DateTime.now(),
                icon: Icons.description_outlined,
                iconColor: const Color(0xFFFF9500),
              ));
            }
          }
        }
      }

      if (results.isEmpty) {
        setState(() => _parseError = 'Could not parse any valid test papers from the provided text.');
      } else {
        setState(() => _parsedTests = results);
      }
    } catch (e) {
      setState(() => _parseError = 'Parsing error: $e');
    }
  }

  TestSeriesItem _mapToTestItem(Map<String, dynamic> m) {
    return TestSeriesItem(
      id: 'imp_${DateTime.now().microsecondsSinceEpoch}',
      title: m['title']?.toString() ?? 'Imported Test',
      description: m['description']?.toString() ?? 'Imported test paper',
      examCategoryId: _targetExam,
      totalTests: 1,
      totalQuestions: (m['total_questions'] as num?)?.toInt() ?? 50,
      durationMinutes: (m['duration_minutes'] as num?)?.toInt() ?? 60,
      negativeMarking: (m['negative_marking'] as num?)?.toDouble() ?? 0.33,
      priceInr: (m['price_inr'] as num?)?.toInt() ?? 0,
      entryFeeCoins: 0,
      enrollments: 0,
      status: (m['status']?.toString() == 'draft') ? TestSeriesStatus.draft : TestSeriesStatus.published,
      testMode: m['test_mode']?.toString() ?? 'mock',
      subject: m['subject']?.toString() ?? 'General Science',
      topic: m['topic']?.toString() ?? 'General',
      createdAt: DateTime.now(),
      icon: Icons.description_outlined,
      iconColor: const Color(0xFFFF9500),
    );
  }

  List<String> _parseDelimitedLine(String line, String sep) {
    final values = <String>[];
    final sb = StringBuffer();
    bool inQuote = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuote = !inQuote;
      } else if (ch == sep && !inQuote) {
        values.add(sb.toString().trim());
        sb.clear();
      } else {
        sb.write(ch);
      }
    }
    values.add(sb.toString().trim());
    return values;
  }

  void _submit() {
    if (_parsedTests.isEmpty) return;
    widget.onImportTests(_parsedTests);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Import Tests & Papers',
      subtitle: 'Bulk import test papers from Excel, CSV or JSON datasets',
      iconData: Icons.cloud_upload_outlined,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 680,
      scrollable: true,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: _parsedTests.isNotEmpty ? _submit : null,
          child: Text(
            _parsedTests.isNotEmpty ? 'Import ${_parsedTests.length} Tests' : 'Import Tests',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Target Exam & Format Selector
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Exam *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _targetExam,
                      items: const [
                        AppDropdownItem(value: 'rrb_alp', label: '🚂 RRB ALP & Technician'),
                        AppDropdownItem(value: 'ssc_cgl', label: '🏛️ SSC CGL Tier 1'),
                        AppDropdownItem(value: 'bpsc_pre', label: '📘 BPSC Civil Services'),
                        AppDropdownItem(value: 'general', label: '🎯 General Competitive'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _targetExam = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data Format *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _selectedFormat,
                      items: const [
                        AppDropdownItem(value: 'CSV', label: '📄 CSV (Comma Separated)'),
                        AppDropdownItem(value: 'Excel', label: '📊 Excel / TSV (Tab Separated)'),
                        AppDropdownItem(value: 'JSON', label: '📦 Structured JSON'),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedFormat = val;
                            _loadSampleTemplate();
                            _parsedTests.clear();
                            _parseError = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Raw Input Area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Raw Dataset / Paste Content', style: _labelStyle),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Reset Sample Template', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _loadSampleTemplate();
                  setState(() {
                    _parsedTests.clear();
                    _parseError = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _rawInputController,
            maxLines: 7,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Color(0xFF1E293B)),
            decoration: AppModalDialog.inputDecoration(
              'Paste formatted CSV or JSON data here...',
              focusColor: const Color(0xFFFF9500),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),

          // Action button to parse
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              onPressed: _parseData,
              icon: const Icon(Icons.bolt_rounded, size: 16),
              label: const Text('Parse & Preview Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),

          if (_parseError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_parseError!, style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C))),
                  ),
                ],
              ),
            ),
          ],

          // Preview table
          if (_parsedTests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Parsed Test Papers Preview (${_parsedTests.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF334155)),
                      ),
                      const Text(
                        'Ready to import',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _parsedTests.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (ctx, idx) {
                      final item = _parsedTests[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.durationMinutes}m • ${item.totalQuestions} MCQs',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
}
