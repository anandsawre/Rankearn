/// Single option in a Poll
class PollOptionItem {
  final int index;
  final String label; // 'A', 'B', 'C', 'D'
  final String text;
  final int votes;

  const PollOptionItem({
    required this.index,
    required this.label,
    required this.text,
    this.votes = 0,
  });

  PollOptionItem copyWith({
    int? index,
    String? label,
    String? text,
    int? votes,
  }) {
    return PollOptionItem(
      index: index ?? this.index,
      label: label ?? this.label,
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'votes': votes,
  };

  factory PollOptionItem.fromDynamic(dynamic raw, int idx, int votesCount) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final lbl = idx < letters.length ? letters[idx] : '${idx + 1}';
    if (raw is Map) {
      return PollOptionItem(
        index: idx,
        label: raw['label']?.toString() ?? lbl,
        text: raw['text']?.toString() ?? 'Option ${idx + 1}',
        votes: votesCount,
      );
    }
    return PollOptionItem(
      index: idx,
      label: lbl,
      text: raw?.toString() ?? 'Option ${idx + 1}',
      votes: votesCount,
    );
  }
}

/// Domain Model for Community & Live Polls
class PollModel {
  final String id;
  final String question;
  final List<PollOptionItem> options;
  final Map<String, int> votes;
  final String targetSegment;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const PollModel({
    required this.id,
    required this.question,
    required this.options,
    required this.votes,
    this.targetSegment = 'all',
    this.isActive = true,
    this.expiresAt,
    this.createdAt,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes);

  double getPercentage(PollOptionItem option) {
    final total = totalVotes;
    if (total == 0) return 0.0;
    return (option.votes / total) * 100.0;
  }

  PollOptionItem? get leadingOption {
    if (options.isEmpty) return null;
    PollOptionItem leader = options.first;
    for (final opt in options) {
      if (opt.votes > leader.votes) {
        leader = opt;
      }
    }
    return leader;
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get remainingSeconds {
    if (expiresAt == null) return 0;
    final diff = expiresAt!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final votesRaw = json['votes'];
    final Map<String, int> parsedVotes = {};
    if (votesRaw is Map) {
      votesRaw.forEach((k, v) {
        if (v is num) {
          parsedVotes[k.toString()] = v.toInt();
        }
      });
    }

    final rawOptions = json['options'];
    final List<PollOptionItem> parsedOptions = [];
    if (rawOptions is List) {
      for (int i = 0; i < rawOptions.length; i++) {
        final votesCount = parsedVotes['$i'] ?? 0;
        parsedOptions.add(PollOptionItem.fromDynamic(rawOptions[i], i, votesCount));
      }
    }

    return PollModel(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: parsedOptions,
      votes: parsedVotes,
      targetSegment: json['target_segment']?.toString() ?? 'all',
      isActive: json['is_active'] == true,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options.map((o) => o.toJson()).toList(),
    'votes': votes,
    'target_segment': targetSegment,
    'is_active': isActive,
    'expires_at': expiresAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}
