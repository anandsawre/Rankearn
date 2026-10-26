/// Category / Subject Domain Model (Level 2: Subjects under an Exam, e.g. History, Science)
class CategoryModel {
  final String id;
  final String name;
  final String? examCategoryId;
  final List<String> topics;
  final String slug;
  final String description;
  final String iconName;
  final String iconColor;
  final int subcategoriesCount;
  final int subjectsCount;
  final int totalTests;
  final int totalQuestions;
  final int displayOrder;
  final String status; // 'active' | 'draft' | 'archived'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.examCategoryId,
    this.topics = const [],
    this.slug = '',
    this.description = '',
    this.iconName = 'school',
    this.iconColor = '#3B82F6',
    this.subcategoriesCount = 0,
    this.subjectsCount = 0,
    this.totalTests = 0,
    this.totalQuestions = 0,
    this.displayOrder = 1,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (examCategoryId != null) 'exam_category_id': examCategoryId,
      'topics': topics,
      'slug': slug,
      'description': description,
      'icon_name': iconName,
      'icon_color': iconColor,
      'subcategories_count': subcategoriesCount,
      'subjects_count': subjectsCount,
      'total_tests': totalTests,
      'total_questions': totalQuestions,
      'display_order': displayOrder,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic d) {
      if (d == null) return DateTime.now();
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString()) ?? DateTime.now();
    }

    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'General',
      examCategoryId: map['exam_category_id']?.toString(),
      topics: (map['topics'] is List)
          ? (map['topics'] as List).map((e) => e.toString()).toList()
          : [],
      slug: map['slug']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      iconName: map['icon_name']?.toString() ?? 'school',
      iconColor: map['icon_color']?.toString() ?? '#3B82F6',
      subcategoriesCount: (map['subcategories_count'] as num?)?.toInt() ?? 0,
      subjectsCount: (map['subjects_count'] as num?)?.toInt() ?? 0,
      totalTests: (map['total_tests'] as num?)?.toInt() ?? 0,
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 0,
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 1,
      status: map['status']?.toString() ?? 'active',
      createdAt: parseDate(map['created_at']),
      updatedAt: map['updated_at'] != null ? parseDate(map['updated_at']) : null,
    );
  }
}
