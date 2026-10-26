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

/// Baseline Reference Categories matching the specification image exactly (48 Total Categories)
final List<CategoryItem> kReferenceCategories = [
  CategoryItem(
    id: 'cat-1',
    index: 1,
    name: 'Competitive Exams',
    slug: 'competitive-exams',
    description: 'Government and competitive exams',
    iconName: 'school',
    iconColor: '#3B82F6',
    subcategoriesCount: 12,
    subjectsCount: 28,
    totalTests: 320,
    totalQuestions: 4850,
    displayOrder: 1,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 18),
  ),
  CategoryItem(
    id: 'cat-2',
    index: 2,
    name: 'School Education',
    slug: 'school-education',
    description: 'School level subjects and tests',
    iconName: 'menu_book',
    iconColor: '#F43F5E',
    subcategoriesCount: 8,
    subjectsCount: 16,
    totalTests: 180,
    totalQuestions: 2340,
    displayOrder: 2,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 15),
  ),
  CategoryItem(
    id: 'cat-3',
    index: 3,
    name: 'State Level Exams',
    slug: 'state-level-exams',
    description: 'State government examinations',
    iconName: 'account_balance',
    iconColor: '#F59E0B',
    subcategoriesCount: 6,
    subjectsCount: 12,
    totalTests: 120,
    totalQuestions: 1950,
    displayOrder: 3,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 12),
  ),
  CategoryItem(
    id: 'cat-4',
    index: 4,
    name: 'Entrance Exams',
    slug: 'entrance-exams',
    description: 'Engineering, Medical and other entrance exams',
    iconName: 'auto_stories',
    iconColor: '#8B5CF6',
    subcategoriesCount: 10,
    subjectsCount: 20,
    totalTests: 240,
    totalQuestions: 3420,
    displayOrder: 4,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 10),
  ),
  CategoryItem(
    id: 'cat-5',
    index: 5,
    name: 'Skill Development',
    slug: 'skill-development',
    description: 'Professional and skill based courses',
    iconName: 'code',
    iconColor: '#10B981',
    subcategoriesCount: 5,
    subjectsCount: 10,
    totalTests: 80,
    totalQuestions: 980,
    displayOrder: 5,
    status: CategoryStatus.draft,
    createdAt: DateTime(2026, 10, 8),
  ),
  CategoryItem(
    id: 'cat-6',
    index: 6,
    name: 'General Awareness',
    slug: 'general-awareness',
    description: 'Current affairs and general knowledge',
    iconName: 'public',
    iconColor: '#06B6D4',
    subcategoriesCount: 7,
    subjectsCount: 14,
    totalTests: 160,
    totalQuestions: 2100,
    displayOrder: 6,
    status: CategoryStatus.active,
    createdAt: DateTime(2026, 10, 5),
  ),
  CategoryItem(
    id: 'cat-7',
    index: 7,
    name: 'Practice & Mock Tests',
    slug: 'practice-mock-tests',
    description: 'Mixed category tests for practice',
    iconName: 'assignment',
    iconColor: '#EC4899',
    subcategoriesCount: 4,
    subjectsCount: 8,
    totalTests: 95,
    totalQuestions: 1250,
    displayOrder: 7,
    status: CategoryStatus.archived,
    createdAt: DateTime(2026, 10, 1),
  ),
  // Additional 41 categories to support full 48-item pagination and filtering
  ...List.generate(41, (i) {
    final idx = i + 8;
    final names = [
      'Banking & Insurance',
      'Civil Services IAS/IPS',
      'Defence & NDA/CDS',
      'Railway Recruitment Board',
      'Teaching & UGC NET',
      'Police Sub-Inspector',
      'SSC CGL & CHSL',
      'GATE & IES Engineering',
      'Medical NEET & AIIMS',
      'Law CLAT & Judiciary',
      'Management CAT & XAT',
      'Computer Science & IT',
      'Foreign Language Studies',
      'Commerce & CA Foundation',
      'Data Science & Analytics',
    ];
    final name = names[i % names.length] + (idx > 22 ? ' ($idx)' : '');
    final isDraft = idx == 15 || idx == 28 || idx == 40;
    final isArchived = idx == 48;
    return CategoryItem(
      id: 'cat-$idx',
      index: idx,
      name: name,
      slug: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-'),
      description: 'Comprehensive study materials, sectional and full length tests for $name.',
      iconName: idx % 3 == 0 ? 'school' : (idx % 2 == 0 ? 'auto_stories' : 'account_balance'),
      iconColor: idx % 4 == 0 ? '#3B82F6' : (idx % 3 == 0 ? '#10B981' : '#F59E0B'),
      subcategoriesCount: 3 + (idx % 6),
      subjectsCount: idx <= 27 ? 1 : 0,
      totalTests: 40 + (idx * 5),
      totalQuestions: 500 + (idx * 75),
      displayOrder: idx,
      status: isDraft ? CategoryStatus.draft : (isArchived ? CategoryStatus.archived : CategoryStatus.active),
      createdAt: DateTime(2026, 9, 30).subtract(Duration(days: idx)),
    );
  }),
];
