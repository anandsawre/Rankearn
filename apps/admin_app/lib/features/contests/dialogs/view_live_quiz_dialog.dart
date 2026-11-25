import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/live_quiz_item.dart';

class _LiveQuizLeaderboardEntry {
  final int rank;
  final String name;
  final double score;
  final int timeTakenSeconds;

  const _LiveQuizLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.timeTakenSeconds,
  });

  String get formattedScore {
    if (score == score.roundToDouble()) {
      return '${score.toInt()} pts';
    }
    return '${score.toStringAsFixed(1)} pts';
  }

  String get formattedTime {
    if (timeTakenSeconds <= 0) return '--';
    final mins = timeTakenSeconds ~/ 60;
    final secs = timeTakenSeconds % 60;
    if (mins > 0) {
      return '${mins}m ${secs.toString().padLeft(2, '0')}s';
    }
    return '${secs}s';
  }
}

class ViewLiveQuizDialog extends StatefulWidget {
  final LiveQuizItem item;

  const ViewLiveQuizDialog({super.key, required this.item});

  @override
  State<ViewLiveQuizDialog> createState() => _ViewLiveQuizDialogState();
}

class _ViewLiveQuizDialogState extends State<ViewLiveQuizDialog> {
  bool _isLoadingLeaderboard = true;
  List<_LiveQuizLeaderboardEntry> _leaderboard = const [];
  int? _liveParticipantCount;

  @override
  void initState() {
    super.initState();
    _loadLiveDetails();
  }

  Future<void> _loadLiveDetails() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoadingLeaderboard = false);
      return;
    }

    try {
      final attemptsRes = await client
          .from('attempts')
          .select('user_id, score, time_taken_seconds, created_at')
          .eq('test_id', widget.item.id)
          .order('score', ascending: false)
          .order('time_taken_seconds', ascending: true)
          .limit(50);

      final rows = List<Map<String, dynamic>>.from(attemptsRes as List);

      // Deduplicate by user_id keeping highest score / fastest time (already sorted)
      final seenUsers = <String>{};
      final uniqueRows = <Map<String, dynamic>>[];
      for (final row in rows) {
        final uid = row['user_id']?.toString() ?? '';
        if (uid.isEmpty || seenUsers.add(uid)) {
          uniqueRows.add(row);
        }
      }

      final userIds = uniqueRows
          .map((r) => r['user_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final profileNames = <String, String>{};
      if (userIds.isNotEmpty) {
        try {
          final profilesRes = await client
              .from('profiles')
              .select('id, name, email')
              .inFilter('id', userIds);
          for (final p in (profilesRes as List)) {
            final pid = p['id']?.toString() ?? '';
            final rawName = p['name']?.toString().trim() ?? '';
            final email = p['email']?.toString().trim() ?? '';
            final displayName = rawName.isNotEmpty
                ? rawName
                : (email.isNotEmpty ? email.split('@').first : 'Participant');
            if (pid.isNotEmpty) {
              profileNames[pid] = displayName;
            }
          }
        } catch (_) {}
      }

      final entries = <_LiveQuizLeaderboardEntry>[];
      for (int i = 0; i < uniqueRows.length && i < 10; i++) {
        final r = uniqueRows[i];
        final uid = r['user_id']?.toString() ?? '';
        final scoreVal = (r['score'] as num?)?.toDouble() ?? 0.0;
        final timeSecs = (r['time_taken_seconds'] as num?)?.toInt() ?? 0;
        entries.add(
          _LiveQuizLeaderboardEntry(
            rank: i + 1,
            name: profileNames[uid] ?? 'Participant #${i + 1}',
            score: scoreVal,
            timeTakenSeconds: timeSecs,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _leaderboard = entries;
          if (uniqueRows.length > widget.item.participantsCount) {
            _liveParticipantCount = uniqueRows.length;
          }
          _isLoadingLeaderboard = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading live quiz leaderboard: $e');
      if (mounted) {
        setState(() => _isLoadingLeaderboard = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final effectiveParticipants =
        _liveParticipantCount ?? item.participantsCount;

    return AppModalDialog(
      title: item.title,
      subtitle: '${item.category} • ${item.statusLabel}',
      iconData: Icons.podcasts_rounded,
      maxWidth: 580,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description
          Text(
            item.description.isNotEmpty ? item.description : 'Live competitive showdown with instant ranking & coin distribution.',
            style: AppTypography.bodySmall.copyWith(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Key Parameters Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadii.cardSubtle,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParam('Category', item.category),
                    _buildParam('Status', item.statusLabel),
                    _buildParam('Duration', '${item.durationMinutes} min'),
                  ],
                ),
                const Divider(height: 20, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParam('Participants', effectiveParticipants.toString()),
                    _buildParam('Questions', item.questionsCount.toString()),
                    _buildParam('Reward Coins', '${item.rewardCoins} pts'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top Leaderboard Preview
          Text(
            'Top Participants / Leaderboard',
            style: AppTypography.titleSmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          if (_isLoadingLeaderboard)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            )
          else if (_leaderboard.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.button,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No participants have submitted attempts for this live quiz yet.',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final entry in _leaderboard)
              _buildLeaderboardRow(
                rank: entry.rank,
                name: entry.name,
                score: entry.formattedScore,
                time: entry.formattedTime,
                avatarColor: _avatarColorForRank(entry.rank),
              ),
        ],
      ),
    );
  }

  Color _avatarColorForRank(int rank) {
    switch (rank) {
      case 1:
        return AppColors.brandPurple;
      case 2:
        return AppColors.brandBlue;
      case 3:
        return AppColors.brandGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildParam(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow({
    required int rank,
    required String name,
    required String score,
    required String time,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: rank == 1 ? AppColors.coinBadgeBackground : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: rank == 1 ? AppColors.coinGold : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: AppTypography.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Text(
            score,
            style: AppTypography.bodySmall.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.brandGreen),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
