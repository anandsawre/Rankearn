import 'package:flutter/material.dart';

enum CategoryStatus {
  active('Active', Color(0xFF10B981), Color(0xFFECFDF5)),
  draft('Draft', Color(0xFFF59E0B), Color(0xFFFFFBEB)),
  archived('Archived', Color(0xFFF43F5E), Color(0xFFFFF1F2));

  final String label;
  final Color color;
  final Color bgColor;

  const CategoryStatus(this.label, this.color, this.bgColor);

  static CategoryStatus fromString(String? val) {
    if (val == null) return CategoryStatus.active;
    final lower = val.toLowerCase().trim();
    if (lower == 'draft') return CategoryStatus.draft;
    if (lower == 'archived') return CategoryStatus.archived;
    return CategoryStatus.active;
  }
}

class CategoryItem {
  final String id;
  final int index;
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
  final CategoryStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryItem({
    required this.id,
    required this.index,
    required this.name,
    this.examCategoryId,
    this.topics = const [],
    required this.slug,
    required this.description,
    this.iconName = 'school',
    this.iconColor = '#3B82F6',
    this.subcategoriesCount = 0,
    this.subjectsCount = 0,
    this.totalTests = 0,
    this.totalQuestions = 0,
    this.displayOrder = 1,
    this.status = CategoryStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  IconData get iconData {
    switch (iconName.toLowerCase()) {
      case 'school':
        return Icons.school_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'auto_stories':
        return Icons.auto_stories_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'engineering':
        return Icons.engineering_rounded;
      case 'calculate':
        return Icons.calculate_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color get parsedColor {
    try {
      final hex = iconColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return const Color(0xFF3B82F6);
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  CategoryItem copyWith({
    String? id,
    int? index,
    String? name,
    String? examCategoryId,
    List<String>? topics,
    String? slug,
    String? description,
    String? iconName,
    String? iconColor,
    int? subcategoriesCount,
    int? subjectsCount,
    int? totalTests,
    int? totalQuestions,
    int? displayOrder,
    CategoryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      index: index ?? this.index,
      name: name ?? this.name,
      examCategoryId: examCategoryId ?? this.examCategoryId,
      topics: topics ?? this.topics,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      iconColor: iconColor ?? this.iconColor,
      subcategoriesCount: subcategoriesCount ?? this.subcategoriesCount,
      subjectsCount: subjectsCount ?? this.subjectsCount,
      totalTests: totalTests ?? this.totalTests,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      displayOrder: displayOrder ?? this.displayOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map, [int fallbackIndex = 1]) {
    DateTime parseDate(dynamic d) {
      if (d == null) return DateTime.now();
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString()) ?? DateTime.now();
    }

    return CategoryItem(
      id: map['id']?.toString() ?? 'cat-$fallbackIndex',
      index: fallbackIndex,
      name: map['name']?.toString() ?? 'Untitled Category',
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
      displayOrder: (map['display_order'] as num?)?.toInt() ?? fallbackIndex,
      status: CategoryStatus.fromString(map['status']?.toString()),
      createdAt: parseDate(map['created_at']),
      updatedAt: map['updated_at'] != null ? parseDate(map['updated_at']) : null,
    );
  }
}

class SubcategoryItem {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final int displayOrder;
  final String status;
  final DateTime createdAt;

  const SubcategoryItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description = '',
    this.displayOrder = 1,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'display_order': displayOrder,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SubcategoryItem.fromMap(Map<String, dynamic> map) {
    return SubcategoryItem(
      id: map['id']?.toString() ?? 'sub-1',
      categoryId: map['category_id']?.toString() ?? 'cat-1',
      name: map['name']?.toString() ?? 'Untitled Subcategory',
      description: map['description']?.toString() ?? '',
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 1,
      status: map['status']?.toString() ?? 'active',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Baseline Reference Subjects matching Option 1 (Exam -> Subject -> Chapter -> Topic)
final List<CategoryItem> kReferenceCategories = [
  CategoryItem(
    id: 'cat-1',
    index: 1,
    name: 'General Science',
    examCategoryId: 'bpsc',
    slug: 'general-science',
    description: 'Physics, Chemistry, and Life Sciences for competitive exams',
    iconName: 'science',
    iconColor: '#3B82F6',
    subcategoriesCount: 3,
    subjectsCount: 1,
    totalTests: 320,
    totalQuestions: 4850,
    displayOrder: 1,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 18),
  ),
  CategoryItem(
    id: 'cat-2',
    index: 2,
    name: 'Indian History',
    examCategoryId: 'bpsc',
    slug: 'indian-history',
    description: 'Ancient, Medieval, and Modern Indian History curriculum',
    iconName: 'menu_book',
    iconColor: '#F43F5E',
    subcategoriesCount: 3,
    subjectsCount: 1,
    totalTests: 180,
    totalQuestions: 2340,
    displayOrder: 2,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 15),
  ),
  CategoryItem(
    id: 'cat-3',
    index: 3,
    name: 'Quantitative Aptitude',
    examCategoryId: 'ssc',
    slug: 'quantitative-aptitude',
    description: 'Arithmetic, Algebra, Geometry, and Advanced Mathematics',
    iconName: 'calculate',
    iconColor: '#F59E0B',
    subcategoriesCount: 4,
    subjectsCount: 1,
    totalTests: 240,
    totalQuestions: 3420,
    displayOrder: 3,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 12),
  ),
  CategoryItem(
    id: 'cat-4',
    index: 4,
    name: 'Logical Reasoning',
    examCategoryId: 'ssc',
    slug: 'logical-reasoning',
    description: 'Verbal, Non-Verbal, Analytical and Critical Reasoning',
    iconName: 'psychology',
    iconColor: '#8B5CF6',
    subcategoriesCount: 3,
    subjectsCount: 1,
    totalTests: 210,
    totalQuestions: 2950,
    displayOrder: 4,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 10),
  ),
  CategoryItem(
    id: 'cat-5',
    index: 5,
    name: 'Indian Polity & Constitution',
    examCategoryId: 'upsc',
    slug: 'indian-polity',
    description: 'Constitutional framework, governance, Parliament and Judiciary',
    iconName: 'account_balance',
    iconColor: '#10B981',
    subcategoriesCount: 3,
    subjectsCount: 1,
    totalTests: 160,
    totalQuestions: 2100,
    displayOrder: 5,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 8),
  ),
  CategoryItem(
    id: 'cat-6',
    index: 6,
    name: 'Geography & Environment',
    examCategoryId: 'upsc',
    slug: 'geography-environment',
    description: 'Physical geography, Indian geography, climate and ecology',
    iconName: 'public',
    iconColor: '#06B6D4',
    subcategoriesCount: 3,
    subjectsCount: 1,
    totalTests: 140,
    totalQuestions: 1850,
    displayOrder: 6,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 5),
  ),
  CategoryItem(
    id: 'cat-7',
    index: 7,
    name: 'English Language & Comprehension',
    examCategoryId: 'banking',
    slug: 'english-language',
    description: 'Grammar, vocabulary, reading comprehension and cloze tests',
    iconName: 'auto_stories',
    iconColor: '#EC4899',
    subcategoriesCount: 3,
    subjectsCount: 1,
    totalTests: 195,
    totalQuestions: 2450,
    displayOrder: 7,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 1),
  ),
  // Additional subjects across competitive exams
  ...List.generate(41, (i) {
    final idx = i + 8;
    final subjectPool = [
      ('General Knowledge & Current Affairs', 'public', '#3B82F6', 'railway'),
      ('Computer Science & IT Aptitude', 'code', '#10B981', 'banking'),
      ('Economics & Social Development', 'account_balance', '#F59E0B', 'upsc'),
      ('Hindi Language & Sahitya', 'menu_book', '#F43F5E', 'bpsc'),
      ('General Mental Ability', 'psychology', '#8B5CF6', 'ssc'),
      ('General Studies Bihar Special', 'school', '#06B6D4', 'bpsc'),
      ('Science & Tech Inventions', 'biotech', '#EC4899', 'upsc'),
      ('Banking Awareness & Economy', 'account_balance', '#3B82F6', 'banking'),
      ('Railway GK & Technical Concepts', 'assignment', '#10B981', 'railway'),
      ('Child Development & Pedagogy', 'school', '#F59E0B', 'bpsc'),
    ];
    final selected = subjectPool[i % subjectPool.length];
    final name = selected.$1 + (idx > 17 ? ' (Module $idx)' : '');
    final isDraft = idx == 20 || idx == 35;
    final isArchived = idx == 48;
    return CategoryItem(
      id: 'cat-$idx',
      index: idx,
      name: name,
      examCategoryId: selected.$4,
      slug: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-'),
      description: 'Comprehensive study materials, sectional and full length tests for $name.',
      iconName: selected.$2,
      iconColor: selected.$3,
      subcategoriesCount: 3 + (idx % 4),
      subjectsCount: 1,
      totalTests: 40 + (idx * 5),
      totalQuestions: 500 + (idx * 75),
      displayOrder: idx,
      status: isDraft ? CategoryStatus.draft : (isArchived ? CategoryStatus.archived : CategoryStatus.active),
      createdAt: DateTime(2026, 9, 30).subtract(Duration(days: idx)),
    );
  }),
];
