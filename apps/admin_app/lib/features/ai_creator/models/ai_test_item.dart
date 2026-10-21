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
  };

  factory AiGeneratedTestItem.fromJson(Map<String, dynamic> json, int index) {
    final sub = AiTestSubject.fromString(json['subject'] as String? ?? 'General Science');
    final diff = AiTestDifficulty.fromString(json['difficulty'] as String? ?? 'Medium');
    final stat = AiTestStatus.fromString(json['status'] as String? ?? 'Published');

    return AiGeneratedTestItem(
      id: json['id'] as String? ?? 'ait_${index + 1}',
      rowNumber: json['row_number'] as int? ?? (index + 1),
      title: json['title'] as String? ?? 'AI Generated Test',
      subtitle: json['subtitle'] as String? ?? 'AI generated test series',
      subject: sub,
      difficulty: diff,
      questionCount: json['question_count'] as int? ?? 50,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      status: stat,
      createdOn: DateTime.tryParse(json['created_on'] as String? ?? '') ?? DateTime(2026, 10, 18),
      createdBy: json['created_by'] as String? ?? 'Admin',
      icon: sub.icon,
      iconBgColor: sub.backgroundColor,
      iconColor: sub.color,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => AiTestQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
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

/// 7 Canonical Reference Items matching the attached screenshot exactly
final List<AiGeneratedTestItem> kDefaultAiGeneratedTests = [
  AiGeneratedTestItem(
    id: 'ait_1',
    rowNumber: 1,
    title: 'RRB Technician Mock Test',
    subtitle: 'AI generated full syllabus test',
    subject: AiTestSubject.generalScience,
    difficulty: AiTestDifficulty.medium,
    questionCount: 50,
    durationMinutes: 60,
    status: AiTestStatus.published,
    createdOn: DateTime(2026, 10, 18),
    createdBy: 'Admin',
    icon: Icons.science_rounded,
    iconBgColor: const Color(0xFF5636F5),
    iconColor: Colors.white,
    questions: [
      const AiTestQuestion(
        id: 'q_1_1',
        questionNumber: 1,
        questionText: 'What is the SI unit of electric potential difference?',
        questionTextHi: 'विद्युत विभवांतर का SI मात्रक क्या है?',
        options: ['Ampere (एम्पीयर)', 'Volt (वोल्ट)', 'Ohm (ओम)', 'Coulomb (कूलॉम)'],
        correctOptionIndex: 1,
        explanation: 'Volt (V) is the SI unit of electric potential difference. One volt is equal to one joule of energy per coulomb of electric charge.',
        subject: 'General Science',
        difficulty: 'Medium',
      ),
      const AiTestQuestion(
        id: 'q_1_2',
        questionNumber: 2,
        questionText: 'Which law explains the relation between current, voltage, and resistance in an electrical circuit?',
        questionTextHi: 'विद्युत परिपथ में धारा, वोल्टेज और प्रतिरोध के बीच संबंध को कौन सा नियम समझाता है?',
        options: ["Coulomb's Law", "Ohm's Law", "Faraday's Law", "Ampere's Law"],
        correctOptionIndex: 1,
        explanation: "Ohm's Law states that current (I) is directly proportional to voltage (V) and inversely proportional to resistance (R), V = IR.",
        subject: 'General Science',
        difficulty: 'Medium',
      ),
    ],
  ),
  AiGeneratedTestItem(
    id: 'ait_2',
    rowNumber: 2,
    title: 'Railway Maths Practice Test',
    subtitle: 'Topic wise AI generated test',
    subject: AiTestSubject.mathematics,
    difficulty: AiTestDifficulty.easy,
    questionCount: 40,
    durationMinutes: 45,
    status: AiTestStatus.published,
    createdOn: DateTime(2026, 10, 17),
    createdBy: 'Admin',
    icon: Icons.calculate_rounded,
    iconBgColor: const Color(0xFFF43F5E),
    iconColor: Colors.white,
    questions: [
      const AiTestQuestion(
        id: 'q_2_1',
        questionNumber: 1,
        questionText: 'If 15 men can complete a work in 20 days, how many days will 25 men take to complete the same work?',
        questionTextHi: 'यदि 15 पुरुष किसी कार्य को 20 दिनों में पूरा कर सकते हैं, तो 25 पुरुष उसी कार्य को कितने दिनों में पूरा करेंगे?',
        options: ['10 days', '12 days', '14 days', '16 days'],
        correctOptionIndex: 1,
        explanation: 'Work = Men × Days = 15 × 20 = 300 man-days. Days for 25 men = 300 / 25 = 12 days.',
        subject: 'Mathematics',
        difficulty: 'Easy',
      ),
    ],
  ),
  AiGeneratedTestItem(
    id: 'ait_3',
    rowNumber: 3,
    title: 'Reasoning Speed Test',
    subtitle: 'AI generated mixed questions',
    subject: AiTestSubject.reasoning,
    difficulty: AiTestDifficulty.hard,
    questionCount: 60,
    durationMinutes: 60,
    status: AiTestStatus.draft,
    createdOn: DateTime(2026, 10, 15),
    createdBy: 'Admin',
    icon: Icons.lightbulb_rounded,
    iconBgColor: const Color(0xFFFF9F0A),
    iconColor: Colors.white,
    questions: [
      const AiTestQuestion(
        id: 'q_3_1',
        questionNumber: 1,
        questionText: 'In a code language, if CLOCK is coded as KCOLP, how will WATCH be coded?',
        questionTextHi: 'एक कूट भाषा में यदि CLOCK को KCOLP लिखा जाता है, तो WATCH को क्या लिखा जाएगा?',
        options: ['HCTAW', 'HCTAX', 'HCUAW', 'HCTAW'],
        correctOptionIndex: 1,
        explanation: 'Letters reversed and last character shifted forward by 1: W-A-T-C-H -> H-C-T-A-(W+1 = X) -> HCTAX.',
        subject: 'Reasoning',
        difficulty: 'Hard',
      ),
    ],
  ),
  AiGeneratedTestItem(
    id: 'ait_4',
    rowNumber: 4,
    title: 'Current Affairs Weekly Test',
    subtitle: 'Latest current affairs questions',
    subject: AiTestSubject.currentAffairs,
    difficulty: AiTestDifficulty.medium,
    questionCount: 50,
    durationMinutes: 45,
    status: AiTestStatus.published,
    createdOn: DateTime(2026, 10, 12),
    createdBy: 'Admin',
    icon: Icons.public_rounded,
    iconBgColor: const Color(0xFF2587F8),
    iconColor: Colors.white,
    questions: [
      const AiTestQuestion(
        id: 'q_4_1',
        questionNumber: 1,
        questionText: 'Which nation hosted the AI Safety Summit focusing on multilateral sovereign computing infrastructure?',
        questionTextHi: 'किस देश ने बहुपक्षीय संप्रभु कंप्यूटिंग बुनियादी ढांचे पर केंद्रित AI सुरक्षा शिखर सम्मेलन की मेजबानी की?',
        options: ['India', 'United Kingdom', 'France', 'Japan'],
        correctOptionIndex: 0,
        explanation: 'India hosted the high-level multilateral Global AI Infrastructure and Sovereign Compute Summit in New Delhi.',
        subject: 'Current Affairs',
        difficulty: 'Medium',
      ),
    ],
  ),
  AiGeneratedTestItem(
    id: 'ait_5',
    rowNumber: 5,
    title: 'Chemistry Chapter Test',
    subtitle: 'Chapter wise practice test',
    subject: AiTestSubject.chemistry,
    difficulty: AiTestDifficulty.medium,
    questionCount: 40,
    durationMinutes: 40,
    status: AiTestStatus.published,
    createdOn: DateTime(2026, 10, 10),
    createdBy: 'Admin',
    icon: Icons.biotech_rounded,
    iconBgColor: const Color(0xFFD946EF),
    iconColor: Colors.white,
    questions: [
      const AiTestQuestion(
        id: 'q_5_1',
        questionNumber: 1,
        questionText: 'What is the chemical formula of Plaster of Paris?',
        questionTextHi: 'प्लास्टर ऑफ पेरिस का रासायनिक सूत्र क्या है?',
        options: ['CaSO4 · 2H2O', 'CaSO4 · ½H2O', 'CaSO4 · H2O', 'CaCO3 · 2H2O'],
        correctOptionIndex: 1,
        explanation: 'Plaster of Paris is calcium sulphate hemihydrate: CaSO4 · ½H2O, formed by heating gypsum at 373K.',
        subject: 'Chemistry',
        difficulty: 'Medium',
      ),
    ],
  ),
  AiGeneratedTestItem(
    id: 'ait_6',
    rowNumber: 6,
    title: 'Biology NEET Practice Test',
    subtitle: 'AI generated NEET pattern test',
    subject: AiTestSubject.biology,
    difficulty: AiTestDifficulty.hard,
    questionCount: 75,
    durationMinutes: 90,
    status: AiTestStatus.published,
    createdOn: DateTime(2026, 10, 8),
    createdBy: 'Admin',
    icon: Icons.eco_rounded,
    iconBgColor: const Color(0xFF10B981),
    iconColor: Colors.white,
    questions: [
      const AiTestQuestion(
        id: 'q_6_1',
        questionNumber: 1,
        questionText: 'During cellular respiration, in which part of the cell does the Krebs cycle take place?',
        questionTextHi: 'कोशिकीय श्वसन के दौरान, क्रेब्स चक्र कोशिका के किस भाग में होता है?',
        options: ['Cytoplasm', 'Mitochondrial Matrix', 'Inner Mitochondrial Membrane', 'Ribosome'],
        correctOptionIndex: 1,
        explanation: 'The citric acid cycle (Krebs cycle) takes place in the matrix of the mitochondria in eukaryotic cells.',
        subject: 'Biology',
        difficulty: 'Hard',
      ),
    ],
  ),
  AiGeneratedTestItem(
    id: 'ait_7',
    rowNumber: 7,
    title: 'Full Syllabus Combined Test',
    subtitle: 'AI generated mixed subject test',
    subject: AiTestSubject.mixed,
    difficulty: AiTestDifficulty.medium,
    questionCount: 100,
    durationMinutes: 120,
    status: AiTestStatus.processing,
    createdOn: DateTime(2026, 10, 5),
    createdBy: 'Admin',
    icon: Icons.settings_rounded,
    iconBgColor: const Color(0xFF2587F8),
    iconColor: Colors.white,
    questions: [
      const AiTestQuestion(
        id: 'q_7_1',
        questionNumber: 1,
        questionText: 'Generating complete 100-question multi-subject examination syllabus via Gemini AI...',
        questionTextHi: 'जेमिनी एआई के माध्यम से 100-प्रश्नों का संपूर्ण बहु-विषय पाठ्यक्रम परीक्षण तैयार किया जा रहा है...',
        options: ['Synthesizing questions...', 'Validating distractors...', 'Parsing solutions...', 'Formatting tags...'],
        correctOptionIndex: 0,
        explanation: 'Autonomous batch generation job is currently in progress.',
        subject: 'Mixed',
        difficulty: 'Medium',
      ),
    ],
  ),
];

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
