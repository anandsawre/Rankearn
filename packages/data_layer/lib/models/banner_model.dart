class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String link;
  final bool isActive;
  final int priority;
  final String type;
  final Map<String, dynamic>? spotlightData;
  final DateTime? scheduledAt;
  final int clicks;
  final DateTime? createdAt;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.link = '/tests',
    this.isActive = true,
    this.priority = 1,
    this.type = 'promotional',
    this.spotlightData,
    this.scheduledAt,
    this.clicks = 0,
    this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      link: json['link']?.toString() ?? '/tests',
      isActive: json['is_active'] == true,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      type: json['type']?.toString() ?? 'promotional',
      spotlightData: json['spotlight_data'] is Map ? Map<String, dynamic>.from(json['spotlight_data'] as Map) : null,
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'].toString()) : null,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'link': link,
      'is_active': isActive,
      'priority': priority,
      'type': type,
      'spotlight_data': spotlightData,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'clicks': clicks,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Helper to extract display placement mode from spotlightData
  String get displayMode {
    if (spotlightData != null && spotlightData!['display_mode'] != null) {
      return spotlightData!['display_mode'].toString();
    }
    return 'home_carousel';
  }
}
