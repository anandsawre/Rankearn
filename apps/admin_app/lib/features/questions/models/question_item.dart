import 'package:flutter/material.dart';

enum QuestionStatus {
  published('Published'),
  draft('Draft'),
  archived('Archived');

  final String label;
  const QuestionStatus(this.label);

  static QuestionStatus fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'published':
        return QuestionStatus.published;
      case 'draft':
        return QuestionStatus.draft;
      case 'archived':
        return QuestionStatus.archived;
      default:
        return QuestionStatus.published;
    }
  }
}

enum QuestionDifficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard'),
  expert('Expert');

  final String label;
  const QuestionDifficulty(this.label);

  static QuestionDifficulty fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'easy':
        return QuestionDifficulty.easy;
      case 'medium':
      case 'moderate':
        return QuestionDifficulty.medium;
      case 'hard':
        return QuestionDifficulty.hard;
      case 'expert':
        return QuestionDifficulty.expert;
      default:
        return QuestionDifficulty.medium;
    }
  }
}

class QuestionOptionItem {
  final String label; // 'A', 'B', 'C', 'D'
  final String text;

  const QuestionOptionItem({required this.label, required this.text});

  factory QuestionOptionItem.fromMap(Map<String, dynamic> map, int index) {
    final defaultLabels = ['A', 'B', 'C', 'D', 'E', 'F'];
    final label = map['label']?.toString() ??
        (index < defaultLabels.length ? defaultLabels[index] : '$index');
    final text = map['text']?.toString() ??
        map['textEnglish']?.toString() ??
        map['text_english']?.toString() ??
        '';
    return QuestionOptionItem(label: label, text: text);
  }

  Map<String, dynamic> toMap() => {'label': label, 'text': text};
}

class QuestionItem {
  final String id;
  final int questionNumber;
  final String questionText;
  final String? questionTextHindi;
  final String subject;
  final String testSeriesTitle;
  final String? testId;
  final String questionSet;
  final String questionType;
  final QuestionDifficulty difficulty;
  final List<QuestionOptionItem> options;
  final int correctAnswerIndex;
  final String correctAnswerChar;
  final int usageCount;
  final QuestionStatus status;
  final DateTime createdAt;
  final String? explanation;
  final double marks;
  final double negativeMarks;
  final List<String> tags;
  bool isSelected;

  QuestionItem({
    required this.id,
    required this.questionNumber,
    required this.questionText,
    this.questionTextHindi,
    required this.subject,
    required this.testSeriesTitle,
    this.testId,
    this.questionSet = 'Set A',
    this.questionType = 'MCQ',
    required this.difficulty,
    required this.options,
    required this.correctAnswerIndex,
    required this.correctAnswerChar,
    required this.usageCount,
    required this.status,
    required this.createdAt,
    this.explanation,
    this.marks = 1.0,
    this.negativeMarks = 0.25,
    this.tags = const [],
    this.isSelected = false,
  });

  QuestionItem copyWith({
    String? id,
    int? questionNumber,
    String? questionText,
    String? questionTextHindi,
    String? subject,
    String? testSeriesTitle,
    String? testId,
    String? questionSet,
    String? questionType,
    QuestionDifficulty? difficulty,
    List<QuestionOptionItem>? options,
    int? correctAnswerIndex,
    String? correctAnswerChar,
    int? usageCount,
    QuestionStatus? status,
    DateTime? createdAt,
    String? explanation,
    double? marks,
    double? negativeMarks,
    List<String>? tags,
    bool? isSelected,
  }) {
    return QuestionItem(
      id: id ?? this.id,
      questionNumber: questionNumber ?? this.questionNumber,
      questionText: questionText ?? this.questionText,
      questionTextHindi: questionTextHindi ?? this.questionTextHindi,
      subject: subject ?? this.subject,
      testSeriesTitle: testSeriesTitle ?? this.testSeriesTitle,
      testId: testId ?? this.testId,
      questionSet: questionSet ?? this.questionSet,
      questionType: questionType ?? this.questionType,
      difficulty: difficulty ?? this.difficulty,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      correctAnswerChar: correctAnswerChar ?? this.correctAnswerChar,
      usageCount: usageCount ?? this.usageCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      explanation: explanation ?? this.explanation,
      marks: marks ?? this.marks,
      negativeMarks: negativeMarks ?? this.negativeMarks,
      tags: tags ?? this.tags,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory QuestionItem.fromMap(Map<String, dynamic> map, [int defaultNumber = 1]) {
    final rawOptions = map['options'];
    final List<QuestionOptionItem> parsedOpts = [];
    if (rawOptions is List) {
      for (int i = 0; i < rawOptions.length; i++) {
        final opt = rawOptions[i];
        if (opt is Map<String, dynamic>) {
          parsedOpts.add(QuestionOptionItem.fromMap(opt, i));
        } else if (opt is Map) {
          parsedOpts.add(QuestionOptionItem.fromMap(Map<String, dynamic>.from(opt), i));
        } else if (opt is String) {
          final defaultLabels = ['A', 'B', 'C', 'D', 'E', 'F'];
          final lbl = i < defaultLabels.length ? defaultLabels[i] : '$i';
          parsedOpts.add(QuestionOptionItem(label: lbl, text: opt));
        }
      }
    }

    final cIdx = (map['correct_answer'] as num?)?.toInt() ?? 0;
    final defaultLabels = ['A', 'B', 'C', 'D'];
    final cChar = map['correct_answer_char']?.toString() ??
        (cIdx < defaultLabels.length ? defaultLabels[cIdx] : 'A');

    DateTime dt = DateTime.now();
    if (map['created_at'] != null) {
      dt = DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now();
    }

    return QuestionItem(
      id: map['id']?.toString() ?? 'q-${DateTime.now().millisecondsSinceEpoch}',
      questionNumber: (map['question_number'] as num?)?.toInt() ?? defaultNumber,
      questionText: map['question_text_english']?.toString() ??
          map['question_text']?.toString() ??
          map['text']?.toString() ??
          'Untitled Question',
      questionTextHindi: map['question_text_hindi']?.toString(),
      subject: map['subject']?.toString() ?? 'General Awareness',
      testSeriesTitle: map['test_series_title']?.toString() ??
          map['test_title']?.toString() ??
          'Practice Series',
      testId: map['test_id']?.toString(),
      questionSet: map['question_set']?.toString() ?? 'Set A',
      questionType: map['question_type']?.toString() ?? 'MCQ',
      difficulty: QuestionDifficulty.fromString(map['difficulty_level']?.toString() ?? 'medium'),
      options: parsedOpts,
      correctAnswerIndex: cIdx,
      correctAnswerChar: cChar,
      usageCount: (map['usage_count'] as num?)?.toInt() ?? 0,
      status: QuestionStatus.fromString(map['status']?.toString() ?? 'published'),
      createdAt: dt,
      explanation: map['explanation_english']?.toString() ?? map['explanation']?.toString(),
      marks: (map['marks'] as num?)?.toDouble() ?? 1.0,
      negativeMarks: (map['negative_marks'] as num?)?.toDouble() ?? 0.25,
      tags: map['tags'] is List ? List<String>.from(map['tags']) : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_number': questionNumber,
      'question_text_english': questionText,
      'question_text_hindi': questionTextHindi,
      'subject': subject,
      'test_series_title': testSeriesTitle,
      'test_id': testId,
      'question_set': questionSet,
      'question_type': questionType,
      'difficulty_level': difficulty.label,
      'options': options.map((o) => o.toMap()).toList(),
      'correct_answer': correctAnswerIndex,
      'correct_answer_char': correctAnswerChar,
      'usage_count': usageCount,
      'status': status.name,
      'explanation_english': explanation,
      'marks': marks,
      'negative_marks': negativeMarks,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Visual Styling Helpers matching reference screenshot exactly
  Color get subjectBgColor {
    final lower = subject.toLowerCase();
    if (lower.contains('physics')) return const Color(0xFFEEF2FF);
    if (lower.contains('general') || lower.contains('awareness')) return const Color(0xFFFFF7ED);
    if (lower.contains('math')) return const Color(0xFFFFF1F2);
    if (lower.contains('chem')) return const Color(0xFFFDF2F8);
    if (lower.contains('bio')) return const Color(0xFFF0FDF4);
    if (lower.contains('reasoning')) return const Color(0xFFF0F9FF);
    if (lower.contains('polity')) return const Color(0xFFF5F3FF);
    return const Color(0xFFF1F5F9);
  }

  Color get subjectTextColor {
    final lower = subject.toLowerCase();
    if (lower.contains('physics')) return const Color(0xFF6366F1);
    if (lower.contains('general') || lower.contains('awareness')) return const Color(0xFFEA580C);
    if (lower.contains('math')) return const Color(0xFFF43F5E);
    if (lower.contains('chem')) return const Color(0xFFDB2777);
    if (lower.contains('bio')) return const Color(0xFF16A34A);
    if (lower.contains('reasoning')) return const Color(0xFF0284C7);
    if (lower.contains('polity')) return const Color(0xFF7C3AED);
    return const Color(0xFF475569);
  }

  Color get iconContainerBg {
    final lower = subject.toLowerCase();
    if (lower.contains('physics')) return const Color(0xFFF59E0B);
    if (lower.contains('general') || lower.contains('awareness')) return const Color(0xFF0284C7);
    if (lower.contains('math')) return const Color(0xFFF43F5E);
    if (lower.contains('chem')) return const Color(0xFF8B5CF6);
    if (lower.contains('bio')) return const Color(0xFF10B981);
    if (lower.contains('reasoning')) return const Color(0xFFF59E0B);
    if (lower.contains('polity')) return const Color(0xFF2563EB);
    return const Color(0xFF64748B);
  }

  IconData get subjectIcon {
    final lower = subject.toLowerCase();
    if (lower.contains('physics')) return Icons.architecture_rounded;
    if (lower.contains('general') || lower.contains('awareness')) return Icons.public_rounded;
    if (lower.contains('math')) return Icons.calculate_rounded;
    if (lower.contains('chem')) return Icons.science_rounded;
    if (lower.contains('bio')) return Icons.eco_rounded;
    if (lower.contains('reasoning')) return Icons.psychology_rounded;
    if (lower.contains('polity')) return Icons.gavel_rounded;
    return Icons.help_outline_rounded;
  }

  Color get difficultyBgColor {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return const Color(0xFFF0FDF4);
      case QuestionDifficulty.medium:
        return const Color(0xFFFFFBEB);
      case QuestionDifficulty.hard:
        return const Color(0xFFFEF2F2);
      case QuestionDifficulty.expert:
        return const Color(0xFFF5F3FF);
    }
  }

  Color get difficultyTextColor {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return const Color(0xFF16A34A);
      case QuestionDifficulty.medium:
        return const Color(0xFFD97706);
      case QuestionDifficulty.hard:
        return const Color(0xFFDC2626);
      case QuestionDifficulty.expert:
        return const Color(0xFF7C3AED);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case QuestionStatus.published:
        return const Color(0xFFDCFCE7);
      case QuestionStatus.draft:
        return const Color(0xFFEFF6FF);
      case QuestionStatus.archived:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get statusTextColor {
    switch (status) {
      case QuestionStatus.published:
        return const Color(0xFF16A34A);
      case QuestionStatus.draft:
        return const Color(0xFF3B82F6);
      case QuestionStatus.archived:
        return const Color(0xFF64748B);
    }
  }

  // Exact reference data from the specification screenshot
  static List<QuestionItem> get referenceData => [
        QuestionItem(
          id: 'q-001',
          questionNumber: 1,
          questionText: 'What is the SI unit of force?',
          subject: 'Physics',
          testSeriesTitle: 'RRB Technician\nGrade 3',
          questionType: 'MCQ',
          difficulty: QuestionDifficulty.easy,
          correctAnswerIndex: 1,
          correctAnswerChar: 'B',
          usageCount: 1245,
          status: QuestionStatus.published,
          createdAt: DateTime(2026, 10, 18),
          options: const [
            QuestionOptionItem(label: 'A', text: 'Joule'),
            QuestionOptionItem(label: 'B', text: 'Newton'),
            QuestionOptionItem(label: 'C', text: 'Pascal'),
            QuestionOptionItem(label: 'D', text: 'Watt'),
          ],
          explanation: 'Newton (N) is the SI unit of force, named after Sir Isaac Newton.',
        ),
        QuestionItem(
          id: 'q-002',
          questionNumber: 2,
          questionText: 'The capital of Australia is?',
          subject: 'General Awareness',
          testSeriesTitle: 'Current Affairs\nPractice Series',
          questionType: 'MCQ',
          difficulty: QuestionDifficulty.easy,
          correctAnswerIndex: 2,
          correctAnswerChar: 'C',
          usageCount: 892,
          status: QuestionStatus.published,
          createdAt: DateTime(2026, 10, 17),
          options: const [
            QuestionOptionItem(label: 'A', text: 'Sydney'),
            QuestionOptionItem(label: 'B', text: 'Melbourne'),
            QuestionOptionItem(label: 'C', text: 'Canberra'),
            QuestionOptionItem(label: 'D', text: 'Brisbane'),
          ],
          explanation: 'Canberra is the federal capital city of the Commonwealth of Australia.',
        ),
        QuestionItem(
          id: 'q-003',
          questionNumber: 3,
          questionText: 'Find the missing number:\n2, 6, 12, 20, ?',
          subject: 'Mathematics',
          testSeriesTitle: 'Railway Maths\nPractice Series',
          questionType: 'MCQ',
          difficulty: QuestionDifficulty.medium,
          correctAnswerIndex: 3,
          correctAnswerChar: 'D',
          usageCount: 1050,
          status: QuestionStatus.published,
          createdAt: DateTime(2026, 10, 16),
          options: const [
            QuestionOptionItem(label: 'A', text: '26'),
            QuestionOptionItem(label: 'B', text: '28'),
            QuestionOptionItem(label: 'C', text: '29'),
            QuestionOptionItem(label: 'D', text: '30'),
          ],
          explanation: 'Pattern is n^2 + n or consecutive even differences: +4, +6, +8, +10. Next term is 20 + 10 = 30.',
        ),
        QuestionItem(
          id: 'q-004',
          questionNumber: 4,
          questionText: 'Which gas is known as\nlaughing gas?',
          subject: 'Chemistry',
          testSeriesTitle: 'Chemistry Practice\nSeries',
          questionType: 'MCQ',
          difficulty: QuestionDifficulty.medium,
          correctAnswerIndex: 0,
          correctAnswerChar: 'A',
          usageCount: 730,
          status: QuestionStatus.draft,
          createdAt: DateTime(2026, 10, 15),
          options: const [
            QuestionOptionItem(label: 'A', text: 'Nitrous Oxide (N2O)'),
            QuestionOptionItem(label: 'B', text: 'Carbon Monoxide'),
            QuestionOptionItem(label: 'C', text: 'Sulphur Dioxide'),
            QuestionOptionItem(label: 'D', text: 'Methane'),
          ],
          explanation: 'Nitrous oxide (N2O) is commonly known as laughing gas due to its euphoric and anesthetic properties.',
        ),
        QuestionItem(
          id: 'q-005',
          questionNumber: 5,
          questionText: 'Who discovered the cell?',
          subject: 'Biology',
          testSeriesTitle: 'Biology Marathon\nSeries',
          questionType: 'MCQ',
          difficulty: QuestionDifficulty.easy,
          correctAnswerIndex: 1,
          correctAnswerChar: 'B',
          usageCount: 620,
          status: QuestionStatus.published,
          createdAt: DateTime(2026, 10, 14),
          options: const [
            QuestionOptionItem(label: 'A', text: 'Robert Brown'),
            QuestionOptionItem(label: 'B', text: 'Robert Hooke'),
            QuestionOptionItem(label: 'C', text: 'Antonie van Leeuwenhoek'),
            QuestionOptionItem(label: 'D', text: 'Alexander Fleming'),
          ],
          explanation: 'Robert Hooke discovered cells in 1665 by examining thin slices of cork under an early compound microscope.',
        ),
        QuestionItem(
          id: 'q-006',
          questionNumber: 6,
          questionText: 'Select the odd one out:\nTable, Chair, Window, Apple',
          subject: 'Reasoning',
          testSeriesTitle: 'Reasoning Special\nSeries',
          questionType: 'MCQ',
          difficulty: QuestionDifficulty.medium,
          correctAnswerIndex: 3,
          correctAnswerChar: 'D',
          usageCount: 540,
          status: QuestionStatus.published,
          createdAt: DateTime(2026, 10, 13),
          options: const [
            QuestionOptionItem(label: 'A', text: 'Table'),
            QuestionOptionItem(label: 'B', text: 'Chair'),
            QuestionOptionItem(label: 'C', text: 'Window'),
            QuestionOptionItem(label: 'D', text: 'Apple'),
          ],
          explanation: 'Apple is an edible organic fruit, while Table, Chair, and Window are inanimate structural/furniture items.',
        ),
        QuestionItem(
          id: 'q-007',
          questionNumber: 7,
          questionText: 'Which article deals with\nthe Right to Education?',
          subject: 'Polity',
          testSeriesTitle: 'Current Affairs\nMonthly Series',
          questionType: 'MCQ',
          difficulty: QuestionDifficulty.hard,
          correctAnswerIndex: 2,
          correctAnswerChar: 'C',
          usageCount: 480,
          status: QuestionStatus.archived,
          createdAt: DateTime(2026, 10, 12),
          options: const [
            QuestionOptionItem(label: 'A', text: 'Article 19'),
            QuestionOptionItem(label: 'B', text: 'Article 21'),
            QuestionOptionItem(label: 'C', text: 'Article 21A'),
            QuestionOptionItem(label: 'D', text: 'Article 22'),
          ],
          explanation: 'Article 21A was inserted by the 86th Constitutional Amendment Act, providing free and compulsory education for children ages 6 to 14.',
        ),
      ];
}
