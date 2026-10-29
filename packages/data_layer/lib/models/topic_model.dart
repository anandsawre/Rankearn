/// Topic Domain Model (Level 4: Specific Chapters / Topics under a Subcategory, e.g. Optics, Thermodynamics)
class TopicModel {
  final String id;
  final String subcategoryId;
  final String? categoryId;
  final String name;
  final String slug;
  final String description;
  final int displayOrder;
  final String status; // 'active' | 'draft' | 'archived'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TopicModel({
    required this.id,
    required this.subcategoryId,
    this.categoryId,
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
      'subcategory_id': subcategoryId,
      if (categoryId != null) 'category_id': categoryId,
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

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id']?.toString() ?? '',
      subcategoryId: map['subcategory_id']?.toString() ?? '',
      categoryId: map['category_id']?.toString(),
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

  TopicModel copyWith({
    String? id,
    String? subcategoryId,
    String? categoryId,
    String? name,
    String? slug,
    String? description,
    int? displayOrder,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TopicModel(
      id: id ?? this.id,
      subcategoryId: subcategoryId ?? this.subcategoryId,
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

