import 'package:flutter/material.dart';

enum AiTestSubject {
  generalScience(
    label: 'General Science',
    color: Color(0xFF2587F8),
    backgroundColor: Color(0xFFEFF6FF),
    icon: Icons.science_outlined,
  ),
  mathematics(
    label: 'Mathematics',
    color: Color(0xFFE11D48),
    backgroundColor: Color(0xFFFFF1F2),
    icon: Icons.calculate_outlined,
  ),
  reasoning(
    label: 'Reasoning',
    color: Color(0xFF5636F5),
    backgroundColor: Color(0xFFEEF0FF),
    icon: Icons.lightbulb_outline_rounded,
  ),
  currentAffairs(
    label: 'Current Affairs',
    color: Color(0xFFFF9F0A),
    backgroundColor: Color(0xFFFFF7ED),
    icon: Icons.public_rounded,
  ),
  chemistry(
    label: 'Chemistry',
    color: Color(0xFFD946EF),
    backgroundColor: Color(0xFFFDF4FF),
    icon: Icons.biotech_rounded,
  ),
  biology(
    label: 'Biology',
    color: Color(0xFF10B981),
    backgroundColor: Color(0xFFECFDF5),
    icon: Icons.eco_outlined,
  ),
  mixed(
    label: 'Mixed',
    color: Color(0xFF64748B),
    backgroundColor: Color(0xFFF1F5F9),
    icon: Icons.tune_rounded,
  ),
  others(
    label: 'Others',
    color: Color(0xFF94A3B8),
    backgroundColor: Color(0xFFF8FAFC),
    icon: Icons.category_outlined,
  );

  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const AiTestSubject({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  static AiTestSubject fromString(String val) {
    for (final s in AiTestSubject.values) {
      if (s.label.toLowerCase() == val.toLowerCase() || s.name.toLowerCase() == val.toLowerCase()) {
        return s;
      }
    }
    return AiTestSubject.generalScience;
  }
}

enum AiTestDifficulty {
  easy(
    label: 'Easy',
    color: Color(0xFF10B981),
    backgroundColor: Color(0xFFECFDF5),
  ),
  medium(
    label: 'Medium',
    color: Color(0xFFFF9F0A),
    backgroundColor: Color(0xFFFFF7ED),
  ),
  hard(
    label: 'Hard',
    color: Color(0xFFF0445F),
    backgroundColor: Color(0xFFFFF1F2),
  );

  final String label;
  final Color color;
  final Color backgroundColor;

  const AiTestDifficulty({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  static AiTestDifficulty fromString(String val) {
    for (final d in AiTestDifficulty.values) {
      if (d.label.toLowerCase() == val.toLowerCase() || d.name.toLowerCase() == val.toLowerCase()) {
        return d;
      }
    }
    return AiTestDifficulty.medium;
  }
}

enum AiTestStatus {
  published(
    label: 'Published',
    color: Color(0xFF10B981),
    backgroundColor: Color(0xFFECFDF5),
  ),
  draft(
    label: 'Draft',
    color: Color(0xFF5636F5),
    backgroundColor: Color(0xFFEEF0FF),
  ),
  processing(
    label: 'Processing',
    color: Color(0xFF2587F8),
    backgroundColor: Color(0xFFEFF6FF),
  );

  final String label;
  final Color color;
  final Color backgroundColor;

  const AiTestStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  static AiTestStatus fromString(String val) {
    for (final s in AiTestStatus.values) {
      if (s.label.toLowerCase() == val.toLowerCase() || s.name.toLowerCase() == val.toLowerCase()) {
        return s;
      }
    }
    return AiTestStatus.published;
  }
}

class AiTestQuestion {
  final String id;
  final int questionNumber;
  final String questionText;
  final String? questionTextHi;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String? explanationHi;
  final String subject;
  final String difficulty;

  const AiTestQuestion({
    required this.id,
    required this.questionNumber,
    required this.questionText,
    this.questionTextHi,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.explanationHi,
    required this.subject,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question_number': questionNumber,
    'question_text': questionText,
    'question_text_hi': questionTextHi,
    'options': options,
    'correct_option_index': correctOptionIndex,
    'explanation': explanation,
    'explanation_hi': explanationHi,
    'subject': subject,
    'difficulty': difficulty,
  };

  factory AiTestQuestion.fromJson(Map<String, dynamic> json) {
    return AiTestQuestion(
      id: json['id'] as String? ?? 'q_1',
      questionNumber: json['question_number'] as int? ?? 1,
      questionText: json['question_text'] as String? ?? '',
      questionTextHi: json['question_text_hi'] as String?,
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctOptionIndex: json['correct_option_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      explanationHi: json['explanation_hi'] as String?,
      subject: json['subject'] as String? ?? 'General Science',
      difficulty: json['difficulty'] as String? ?? 'Medium',
    );
  }
}

class AiGeneratedTestItem {
  final String id;
  final int rowNumber;
  final String title;
  final String subtitle;
  final AiTestSubject subject;
  final AiTestDifficulty difficulty;
  final int questionCount;
  final int durationMinutes;
  final AiTestStatus status;
  final DateTime createdOn;
  final String createdBy;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final List<AiTestQuestion> questions;
  final int? generationTimeSeconds;
  final int timesUsed;

  const AiGeneratedTestItem({
    required this.id,
    required this.rowNumber,
    required this.title,
    required this.subtitle,
    required this.subject,
    required this.difficulty,
    required this.questionCount,
    required this.durationMinutes,
    required this.status,
    required this.createdOn,
    this.createdBy = 'Admin',
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.questions = const [],
    this.generationTimeSeconds,
    this.timesUsed = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'row_number': rowNumber,
    'title': title,
    'subtitle': subtitle,
    'subject': subject.label,
    'difficulty': difficulty.label,
    'question_count': questionCount,
    'duration_minutes': durationMinutes,
    'status': status.label,
    'created_on': createdOn.toIso8601String(),
    'created_by': createdBy,
    'metadata': {
      if (generationTimeSeconds != null) 'generation_time_seconds': generationTimeSeconds,
      'times_used': timesUsed,
    },
  };

  factory AiGeneratedTestItem.fromJson(Map<String, dynamic> json, int index) {
    final sub = AiTestSubject.fromString(
      (json['subject'] ?? json['category_id'] ?? 'General Science').toString(),
    );
    final diff = AiTestDifficulty.fromString(
      (json['difficulty'] ?? 'Medium').toString(),
    );
    final stat = AiTestStatus.fromString(
      (json['status'] ?? 'Published').toString(),
    );
    final meta = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : const <String, dynamic>{};

    return AiGeneratedTestItem(
      id: json['id']?.toString() ?? 'ait_${index + 1}',
      rowNumber: (json['row_number'] as num?)?.toInt() ?? (index + 1),
      title: json['title']?.toString() ?? 'AI Generated Test',
      subtitle: json['subtitle']?.toString() ?? '',
      subject: sub,
      difficulty: diff,
      questionCount: (json['question_count'] as num?)?.toInt() ??
          (json['total_questions'] as num?)?.toInt() ??
          0,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      status: stat,
      createdOn: DateTime.tryParse(
            (json['created_on'] ?? json['created_at'] ?? '').toString(),
          )?.toLocal() ??
          DateTime.now(),
      createdBy: json['created_by']?.toString() ?? 'Admin',
      icon: sub.icon,
      iconBgColor: sub.backgroundColor,
      iconColor: sub.color,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => AiTestQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      generationTimeSeconds: (meta['generation_time_seconds'] as num?)?.toInt(),
      timesUsed: (meta['times_used'] as num?)?.toInt() ?? 0,
    );
  }

  AiGeneratedTestItem copyWith({
    String? id,
    int? rowNumber,
    String? title,
    String? subtitle,
    AiTestSubject? subject,
    AiTestDifficulty? difficulty,
    int? questionCount,
    int? durationMinutes,
    AiTestStatus? status,
    DateTime? createdOn,
    String? createdBy,
    IconData? icon,
    Color? iconBgColor,
    Color? iconColor,
    List<AiTestQuestion>? questions,
    int? generationTimeSeconds,
    int? timesUsed,
  }) {
    return AiGeneratedTestItem(
      id: id ?? this.id,
      rowNumber: rowNumber ?? this.rowNumber,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      icon: icon ?? this.icon,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      iconColor: iconColor ?? this.iconColor,
      questions: questions ?? this.questions,
      generationTimeSeconds: generationTimeSeconds ?? this.generationTimeSeconds,
      timesUsed: timesUsed ?? this.timesUsed,
    );
  }
}

class AiTestTemplate {
  final String id;
  final String title;
  final String description;
  final AiTestSubject subject;
  final AiTestDifficulty defaultDifficulty;
  final int defaultQuestionCount;
  final int defaultDurationMinutes;
  final String targetExam;
  final IconData icon;
  final Color color;

  const AiTestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.defaultDifficulty,
    required this.defaultQuestionCount,
    required this.defaultDurationMinutes,
    required this.targetExam,
    required this.icon,
    required this.color,
  });
}

final List<AiTestTemplate> kPrebuiltTemplates = [
  const AiTestTemplate(
    id: 'tpl_1',
    title: 'RRB Technician Full Mock',
    description: '50 Qs General Science & Math pattern for Railway exams',
    subject: AiTestSubject.generalScience,
    defaultDifficulty: AiTestDifficulty.medium,
    defaultQuestionCount: 50,
    defaultDurationMinutes: 60,
    targetExam: 'RRB Technician',
    icon: Icons.train_rounded,
    color: Color(0xFF5636F5),
  ),
  const AiTestTemplate(
    id: 'tpl_2',
    title: 'NEET Biology High-Yield Chapter',
    description: '75 Qs NCERT-strictly aligned with diagram-based concepts',
    subject: AiTestSubject.biology,
    defaultDifficulty: AiTestDifficulty.hard,
    defaultQuestionCount: 75,
    defaultDurationMinutes: 90,
    targetExam: 'NEET UG',
    icon: Icons.biotech_rounded,
    color: Color(0xFF10B981),
  ),
  const AiTestTemplate(
    id: 'tpl_3',
    title: 'SSC CGL Reasoning Speed Sprint',
    description: '25 Qs rapid fire pattern with high-speed tricks & solutions',
    subject: AiTestSubject.reasoning,
    defaultDifficulty: AiTestDifficulty.medium,
    defaultQuestionCount: 25,
    defaultDurationMinutes: 20,
    targetExam: 'SSC CGL',
    icon: Icons.bolt_rounded,
    color: Color(0xFFFF9F0A),
  ),
  const AiTestTemplate(
    id: 'tpl_4',
    title: 'Monthly Current Affairs Digest',
    description: '50 Qs covering national, international, sports & awards',
    subject: AiTestSubject.currentAffairs,
    defaultDifficulty: AiTestDifficulty.medium,
    defaultQuestionCount: 50,
    defaultDurationMinutes: 45,
    targetExam: 'All Competitive Exams',
    icon: Icons.newspaper_rounded,
    color: Color(0xFF2587F8),
  ),
];
