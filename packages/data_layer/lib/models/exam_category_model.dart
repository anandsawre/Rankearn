/// Exam Category Domain Model (Level 1: Main Exams e.g. BPSC, SSC, UPSC, Railway)
class ExamCategoryModel {
  final String id;
  final String name;
  final String normalizedName;
  final String? iconUrl;
  final int displayOrder;
  final bool isPublished;
  final String? languages;
  final int totalTests;
  final int totalMocks;
  final int totalSectional;

  const ExamCategoryModel({
    required this.id,
    required this.name,
    this.normalizedName = '',
    this.iconUrl,
    this.displayOrder = 1,
    this.isPublished = true,
    this.languages,
    this.totalTests = 0,
    this.totalMocks = 0,
    this.totalSectional = 0,
  });

  ExamCategoryModel copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? iconUrl,
    int? displayOrder,
    bool? isPublished,
    String? languages,
    int? totalTests,
    int? totalMocks,
    int? totalSectional,
  }) {
    return ExamCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      iconUrl: iconUrl ?? this.iconUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isPublished: isPublished ?? this.isPublished,
      languages: languages ?? this.languages,
      totalTests: totalTests ?? this.totalTests,
      totalMocks: totalMocks ?? this.totalMocks,
      totalSectional: totalSectional ?? this.totalSectional,
    );
  }

  factory ExamCategoryModel.fromMap(Map<String, dynamic> map) {
    return ExamCategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Exam',
      normalizedName: map['normalized_name']?.toString() ?? '',
      iconUrl: map['icon_url']?.toString(),
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 1,
      isPublished: map['is_published'] != false,
      languages: map['languages']?.toString(),
      totalTests: (map['total_tests'] as num?)?.toInt() ?? 0,
      totalMocks: (map['total_mocks'] as num?)?.toInt() ?? 0,
      totalSectional: (map['total_sectional'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'normalized_name': normalizedName,
      'icon_url': iconUrl,
      'display_order': displayOrder,
      'is_published': isPublished,
      'languages': languages,
    };
  }
}
