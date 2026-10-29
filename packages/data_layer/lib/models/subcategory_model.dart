/// Subcategory Domain Model (Level 3: Units / Sections under a Subject, e.g. Physics, Ancient History)
class SubcategoryModel {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String description;
  final int displayOrder;
  final String status; // 'active' | 'draft' | 'archived'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubcategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.slug = '',
    this.description = '',
    this.displayOrder = 1,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug.isNotEmpty
          ? slug
          : name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
      'description': description,
      'display_order': displayOrder,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory SubcategoryModel.fromMap(Map<String, dynamic> map) {
    return SubcategoryModel(
      id: map['id']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 1,
      status: map['status']?.toString() ?? 'active',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  SubcategoryModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? slug,
    String? description,
    int? displayOrder,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubcategoryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

