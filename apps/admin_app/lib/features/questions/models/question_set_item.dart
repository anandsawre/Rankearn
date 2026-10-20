class QuestionSetItem {
  final String id;
  final String name;
  final String subject;
  final int totalQuestions;
  final String difficulty;
  final String status;
  final DateTime createdAt;

  const QuestionSetItem({
    required this.id,
    required this.name,
    required this.subject,
    required this.totalQuestions,
    required this.difficulty,
    this.status = 'Active',
    required this.createdAt,
  });

  factory QuestionSetItem.fromMap(Map<String, dynamic> map) {
    return QuestionSetItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Default Set',
      subject: map['subject']?.toString() ?? 'General Science',
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 0,
      difficulty: map['difficulty']?.toString() ?? 'Medium',
      status: map['status']?.toString() ?? 'Active',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subject': subject,
        'total_questions': totalQuestions,
        'difficulty': difficulty,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  static List<QuestionSetItem> get sampleSets => [
        QuestionSetItem(
          id: 'qs-1',
          name: 'RRB Technician Grade 3 Master Set',
          subject: 'Physics',
          totalQuestions: 250,
          difficulty: 'Easy',
          status: 'Active',
          createdAt: DateTime(2026, 10, 18),
        ),
        QuestionSetItem(
          id: 'qs-2',
          name: 'Current Affairs 2026 Q-Bank',
          subject: 'General Awareness',
          totalQuestions: 500,
          difficulty: 'Easy',
          status: 'Active',
          createdAt: DateTime(2026, 10, 15),
        ),
        QuestionSetItem(
          id: 'qs-3',
          name: 'Quantitative Aptitude Special',
          subject: 'Mathematics',
          totalQuestions: 400,
          difficulty: 'Medium',
          status: 'Active',
          createdAt: DateTime(2026, 10, 10),
        ),
        QuestionSetItem(
          id: 'qs-4',
          name: 'Organic & Inorganic Chemistry Set',
          subject: 'Chemistry',
          totalQuestions: 320,
          difficulty: 'Medium',
          status: 'Active',
          createdAt: DateTime(2026, 10, 5),
        ),
        QuestionSetItem(
          id: 'qs-5',
          name: 'Logical Reasoning Marathon',
          subject: 'Reasoning',
          totalQuestions: 450,
          difficulty: 'Hard',
          status: 'Active',
          createdAt: DateTime(2026, 10, 1),
        ),
      ];
}
