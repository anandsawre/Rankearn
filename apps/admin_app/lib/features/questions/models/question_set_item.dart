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
      name: map['name']?.toString() ?? map['title']?.toString() ?? 'Untitled Set',
      subject: map['subject']?.toString() ?? map['category_id']?.toString() ?? 'General',
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 0,
      difficulty: map['difficulty']?.toString() ?? 'Mixed',
      status: map['status']?.toString() ?? 'published',
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
}
