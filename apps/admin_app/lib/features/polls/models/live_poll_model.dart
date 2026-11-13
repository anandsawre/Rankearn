import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Supported types of live polls
enum LivePollType {
  singleChoice('Single Choice'),
  multipleChoice('Multiple Choice'),
  yesNo('Yes / No');

  final String label;
  const LivePollType(this.label);
}

/// Represents a single selectable option in a live poll
class LivePollOption {
  final String id;
  final String label; // 'A', 'B', 'C', 'D'
  String text;
  int votes;
  Color color;

  LivePollOption({
    required this.id,
    required this.label,
    required this.text,
    this.votes = 0,
    Color? color,
  }) : color = color ?? _defaultColorForLabel(label);

  static Color _defaultColorForLabel(String label) {
    switch (label.toUpperCase()) {
      case 'A':
        return AppColors.brandBlue; // #2587F8
      case 'B':
        return AppColors.brandGreen; // #10B981
      case 'C':
        return AppColors.brandPurple; // #5636F5
      case 'D':
        return AppColors.coinGold; // #FFB800
      case 'E':
        return AppColors.brandPink;
      default:
        return AppColors.brandOrange;
    }
  }

  LivePollOption copyWith({
    String? id,
    String? label,
    String? text,
    int? votes,
    Color? color,
  }) {
    return LivePollOption(
      id: id ?? this.id,
      label: label ?? this.label,
      text: text ?? this.text,
      votes: votes ?? this.votes,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'text': text,
    'votes': votes,
  };

  factory LivePollOption.fromJson(Map<String, dynamic> json, int index) {
    final defaultLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final lbl = json['label']?.toString() ?? (index < defaultLabels.length ? defaultLabels[index] : '${index + 1}');
    return LivePollOption(
      id: json['id']?.toString() ?? 'opt_$index',
      label: lbl,
      text: json['text']?.toString() ?? '',
      votes: (json['votes'] is num) ? (json['votes'] as num).toInt() : 0,
    );
  }
}

/// Full state of the active live poll
class LivePollData {
  String question;
  LivePollType type;
  List<LivePollOption> options;
  int durationSeconds;
  int remainingSeconds;
  int liveViewers;
  bool isLive;
  bool isPaused;
  bool showLiveResult;
  bool allowOptionChange;
  bool autoRefresh;
  DateTime? createdAt;

  LivePollData({
    required this.question,
    this.type = LivePollType.singleChoice,
    required this.options,
    this.durationSeconds = 30,
    this.remainingSeconds = 18,
    this.liveViewers = 2847,
    this.isLive = true,
    this.isPaused = false,
    this.showLiveResult = true,
    this.allowOptionChange = false,
    this.autoRefresh = true,
    this.createdAt,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes);

  double getPercentage(LivePollOption option) {
    final total = totalVotes;
    if (total == 0) return 0.0;
    return (option.votes / total) * 100.0;
  }

  LivePollOption? get leadingOption {
    if (options.isEmpty) return null;
    LivePollOption leader = options.first;
    for (final opt in options) {
      if (opt.votes > leader.votes) {
        leader = opt;
      }
    }
    return leader;
  }

  /// Create default initial data exactly matching the user's reference screenshot
  factory LivePollData.defaultLive() {
    return LivePollData(
      question: 'भारत का राष्ट्रीय पशु कौन है?',
      type: LivePollType.singleChoice,
      durationSeconds: 30,
      remainingSeconds: 18,
      liveViewers: 2847,
      isLive: true,
      isPaused: false,
      showLiveResult: true,
      allowOptionChange: false,
      autoRefresh: true,
      options: [
        LivePollOption(id: '1', label: 'A', text: 'शेर (Lion)', votes: 342, color: AppColors.brandBlue),
        LivePollOption(id: '2', label: 'B', text: 'बाघ (Tiger)', votes: 1937, color: AppColors.brandGreen),
        LivePollOption(id: '3', label: 'C', text: 'हाथी (Elephant)', votes: 399, color: AppColors.brandPurple),
        LivePollOption(id: '4', label: 'D', text: 'हिरण (Deer)', votes: 169, color: AppColors.coinGold),
      ],
      createdAt: DateTime.now(),
    );
  }
}

