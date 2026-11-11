import 'dart:math' as math;
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

  Map<String, dynamic> toMap() => {
        'label': label,
        'text': text,
        'textEnglish': text,
        'text_english': text,
      };
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

  factory QuestionItem.fromMap(
    Map<String, dynamic> map, [
    int defaultNumber = 1,
    String? resolvedTestTitle,
    QuestionStatus? derivedStatus,
  ]) {
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
    } else {
      // Check for flat option_a, option_b, option_c, option_d keys
      for (final lbl in ['A', 'B', 'C', 'D']) {
        final key = 'option_${lbl.toLowerCase()}';
        if (map[key] != null && map[key].toString().isNotEmpty) {
          parsedOpts.add(QuestionOptionItem(label: lbl, text: map[key].toString()));
        }
      }
    }

    final defaultLabels = ['A', 'B', 'C', 'D'];
    int cIdx = 0;
    String cChar = 'A';

    final rawAns = map['correct_answer'] ?? map['correct_answer_char'] ?? map['answer'];
    if (rawAns is num) {
      cIdx = rawAns.toInt();
      cChar = cIdx >= 0 && cIdx < defaultLabels.length ? defaultLabels[cIdx] : '$cIdx';
    } else if (rawAns != null) {
      final str = rawAns.toString().trim().toUpperCase();
      final idxInLabels = defaultLabels.indexOf(str);
      if (idxInLabels >= 0) {
        cIdx = idxInLabels;
        cChar = str;
      } else {
        final parsedNum = int.tryParse(str);
        if (parsedNum != null) {
          cIdx = parsedNum;
          cChar = cIdx >= 0 && cIdx < defaultLabels.length ? defaultLabels[cIdx] : str;
        } else {
          cChar = str;
          cIdx = 0;
        }
      }
    }

    DateTime dt = DateTime.now();
    if (map['created_at'] != null) {
      dt = DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now();
    }

    final qNum = (map['question_number'] is num)
        ? (map['question_number'] as num).toInt()
        : (int.tryParse(map['question_number']?.toString() ?? '') ?? defaultNumber);

    final marksVal = (map['marks'] is num)
        ? (map['marks'] as num).toDouble()
        : (double.tryParse(map['marks']?.toString() ?? '') ?? 1.0);

    final negMarksVal = (map['negative_marks'] is num)
        ? (map['negative_marks'] as num).toDouble()
        : (double.tryParse(map['negative_marks']?.toString() ?? '') ?? 0.25);

    final usageVal = (map['usage_count'] is num)
        ? (map['usage_count'] as num).toInt()
        : (int.tryParse(map['usage_count']?.toString() ?? '') ?? 0);

    final diffStr = map['difficulty_level']?.toString() ??
        map['difficulty']?.toString() ??
        'medium';

    return QuestionItem(
      id: (map['id'] != null && map['id'].toString().trim().isNotEmpty)
          ? map['id'].toString()
          : 'q_${DateTime.now().microsecondsSinceEpoch}_${defaultNumber}_${math.Random().nextInt(999999)}',
      questionNumber: qNum,
      questionText: map['question_text_english']?.toString() ??
          map['question_text']?.toString() ??
          map['text']?.toString() ??
          'Untitled Question',
      questionTextHindi: map['question_text_hindi']?.toString(),
      subject: (map['subject']?.toString().trim().isNotEmpty ?? false)
          ? map['subject'].toString().trim()
          : 'Uncategorized',
      testSeriesTitle: (resolvedTestTitle != null && resolvedTestTitle.trim().isNotEmpty)
          ? resolvedTestTitle.trim()
          : (map['test_series_title']?.toString() ??
              map['test_title']?.toString() ??
              'General Bank'),
      testId: map['test_id']?.toString(),
      questionSet: map['question_set']?.toString() ?? 'General',
      questionType: map['question_type']?.toString() ?? 'MCQ',
      difficulty: QuestionDifficulty.fromString(diffStr),
      options: parsedOpts,
      correctAnswerIndex: cIdx,
      correctAnswerChar: cChar,
      usageCount: usageVal,
      status: derivedStatus ??
          QuestionStatus.fromString(map['status']?.toString() ?? 'published'),
      createdAt: dt,
      explanation: map['explanation_english']?.toString() ?? map['explanation']?.toString(),
      marks: marksVal,
      negativeMarks: negMarksVal,
      tags: map['tags'] is List ? List<String>.from(map['tags']) : const [],
    );
  }

  Map<String, dynamic> toMap() {
    String diffLevel = difficulty.label.toLowerCase();
    if (diffLevel != 'easy' && diffLevel != 'medium' && diffLevel != 'hard') {
      diffLevel = 'hard';
    }

    final map = <String, dynamic>{
      'id': id,
      'question_number': questionNumber,
      'question_text_english': questionText,
      if (questionTextHindi != null && questionTextHindi!.isNotEmpty)
        'question_text_hindi': questionTextHindi,
      'subject': subject,
      if (testId != null && testId!.isNotEmpty) 'test_id': testId,
      'difficulty_level': diffLevel,
      'options': options.map((o) => o.toMap()).toList(),
      'correct_answer': correctAnswerIndex.clamp(0, 3),
      if (explanation != null && explanation!.isNotEmpty)
        'explanation_english': explanation,
      'created_at': createdAt.toIso8601String(),
    };
    return map;
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
}
