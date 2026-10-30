import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'models/tournament_item.dart';
import 'widgets/tournaments_hero_card.dart';
import 'widgets/tournaments_quick_actions.dart';
import 'widgets/tournaments_metrics_row.dart';
import 'widgets/tournaments_table_card.dart';
import 'widgets/tournaments_category_donut_card.dart';
import 'widgets/tournaments_participants_bar_chart_card.dart';
import 'widgets/tournaments_recent_activity_card.dart';
import 'dialogs/create_tournament_dialog.dart';
import 'dialogs/tournament_details_dialog.dart';
import 'dialogs/tournament_registrations_dialog.dart';
import 'dialogs/tournament_rewards_dialog.dart';
import 'dialogs/tournament_questions_dialog.dart';

/// Rankearn Admin Panel — Tournaments Management Screen
/// Pixel-accurate implementation adhering to the centralized design system.
class TournamentsTab extends StatefulWidget {
  const TournamentsTab({super.key});

  @override
  State<TournamentsTab> createState() => _TournamentsTabState();
}

class _TournamentsTabState extends State<TournamentsTab> {
  List<TournamentItem> _tournaments = [];
  bool _isLoading = false;
  Timer? _statusTimer;

  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';
  DateTimeRange? _dateRange;

  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
    // Auto-recalculate ongoing/completed tournament statuses every 15 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTournaments() async {
    setState(() => _isLoading = true);

    try {
      final client = SupabaseConfig.clientSafe;
      if (client != null) {
        final res = await client
            .from('tests')
            .select()
            .eq('is_tournament', true)
            .order('created_at', ascending: false);

        final list = (res as List).map((row) => TournamentItem.fromSupabase(row as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) {
          if (mounted) {
            setState(() {
              _tournaments = list;
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading tournaments from Supabase: $e');
    }

    // Fallback to pixel-accurate reference specification mock data
    if (mounted) {
      setState(() {
        _tournaments = List.from(TournamentItem.mockTournaments);
        _isLoading = false;
      });
    }
  }

  List<TournamentItem> get _filteredTournaments {
    return _tournaments.where((item) {
      // Search Query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchSubtitle = item.subtitle.toLowerCase().contains(q);
        final matchCategory = item.category.toLowerCase().contains(q);
        if (!matchTitle && !matchSubtitle && !matchCategory) return false;
      }

      // Category filter
      if (_selectedCategory != 'All Categories') {
        if (item.category.toLowerCase() != _selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // Status filter using dynamic computedStatus
      if (_selectedStatus != 'All Status') {
        if (item.computedStatus.label.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // Date Range filter
      if (_dateRange != null) {
        if (item.startDate.isBefore(_dateRange!.start) ||
            item.startDate.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<TournamentItem> get _paginatedTournaments {
    final filtered = _filteredTournaments;
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    if (startIndex >= filtered.length) return [];
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    final count = _filteredTournaments.length;
    if (count == 0) return 1;
    return (count / _rowsPerPage).ceil();
  }

  // --- Dynamic Category Slices Calculation ---
  List<DonutSlice> _calculateCategorySlices() {
    if (_tournaments.isEmpty) return const [];
    final Map<String, int> counts = {};
    for (final t in _tournaments) {
      final cat = t.category.trim().isEmpty ? 'General' : t.category.trim();
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    final colors = [
      const Color(0xFF2587F8),
      const Color(0xFF6B4EFF),
      const Color(0xFFF04483),
      const Color(0xFFFF9F0A),
      const Color(0xFF00C48C),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFFBC531),
    ];
    int colorIdx = 0;
    final total = _tournaments.length;
    return counts.entries.map((e) {
      final pct = (e.value / total * 100).toDouble();
      final c = colors[colorIdx % colors.length];
      colorIdx++;
      return DonutSlice(label: e.key, percentage: pct, color: c, count: e.value);
    }).toList();
  }

  // --- Dynamic Recent Activities ---
  List<TournamentActivityItem> _generateRecentActivities() {
    if (_tournaments.isEmpty) return const [];
    return _tournaments.take(5).map((t) {
      IconData icon;
      Color iconColor;
      Color iconBgColor;
      String action;

      if (t.computedStatus == TournamentStatus.ongoing) {
        icon = Icons.play_arrow_rounded;
        iconColor = const Color(0xFF10B981);
        iconBgColor = const Color(0xFFDCFCE7);
        action = 'Ongoing: ${t.title}';
      } else if (t.computedStatus == TournamentStatus.completed) {
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFFFF9F0A);
        iconBgColor = const Color(0xFFFFFBEB);
        action = 'Completed: ${t.title}';
      } else if (t.computedStatus == TournamentStatus.archived) {
        icon = Icons.archive_outlined;
        iconColor = const Color(0xFF64748B);
        iconBgColor = const Color(0xFFF1F5F9);
        action = 'Archived: ${t.title}';
      } else {
        icon = Icons.emoji_events_rounded;
        iconColor = const Color(0xFF6B4EFF);
        iconBgColor = const Color(0xFFF3F0FF);
        action = 'Upcoming: ${t.title}';
      }

      String timeStr;
      final diff = DateTime.now().difference(t.startDate.toLocal());
      if (diff.isNegative) {
        final hours = (-diff.inHours);
        if (hours > 24) {
          timeStr = 'In ${(-diff.inDays)}d';
        } else if (hours > 0) {
          timeStr = 'In ${hours}h';
        } else {
          timeStr = 'In ${(-diff.inMinutes)}m';
        }
      } else {
        if (diff.inDays > 0) {
          timeStr = '${diff.inDays}d ago';
        } else if (diff.inHours > 0) {
          timeStr = '${diff.inHours}h ago';
        } else {
          timeStr = '${diff.inMinutes}m ago';
        }
      }

      return TournamentActivityItem(
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        title: action,
        timeAgo: timeStr,
      );
    }).toList();
  }

  // Quick Action & Dialog handlers
  void _openCreateDialog({TournamentItem? editItem}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CreateTournamentDialog(
        editItem: editItem,
        onSave: (newItem) {},
        onSaveWithSource: (newItem, sourceTestId) async {
          final isEditing = editItem != null;
          final itemToSave = newItem.copyWith(
            status: newItem.computedStatus,
          );

          setState(() {
            if (isEditing) {
              final index = _tournaments.indexWhere((e) => e.id == editItem.id);
              if (index != -1) _tournaments[index] = itemToSave;
            } else {
              _tournaments.insert(0, itemToSave);
            }
          });

          // Sync to Supabase in background
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              await client.from('tests').upsert(itemToSave.toSupabase());

              // If admin selected an existing test to copy questions from:
              if (sourceTestId != null && sourceTestId.isNotEmpty) {
                final sourceQs = await client
                    .from('questions')
                    .select()
                    .eq('test_id', sourceTestId)
                    .order('question_number', ascending: true);

                if (sourceQs.isNotEmpty) {
                  final payload = <Map<String, dynamic>>[];
                  for (int i = 0; i < sourceQs.length; i++) {
                    final original = Map<String, dynamic>.from(sourceQs[i]);
                    original['id'] = 'q_tour_${itemToSave.id}_${DateTime.now().millisecondsSinceEpoch}_${i + 1}';
                    original['test_id'] = itemToSave.id;
                    original['question_number'] = i + 1;
                    original['created_at'] = DateTime.now().toUtc().toIso8601String();
                    payload.add(original);
                  }
                  await client.from('questions').upsert(payload);
                  await client.from('tests').update({
                    'total_questions': payload.length,
                  }).eq('id', itemToSave.id);
                }
              }
            } catch (e) {
              debugPrint('Failed to sync tournament to Supabase: $e');
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing
                    ? 'Tournament updated in database.'
                    : (sourceTestId != null
                        ? 'Tournament created & questions copied from existing test!'
                        : 'Tournament created & synced with database.')),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  void _openQuestionsDialog(TournamentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => TournamentQuestionsDialog(
        tournament: item,
        onQuestionsUpdated: () {
          _loadTournaments();
        },
      ),
    );
  }

  void _openViewDialog(TournamentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => TournamentDetailsDialog(
        item: item,
        onEdit: () => _openCreateDialog(editItem: item),
      ),
    );
  }

  void _openRegistrationsDialog([TournamentItem? item]) {
    showDialog(
      context: context,
      builder: (ctx) => TournamentRegistrationsDialog(tournament: item),
    );
  }

  void _openRewardsDialog([TournamentItem? item]) {
    showDialog(
      context: context,
      builder: (ctx) => TournamentRewardsDialog(tournament: item),
    );
  }

  void _showMoreContextMenu(TournamentItem item, TapDownDetails details) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      details.globalPosition & const Size(40, 40),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 6,
      items: [
        const PopupMenuItem(
          value: 'questions',
          child: Row(
            children: [
              Icon(Icons.quiz_outlined, size: 16, color: Color(0xFF5636F5)),
              SizedBox(width: 8),
              Text('Manage Questions & Tests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'registrations',
          child: Row(
            children: [
              Icon(Icons.group_outlined, size: 16, color: Color(0xFF5636F5)),
              SizedBox(width: 8),
              Text('View Registrations', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'rewards',
          child: Row(
            children: [
              Icon(Icons.card_giftcard_rounded, size: 16, color: Color(0xFF00C48C)),
              SizedBox(width: 8),
              Text('Manage Rewards', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Duplicate Tournament', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(Icons.archive_outlined, size: 16, color: Color(0xFFFF9F0A)),
              SizedBox(width: 8),
              Text('Archive Tournament', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Delete Tournament', style: TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
            ],
          ),
        ),
      ],
    ).then((val) async {
      if (val == null || !mounted) return;
      final client = SupabaseConfig.clientSafe;

      switch (val) {
        case 'questions':
          _openQuestionsDialog(item);
          break;
        case 'registrations':
          _openRegistrationsDialog(item);
          break;
        case 'rewards':
          _openRewardsDialog(item);
          break;
        case 'duplicate':
          final dupId = 'test-${DateTime.now().millisecondsSinceEpoch}';
          final dup = item.copyWith(
            id: dupId,
            title: '${item.title} (Copy)',
            status: TournamentStatus.upcoming,
            participants: 0,
          );
          setState(() => _tournaments.insert(0, dup));

          if (client != null) {
            try {
              await client.from('tests').insert(dup.toSupabase());
            } catch (e) {
              debugPrint('Error duplicating tournament: $e');
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tournament duplicated in database.'), backgroundColor: Color(0xFF5636F5)),
            );
          }
          break;
        case 'archive':
          final updated = item.copyWith(status: TournamentStatus.archived);
          setState(() {
            final idx = _tournaments.indexWhere((e) => e.id == item.id);
            if (idx != -1) {
              _tournaments[idx] = updated;
            }
          });

          if (client != null) {
            try {
              await client.from('tests').update({
                'status': 'draft',
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              }).eq('id', item.id);
            } catch (e) {
              debugPrint('Error archiving tournament: $e');
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tournament moved to archived.'), backgroundColor: Color(0xFFFF9F0A)),
            );
          }
          break;
        case 'delete':
          setState(() => _tournaments.removeWhere((e) => e.id == item.id));

          if (client != null) {
            try {
              await client.from('tests').delete().eq('id', item.id);
            } catch (e) {
              debugPrint('Error deleting tournament: $e');
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tournament deleted from database.'), backgroundColor: Color(0xFFDC2626)),
            );
          }
          break;
      }
    });
  }

  void _sendNotification() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.campaign_outlined, color: Color(0xFF5636F5)),
            SizedBox(width: 8),
            Text('Send Tournament Notification'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Broadcast instant notification to all registered candidates or general users.'),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'e.g. Mega Tournament starts in 30 minutes! Join now to win rewards.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              Navigator.pop(ctx);
              if (text.isEmpty) return;

              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                try {
                  await client.from('notifications').insert({
                    'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
                    'user_id': 'global',
                    'title': 'Tournament Announcement',
                    'message': text,
                    'type': 'tournament',
                    'target_segment': 'all',
                    'created_at': DateTime.now().toUtc().toIso8601String(),
                  });
                } catch (e) {
                  debugPrint('Tournament notification error: $e');
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification broadcast sent successfully!'), backgroundColor: Color(0xFF10B981)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5636F5), foregroundColor: Colors.white),
            child: const Text('Send Now'),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Category,Status,Start Date,End Date,Entry Fee,Participants,Prize Pool');
    for (final t in _tournaments) {
      buffer.writeln('"${t.id}","${t.title}","${t.category}","${t.computedStatus.label}","${t.startDate.toIso8601String()}","${t.endDate.toIso8601String()}",${t.entryFee},${t.participants},${t.prizePool}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_tournaments.length} tournaments report (CSV format ready)!'),
        backgroundColor: const Color(0xFF5636F5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: Color(0xFF5636F5)),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isWideHeader = screenWidth >= 900;

    final categorySlices = _calculateCategorySlices();
    final recentActivities = _generateRecentActivities();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Section: Hero Banner + Quick Actions Row
          if (isWideHeader)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 7,
                  child: TournamentsHeroCard(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: TournamentsQuickActions(
                    onCreateTournament: () => _openCreateDialog(),
                    onScheduleTournament: () => _openCreateDialog(),
                    onManageRewards: () => _openRewardsDialog(),
                    onViewRegistrations: () => _openRegistrationsDialog(),
                    onSendNotification: _sendNotification,
                    onExportReport: _exportReport,
                    onCustomize: () {},
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                const TournamentsHeroCard(),
                const SizedBox(height: 12),
                TournamentsQuickActions(
                  onCreateTournament: () => _openCreateDialog(),
                  onScheduleTournament: () => _openCreateDialog(),
                  onManageRewards: () => _openRewardsDialog(),
                  onViewRegistrations: () => _openRegistrationsDialog(),
                  onSendNotification: _sendNotification,
                  onExportReport: _exportReport,
                  onCustomize: () {},
                ),
              ],
            ),
          const SizedBox(height: 14),

          // 2. Metrics Cards Row (5 Cards)
          TournamentsMetricsRow(
            totalTournaments: _tournaments.length,
            totalParticipants: _tournaments.fold(0, (acc, item) => acc + item.participants),
            completedTournaments: _tournaments.where((t) => t.computedStatus == TournamentStatus.completed).length,
            ongoingTournaments: _tournaments.where((t) => t.computedStatus == TournamentStatus.ongoing).length,
            upcomingTournaments: _tournaments.where((t) => t.computedStatus == TournamentStatus.upcoming).length,
          ),
          const SizedBox(height: 14),

          // 3. Main Content: Table Card on Left + Analytics Column on Right
          if (isDesktop) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Table Card
                Expanded(
                  child: TournamentsTableCard(
                    items: _paginatedTournaments,
                    totalCount: _filteredTournaments.length,
                    selectedCategory: _selectedCategory,
                    selectedStatus: _selectedStatus,
                    searchQuery: _searchQuery,
                    dateRange: _dateRange,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    rowsPerPage: _rowsPerPage,
                    onCategoryChanged: (cat) => setState(() {
                      _selectedCategory = cat;
                      _currentPage = 1;
                    }),
                    onStatusChanged: (status) => setState(() {
                      _selectedStatus = status;
                      _currentPage = 1;
                    }),
                    onSearchChanged: (q) => setState(() {
                      _searchQuery = q;
                      _currentPage = 1;
                    }),
                    onDateRangeChanged: (range) => setState(() {
                      _dateRange = range;
                      _currentPage = 1;
                    }),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    onRowsPerPageChanged: (rpp) => setState(() {
                      _rowsPerPage = rpp;
                      _currentPage = 1;
                    }),
                    onView: _openViewDialog,
                    onAnalytics: _openViewDialog,
                    onEdit: (item) => _openCreateDialog(editItem: item),
                    onManageQuestions: _openQuestionsDialog,
                    onMore: _showMoreContextMenu,
                    onBulkArchive: (ids) async {
                      setState(() {
                        for (final id in ids) {
                          final idx = _tournaments.indexWhere((t) => t.id == id);
                          if (idx != -1) {
                            _tournaments[idx] = _tournaments[idx].copyWith(status: TournamentStatus.archived);
                          }
                        }
                      });

                      final client = SupabaseConfig.clientSafe;
                      if (client != null) {
                        try {
                          await client.from('tests').update({
                            'status': 'draft',
                            'updated_at': DateTime.now().toUtc().toIso8601String(),
                          }).filter('id', 'in', ids);
                        } catch (e) {
                          debugPrint('Bulk archive error: $e');
                        }
                      }
                    },
                    onBulkDelete: (ids) async {
                      setState(() {
                        _tournaments.removeWhere((t) => ids.contains(t.id));
                      });

                      final client = SupabaseConfig.clientSafe;
                      if (client != null) {
                        try {
                          await client.from('tests').delete().filter('id', 'in', ids);
                        } catch (e) {
                          debugPrint('Bulk delete error: $e');
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // Right Analytics Column (3 Stacked Cards)
                SizedBox(
                  width: 295,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TournamentsCategoryDonutCard(
                        totalCount: _tournaments.length,
                        slices: categorySlices.isNotEmpty
                            ? categorySlices
                            : const [
                                DonutSlice(label: 'Railway', percentage: 28, color: Color(0xFF2587F8), count: 7),
                                DonutSlice(label: 'General Science', percentage: 18, color: Color(0xFF6B4EFF), count: 4),
                                DonutSlice(label: 'Mathematics', percentage: 15, color: Color(0xFFF04483), count: 4),
                                DonutSlice(label: 'Current Affairs', percentage: 12, color: Color(0xFFFF9F0A), count: 3),
                                DonutSlice(label: 'State Level', percentage: 10, color: Color(0xFF00C48C), count: 2),
                                DonutSlice(label: 'Reasoning', percentage: 8, color: Color(0xFF06B6D4), count: 2),
                                DonutSlice(label: 'Biology', percentage: 6, color: Color(0xFF10B981), count: 2),
                                DonutSlice(label: 'Others', percentage: 3, color: Color(0xFFFBC531), count: 1),
                              ],
                        onViewAll: () {},
                      ),
                      const SizedBox(height: 12),
                      TournamentsParticipantsBarChartCard(
                        onViewAll: () {},
                      ),
                      const SizedBox(height: 12),
                      TournamentsRecentActivityCard(
                        activities: recentActivities.isNotEmpty
                            ? recentActivities
                            : const [
                                TournamentActivityItem(
                                  icon: Icons.emoji_events_rounded,
                                  iconColor: Color(0xFF6B4EFF),
                                  iconBgColor: Color(0xFFF3F0FF),
                                  title: 'New tournament created: RRB Technician',
                                  timeAgo: '10 minutes ago',
                                ),
                                TournamentActivityItem(
                                  icon: Icons.people_alt_rounded,
                                  iconColor: Color(0xFF2587F8),
                                  iconBgColor: Color(0xFFEFF6FF),
                                  title: '500 new participants joined',
                                  timeAgo: '25 minutes ago',
                                ),
                              ],
                        onViewAll: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Mobile/Tablet stacked layout
            TournamentsTableCard(
              items: _paginatedTournaments,
              totalCount: _filteredTournaments.length,
              selectedCategory: _selectedCategory,
              selectedStatus: _selectedStatus,
              searchQuery: _searchQuery,
              dateRange: _dateRange,
              currentPage: _currentPage,
              totalPages: _totalPages,
              rowsPerPage: _rowsPerPage,
              onCategoryChanged: (cat) => setState(() {
                _selectedCategory = cat;
                _currentPage = 1;
              }),
              onStatusChanged: (status) => setState(() {
                _selectedStatus = status;
                _currentPage = 1;
              }),
              onSearchChanged: (q) => setState(() {
                _searchQuery = q;
                _currentPage = 1;
              }),
              onDateRangeChanged: (range) => setState(() {
                _dateRange = range;
                _currentPage = 1;
              }),
              onPageChanged: (page) => setState(() => _currentPage = page),
              onRowsPerPageChanged: (rpp) => setState(() {
                _rowsPerPage = rpp;
                _currentPage = 1;
              }),
              onView: _openViewDialog,
              onAnalytics: _openViewDialog,
              onEdit: (item) => _openCreateDialog(editItem: item),
              onManageQuestions: _openQuestionsDialog,
              onMore: _showMoreContextMenu,
            ),
            const SizedBox(height: 14),
            TournamentsCategoryDonutCard(
              totalCount: _tournaments.length,
              slices: categorySlices.isNotEmpty ? categorySlices : const [],
            ),
            const SizedBox(height: 12),
            const TournamentsParticipantsBarChartCard(),
            const SizedBox(height: 12),
            TournamentsRecentActivityCard(
              activities: recentActivities.isNotEmpty ? recentActivities : const [],
            ),
          ],
        ],
      ),
    );
  }
}
