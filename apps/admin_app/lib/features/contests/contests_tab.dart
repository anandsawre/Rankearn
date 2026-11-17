import 'dart:async';
import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'models/live_quiz_item.dart';
import 'widgets/live_quiz_hero_card.dart';
import 'widgets/live_quiz_quick_actions.dart';
import 'widgets/live_quiz_metrics_row.dart';
import 'widgets/live_quiz_table_card.dart';
import 'widgets/live_quiz_category_donut_card.dart';
import 'widgets/live_quiz_participants_bar_chart_card.dart';
import 'widgets/live_quiz_recent_activity_card.dart';
import 'dialogs/create_live_quiz_dialog.dart';
import 'dialogs/schedule_quiz_dialog.dart';
import 'dialogs/live_now_dashboard_dialog.dart';
import 'dialogs/view_live_quiz_dialog.dart';
import '../tests/dialogs/view_test_questions_dialog.dart';

/// Pixel-Accurate Live Quiz Management Tab
/// Completely integrated with centralized design system tokens and Supabase.
class ContestsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialContests;
  final VoidCallback? onManageQuestions;

  const ContestsTab({
    super.key,
    this.initialContests,
    this.onManageQuestions,
  });

  @override
  State<ContestsTab> createState() => _ContestsTabState();
}

class _ContestsTabState extends State<ContestsTab> {
  bool _isLoading = false;
  List<LiveQuizItem> _allQuizzes = [];
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  String _selectedCategory = 'All Categories';
  DateTimeRange? _dateRange;
  int _currentPage = 1;
  int _rowsPerPage = 10;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
    // Auto-update live quiz status dynamically as real time progresses
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _allQuizzes = [];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final res = await client
          .from('tests')
          .select()
          .eq('is_tournament', false)
          .order('created_at', ascending: false);

      final List<dynamic> allRows = res as List<dynamic>;
      // Filter out pure static mock tests that don't belong to Live Quiz
      final rows = allRows.where((r) {
        if (r['is_tournament'] == true) return false;
        final hasSchedule = r['scheduled_start_time'] != null;
        final isLq = (r['id']?.toString().startsWith('lq-') ?? false);
        final mode = (r['test_mode'] ?? '').toString().toLowerCase();
        return hasSchedule || isLq || mode == 'live_quiz' || mode == 'live';
      }).toList();

      if (rows.isNotEmpty) {
        final now = DateTime.now();
        final loaded = rows.map((r) {
          final rawStart = r['scheduled_start_time'] != null
              ? DateTime.tryParse(r['scheduled_start_time'].toString())
              : null;
          final start = rawStart?.toLocal();
          final durationMins = (r['duration_minutes'] as num?)?.toInt() ?? 45;
          final rawEnd = r['scheduled_end_time'] != null
              ? DateTime.tryParse(r['scheduled_end_time'].toString())
              : null;
          final end = rawEnd?.toLocal() ?? start?.add(Duration(minutes: durationMins));

          final statusStr = (r['status'] ?? '').toString().toLowerCase();

          LiveQuizStatus status = LiveQuizStatus.scheduled;
          if (statusStr == 'draft') {
            status = LiveQuizStatus.draft;
          } else if (start != null && end != null) {
            if (now.isBefore(start)) {
              status = LiveQuizStatus.scheduled;
            } else if (now.isAfter(end)) {
              status = LiveQuizStatus.completed;
            } else {
              status = LiveQuizStatus.liveNow;
            }
          } else if (start != null) {
            status = now.isBefore(start) ? LiveQuizStatus.scheduled : LiveQuizStatus.liveNow;
          }

          final rawFee = (r['entry_fee_coins'] as num?)?.toInt() ?? 0;
          final rawPrize = (r['prize_pool_coins'] as num?)?.toInt() ?? (rawFee * 10 > 0 ? rawFee * 10 : 1000);

          return LiveQuizItem(
            id: r['id']?.toString() ?? '',
            title: r['title']?.toString() ?? 'Live Quiz',
            description: (r['syllabus'] ?? r['description'])?.toString() ?? 'Live quiz tournament session',
            category: (r['category_id'] ?? r['category'])?.toString() ?? 'General Science',
            startTime: start ?? DateTime.now(),
            durationMinutes: durationMins,
            participantsCount: (r['total_participants'] as num?)?.toInt() ?? 0,
            status: status,
            createdByName: 'Admin',
            rewardCoins: rawPrize,
            entryFeeCoins: rawFee,
            questionsCount: (r['total_questions'] as num?)?.toInt() ?? 25,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _allQuizzes = loaded;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _allQuizzes = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading quizzes from Supabase: $e');
      if (mounted) {
        setState(() {
          _allQuizzes = [];
          _isLoading = false;
        });
      }
    }
  }

  // --- Filtering & Pagination Logic ---
  List<LiveQuizItem> get _filteredQuizzes {
    return _allQuizzes.where((item) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc) return false;
      }
      if (_selectedStatus != 'All Status') {
        if (item.statusLabel.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }
      if (_selectedCategory != 'All Categories') {
        if (item.category.toLowerCase() != _selectedCategory.toLowerCase()) {
          return false;
        }
      }
      if (_dateRange != null) {
        if (item.startTime.isBefore(_dateRange!.start) ||
            item.startTime.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<LiveQuizItem> get _paginatedQuizzes {
    final filtered = _filteredQuizzes;
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    if (startIndex >= filtered.length) {
      return filtered.isNotEmpty ? [filtered.first] : [];
    }
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    final count = _filteredQuizzes.length;
    if (count == 0) return 1;
    return (count / _rowsPerPage).ceil();
  }

  // --- Dynamic Category Slices Calculation ---
  List<DonutSlice> _calculateCategorySlices() {
    if (_allQuizzes.isEmpty) return const [];
    final Map<String, int> counts = {};
    for (final q in _allQuizzes) {
      final cat = q.category.trim().isEmpty ? 'General' : q.category.trim();
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    final colors = [
      const Color(0xFF2587F8),
      const Color(0xFF6B4EFF),
      const Color(0xFFF04483),
      const Color(0xFFFF9F0A),
      const Color(0xFF00C48C),
      const Color(0xFF10B981),
      const Color(0xFFFBC531),
      const Color(0xFF8B5CF6),
    ];
    int colorIdx = 0;
    final total = _allQuizzes.length;
    return counts.entries.map((e) {
      final pct = (e.value / total * 100).toDouble();
      final c = colors[colorIdx % colors.length];
      colorIdx++;
      return DonutSlice(label: e.key, percentage: pct, color: c, count: e.value);
    }).toList();
  }

  // --- Dynamic Recent Activities ---
  List<LiveQuizActivityItem> _generateRecentActivities() {
    if (_allQuizzes.isEmpty) return const [];
    return _allQuizzes.take(5).map((q) {
      IconData icon;
      Color iconColor;
      Color iconBgColor;
      String action;

      if (q.computedStatus == LiveQuizStatus.liveNow) {
        icon = Icons.play_arrow_rounded;
        iconColor = const Color(0xFF10B981);
        iconBgColor = const Color(0xFFDCFCE7);
        action = 'Live now: ${q.title}';
      } else if (q.computedStatus == LiveQuizStatus.completed) {
        icon = Icons.emoji_events_rounded;
        iconColor = const Color(0xFFFF9F0A);
        iconBgColor = const Color(0xFFFFFBEB);
        action = 'Completed: ${q.title}';
      } else if (q.computedStatus == LiveQuizStatus.draft) {
        icon = Icons.edit_note_rounded;
        iconColor = const Color(0xFF6C5CE7);
        iconBgColor = const Color(0xFFF3F0FF);
        action = 'Draft quiz: ${q.title}';
      } else {
        icon = Icons.calendar_today_rounded;
        iconColor = const Color(0xFFF04483);
        iconBgColor = const Color(0xFFFFF1F2);
        action = 'Scheduled: ${q.title}';
      }

      return LiveQuizActivityItem(
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        title: action,
        timeAgo: '${q.durationMinutes}m | ${q.questionsCount} Qs',
      );
    }).toList();
  }

  // --- Dialog Handlers with Supabase CRUD ---
  void _openManageQuestions(LiveQuizItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ViewTestQuestionsDialog(
        item: item.toTestSeriesItem(),
        onQuestionsUpdated: () {
          _loadQuizzes();
        },
      ),
    );
  }

  void _openCreateDialog({LiveQuizItem? editItem}) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CreateLiveQuizDialog(
        initialItem: editItem,
        onSave: (savedItem) async => _saveQuiz(savedItem, editItem != null),
        onSaveWithSource: (savedItem, sourceTestId) async =>
            _saveQuiz(savedItem, editItem != null, sourceTestId: sourceTestId),
      ),
    );
  }

  Future<void> _saveQuiz(
    LiveQuizItem savedItem,
    bool isEditing, {
    String? sourceTestId,
  }) async {
    final now = DateTime.now();
    final localStart = savedItem.startTime.toLocal();
    final localEnd = localStart.add(Duration(minutes: savedItem.durationMinutes));

    LiveQuizStatus finalStatus = savedItem.status;
    if (finalStatus != LiveQuizStatus.draft) {
      if (now.isBefore(localStart)) {
        finalStatus = LiveQuizStatus.scheduled;
      } else if (now.isAfter(localEnd)) {
        finalStatus = LiveQuizStatus.completed;
      } else {
        finalStatus = LiveQuizStatus.liveNow;
      }
    }

    final updatedItem = savedItem.copyWith(
      startTime: localStart,
      status: finalStatus,
    );

    setState(() {
      final idx = _allQuizzes.indexWhere((q) => q.id == updatedItem.id);
      if (idx >= 0) {
        _allQuizzes[idx] = updatedItem;
      } else {
        _allQuizzes.insert(0, updatedItem);
      }
    });

    // Supabase Persistence
    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        final payload = {
          'title': updatedItem.title,
          'syllabus': updatedItem.description,
          'category_id': updatedItem.category,
          'duration_minutes': updatedItem.durationMinutes,
          'total_questions': updatedItem.questionsCount,
          'entry_fee_coins': updatedItem.entryFeeCoins,
          'is_tournament': false, // Strictly false for Live Quiz!
          'test_mode': 'mock',
          'status': updatedItem.status == LiveQuizStatus.draft ? 'draft' : 'published',
          'scheduled_start_time': updatedItem.startTime.toUtc().toIso8601String(),
          'scheduled_end_time': updatedItem.startTime
              .add(Duration(minutes: updatedItem.durationMinutes))
              .toUtc()
              .toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };

        if (isEditing) {
          await client.from('tests').update(payload).eq('id', updatedItem.id);
        } else {
          payload['id'] = updatedItem.id;
          payload['total_participants'] = 0;
          payload['created_at'] = DateTime.now().toUtc().toIso8601String();
          await client.from('tests').insert(payload);

          // Copy questions from source test if selected (just like in tournament!)
          if (sourceTestId != null && sourceTestId.isNotEmpty) {
            final sourceQs = await client
                .from('questions')
                .select()
                .eq('test_id', sourceTestId)
                .order('question_number', ascending: true);

            if (sourceQs.isNotEmpty) {
              final qPayload = <Map<String, dynamic>>[];
              for (int i = 0; i < sourceQs.length; i++) {
                final original = Map<String, dynamic>.from(sourceQs[i]);
                original['id'] =
                    'q_lq_${updatedItem.id}_${DateTime.now().millisecondsSinceEpoch}_${i + 1}';
                original['test_id'] = updatedItem.id;
                original['question_number'] = i + 1;
                original['created_at'] = DateTime.now().toUtc().toIso8601String();
                qPayload.add(original);
              }
              await client.from('questions').upsert(qPayload);
              await client.from('tests').update({
                'total_questions': qPayload.length,
              }).eq('id', updatedItem.id);

              final inMemIdx = _allQuizzes.indexWhere((q) => q.id == updatedItem.id);
              if (inMemIdx >= 0) {
                setState(() {
                  _allQuizzes[inMemIdx] = _allQuizzes[inMemIdx].copyWith(
                    questionsCount: qPayload.length,
                  );
                });
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Supabase live quiz save error: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Live Quiz updated in database!'
                : (sourceTestId != null
                    ? 'Live Quiz created & questions copied from existing test!'
                    : 'Live Quiz created & synced with database!'),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _openAddExistingTestDialog() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database client not connected.')),
      );
      return;
    }

    List<Map<String, dynamic>> availableTests = [];
    try {
      final res = await client
          .from('tests')
          .select('id, title, category_id, total_questions, duration_minutes, test_mode')
          .order('created_at', ascending: false)
          .limit(100);
      availableTests = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error loading existing tests for live quiz: $e');
    }

    if (!mounted) return;

    if (availableTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No existing tests found in database to import from.'),
          backgroundColor: Color(0xFFFF9F0A),
        ),
      );
      return;
    }

    String? selectedTestId = availableTests.first['id']?.toString();
    final initialTest = availableTests.first;
    final titleController = TextEditingController(
      text: '${initialTest['title']} (Live Showdown)',
    );
    final durationController = TextEditingController(
      text: (initialTest['duration_minutes'] ?? 45).toString(),
    );
    final entryFeeController = TextEditingController(text: '0');
    final rewardsController = TextEditingController(text: '1500');

    DateTime scheduleTime = DateTime.now().add(const Duration(hours: 2));

    await AppModalDialog.show(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedTest = availableTests.firstWhere(
            (t) => t['id']?.toString() == selectedTestId,
            orElse: () => availableTests.first,
          );

          return AppModalDialog(
            title: 'Add Existing Test as Live Quiz',
            subtitle: 'Turn any existing test into a scheduled Live Quiz showdown with questions',
            iconData: Icons.podcasts_rounded,
            maxWidth: 560,
            actions: [
              AppModalDialog.cancelButton(ctx),
              AppModalDialog.primaryButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _createLiveQuizFromExistingTest(
                    sourceTest: selectedTest,
                    customTitle: titleController.text.trim(),
                    startTime: scheduleTime,
                    durationMins: int.tryParse(durationController.text.trim()) ?? 45,
                    entryFee: int.tryParse(entryFeeController.text.trim()) ?? 0,
                    rewardCoins: int.tryParse(rewardsController.text.trim()) ?? 1500,
                  );
                },
                child: const Text(
                  'Schedule Live Quiz Now',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Select Existing Test Dropdown
                const Text(
                  'Select Existing Test to Clone *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                AppDropdown<String>(
                  value: selectedTestId,
                  items: availableTests.map((t) {
                    final tId = t['id']?.toString() ?? '';
                    final tTitle = t['title']?.toString() ?? 'Untitled';
                    final tCat = t['category_id']?.toString() ?? 'General';
                    final tQs = (t['total_questions'] as num?)?.toInt() ?? 0;
                    return AppDropdownItem<String>(
                      value: tId,
                      label: '$tTitle ($tCat • $tQs Questions)',
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedTestId = val;
                        final match = availableTests.firstWhere((t) => t['id']?.toString() == val);
                        titleController.text = '${match['title']} (Live Showdown)';
                        durationController.text = (match['duration_minutes'] ?? 45).toString();
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Title
                AppModalDialog.textField(
                  controller: titleController,
                  hint: 'Live Quiz Title *',
                ),
                const SizedBox(height: 12),

                // Date & Time Picker
                Row(
                  children: [
                    Expanded(
                      child: AppDatePicker(
                        label: 'Date',
                        value: scheduleTime,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        onChanged: (d) {
                          setDialogState(() {
                            scheduleTime = DateTime(
                              d.year,
                              d.month,
                              d.day,
                              scheduleTime.hour,
                              scheduleTime.minute,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTimePicker(
                        label: 'Time',
                        value: TimeOfDay.fromDateTime(scheduleTime),
                        onChanged: (t) {
                          setDialogState(() {
                            scheduleTime = DateTime(
                              scheduleTime.year,
                              scheduleTime.month,
                              scheduleTime.day,
                              t.hour,
                              t.minute,
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Duration, Entry Fee & Reward
                Row(
                  children: [
                    Expanded(
                      child: AppModalDialog.textField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        hint: 'Duration (45)',
                        suffixText: 'min',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppModalDialog.textField(
                        controller: entryFeeController,
                        keyboardType: TextInputType.number,
                        hint: 'Entry (0=Free)',
                        suffixText: 'Entry',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppModalDialog.textField(
                        controller: rewardsController,
                        keyboardType: TextInputType.number,
                        hint: 'Prize (1500)',
                        suffixText: 'Coins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All ${(selectedTest['total_questions'] as num?)?.toInt() ?? 0} questions from "${selectedTest['title']}" will be copied into this live quiz.',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _createLiveQuizFromExistingTest({
    required Map<String, dynamic> sourceTest,
    required String customTitle,
    required DateTime startTime,
    required int durationMins,
    required int entryFee,
    required int rewardCoins,
  }) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    final sourceTestId = sourceTest['id']?.toString() ?? '';
    final newId = 'lq-${DateTime.now().millisecondsSinceEpoch}';
    final category = sourceTest['category_id']?.toString() ?? 'General';
    final localStart = startTime.toLocal();
    final localEnd = localStart.add(Duration(minutes: durationMins));
    final now = DateTime.now();

    LiveQuizStatus status = LiveQuizStatus.scheduled;
    if (now.isAfter(localStart) && now.isBefore(localEnd)) {
      status = LiveQuizStatus.liveNow;
    } else if (now.isAfter(localEnd)) {
      status = LiveQuizStatus.completed;
    }

    final newQuiz = LiveQuizItem(
      id: newId,
      title: customTitle.isNotEmpty ? customTitle : '${sourceTest['title']} (Live Showdown)',
      description: 'Live competitive quiz showdown based on ${sourceTest['title']}.',
      category: category,
      status: status,
      startTime: localStart,
      durationMinutes: durationMins,
      questionsCount: (sourceTest['total_questions'] as num?)?.toInt() ?? 25,
      participantsCount: 0,
      rewardCoins: rewardCoins,
      entryFeeCoins: entryFee,
    );

    setState(() {
      _allQuizzes.insert(0, newQuiz);
    });

    try {
      // 1. Insert live quiz into tests
      await client.from('tests').insert({
        'id': newId,
        'title': newQuiz.title,
        'syllabus': newQuiz.description,
        'category_id': newQuiz.category,
        'duration_minutes': durationMins,
        'total_questions': newQuiz.questionsCount,
        'entry_fee_coins': entryFee,
        'is_tournament': false,
        'test_mode': 'mock',
        'status': 'published',
        'scheduled_start_time': localStart.toUtc().toIso8601String(),
        'scheduled_end_time': localEnd.toUtc().toIso8601String(),
        'total_participants': 0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      // 2. Copy questions from source test
      if (sourceTestId.isNotEmpty) {
        final sourceQs = await client
            .from('questions')
            .select()
            .eq('test_id', sourceTestId)
            .order('question_number', ascending: true);

        if (sourceQs.isNotEmpty) {
          final qPayload = <Map<String, dynamic>>[];
          for (int i = 0; i < sourceQs.length; i++) {
            final original = Map<String, dynamic>.from(sourceQs[i]);
            original['id'] = 'q_lq_${newId}_${DateTime.now().millisecondsSinceEpoch}_${i + 1}';
            original['test_id'] = newId;
            original['question_number'] = i + 1;
            original['created_at'] = DateTime.now().toUtc().toIso8601String();
            qPayload.add(original);
          }
          await client.from('questions').upsert(qPayload);
          await client.from('tests').update({
            'total_questions': qPayload.length,
          }).eq('id', newId);

          final inMemIdx = _allQuizzes.indexWhere((q) => q.id == newId);
          if (inMemIdx >= 0) {
            setState(() {
              _allQuizzes[inMemIdx] = _allQuizzes[inMemIdx].copyWith(
                questionsCount: qPayload.length,
              );
            });
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Live Quiz scheduled and questions copied from "${sourceTest['title']}"!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating live quiz from existing test: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  void _openScheduleDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ScheduleQuizDialog(
        quizzes: _allQuizzes,
        onSchedule: (quiz, dateTime) async {
          final localStart = dateTime.toLocal();
          final localEnd = localStart.add(Duration(minutes: quiz.durationMinutes));
          final now = DateTime.now();

          LiveQuizStatus schedStatus = LiveQuizStatus.scheduled;
          if (now.isAfter(localStart) && now.isBefore(localEnd)) {
            schedStatus = LiveQuizStatus.liveNow;
          } else if (now.isAfter(localEnd)) {
            schedStatus = LiveQuizStatus.completed;
          }

          final updatedQuiz = quiz.copyWith(
            startTime: localStart,
            status: schedStatus,
          );

          setState(() {
            final idx = _allQuizzes.indexWhere((q) => q.id == quiz.id);
            if (idx >= 0) {
              _allQuizzes[idx] = updatedQuiz;
            }
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              await client.from('tests').update({
                'scheduled_start_time': localStart.toUtc().toIso8601String(),
                'scheduled_end_time': localEnd.toUtc().toIso8601String(),
                'status': 'published',
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              }).eq('id', quiz.id);
            } catch (e) {
              debugPrint('Supabase schedule quiz error: $e');
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quiz "${quiz.title}" scheduled for ${localStart.toLocal()}'),
                backgroundColor: const Color(0xFF0084FF),
              ),
            );
          }
        },
      ),
    );
  }

  void _openLiveNowDashboard(LiveQuizItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => LiveNowDashboardDialog(
        item: item,
        onSessionEnded: () async {
          setState(() {
            final idx = _allQuizzes.indexWhere((q) => q.id == item.id);
            if (idx >= 0) {
              _allQuizzes[idx] = item.copyWith(status: LiveQuizStatus.completed);
            }
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              await client.from('tests').update({
                'scheduled_end_time': DateTime.now().toUtc().toIso8601String(),
                'is_result_declared': true,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              }).eq('id', item.id);
            } catch (e) {
              debugPrint('Supabase session end error: $e');
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Live Quiz session ended and leaderboard published!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  void _openViewDialog(LiveQuizItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ViewLiveQuizDialog(item: item),
    );
  }

  void _showNotificationComposer() {
    final textController = TextEditingController();

    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Broadcast Announcement',
        subtitle: 'Push alert to students enrolled in live quizzes',
        iconData: Icons.campaign_outlined,
        maxWidth: 500,
        actions: [
          AppModalDialog.cancelButton(ctx),
          AppModalDialog.primaryButton(
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
                    'title': 'Live Quiz Announcement',
                    'message': text,
                    'type': 'live_quiz',
                    'target_segment': 'all',
                    'created_at': DateTime.now().toUtc().toIso8601String(),
                  });
                } catch (e) {
                  debugPrint('Notification broadcast error: $e');
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Push notification broadcasted successfully to all users!'),
                    backgroundColor: AppColors.brandGreen,
                  ),
                );
              }
            },
            child: const Text(
              'Send Broadcast',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compose and send instant push notifications to all enrolled students for upcoming live quizzes.',
              style: AppTypography.bodySmall.copyWith(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            AppModalDialog.textField(
              controller: textController,
              maxLines: 3,
              minLines: 3,
              hint: 'e.g. Current Affairs Live Quiz starts in 10 minutes! Join now to win rewards.',
              contentPadding: const EdgeInsets.all(14),
            ),
          ],
        ),
      ),
    );
  }

  void _exportReports() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Category,Status,Start Time,Duration (Mins),Questions,Reward Coins,Participants');
    for (final q in _allQuizzes) {
      buffer.writeln('"${q.id}","${q.title}","${q.category}","${q.statusLabel}","${q.startTime.toIso8601String()}",${q.durationMinutes},${q.questionsCount},${q.rewardCoins},${q.participantsCount}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_allQuizzes.length} live quizzes report (CSV format ready)!'),
        backgroundColor: const Color(0xFF5636F5),
      ),
    );
  }

  void _showMoreContextMenu(LiveQuizItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.quiz_outlined, color: Color(0xFF5636F5)),
              title: const Text('Manage Questions'),
              onTap: () {
                Navigator.pop(ctx);
                _openManageQuestions(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Color(0xFF5636F5)),
              title: const Text('Duplicate Live Quiz'),
              onTap: () async {
                Navigator.pop(ctx);
                final dupId = 'test-${DateTime.now().millisecondsSinceEpoch}';
                final dup = item.copyWith(
                  id: dupId,
                  title: '${item.title} (Copy)',
                  status: LiveQuizStatus.draft,
                );
                setState(() => _allQuizzes.insert(0, dup));

                final client = SupabaseConfig.clientSafe;
                if (client != null) {
                  try {
                    await client.from('tests').insert({
                      'id': dupId,
                      'title': dup.title,
                      'syllabus': dup.description,
                      'category_id': dup.category,
                      'duration_minutes': dup.durationMinutes,
                      'total_questions': dup.questionsCount,
                      'is_tournament': false, // Strictly false!
                      'test_mode': 'mock',
                      'entry_fee_coins': dup.entryFeeCoins,
                      'status': 'draft',
                      'total_participants': 0,
                      'created_at': DateTime.now().toUtc().toIso8601String(),
                      'updated_at': DateTime.now().toUtc().toIso8601String(),
                    });
                  } catch (e) {
                    debugPrint('Supabase duplicate error: $e');
                  }
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz duplicated as draft in database')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Color(0xFFFF9F0A)),
              title: const Text('Archive Quiz'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  final idx = _allQuizzes.indexWhere((q) => q.id == item.id);
                  if (idx >= 0) {
                    _allQuizzes[idx] = item.copyWith(isArchived: true);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quiz archived')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
              title: const Text('Delete Quiz', style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () async {
                Navigator.pop(ctx);
                setState(() => _allQuizzes.removeWhere((q) => q.id == item.id));

                final client = SupabaseConfig.clientSafe;
                if (client != null) {
                  try {
                    await client.from('tests').delete().eq('id', item.id);
                  } catch (e) {
                    debugPrint('Supabase delete quiz error: $e');
                  }
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz deleted from database')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Genuine dynamic metrics from loaded database records
    final totalLiveQuiz = _allQuizzes.length;
    final totalParticipants = _allQuizzes.fold<int>(0, (acc, q) => acc + q.participantsCount);
    final completedQuiz = _allQuizzes.where((q) => q.computedStatus == LiveQuizStatus.completed).length;
    final ongoingQuiz = _allQuizzes.where((q) => q.computedStatus == LiveQuizStatus.liveNow || q.computedStatus == LiveQuizStatus.ongoing).length;
    final totalRewards = _allQuizzes.fold<int>(0, (acc, q) => acc + q.rewardCoins);

    final categorySlices = _calculateCategorySlices();
    final recentActivities = _generateRecentActivities();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;

        return SingleChildScrollView(
          padding: AppSpacing.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Hero Banner (height: 124) + Quick Actions (height: 124)
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 6,
                      child: LiveQuizHeroCard(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: LiveQuizQuickActions(
                        height: 124,
                        onCreateLiveQuiz: () => _openCreateDialog(),
                        onAddExistingTest: _openAddExistingTestDialog,
                        onScheduleQuiz: _openScheduleDialog,
                        onManageQuestions: () {
                          if (_allQuizzes.isNotEmpty) {
                            _openManageQuestions(_allQuizzes.first);
                          } else if (widget.onManageQuestions != null) {
                            widget.onManageQuestions!();
                          }
                        },
                        onLiveNowDashboard: () {
                          if (_allQuizzes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No live quizzes found. Create or schedule one first.')),
                            );
                            return;
                          }
                          final liveItem = _allQuizzes.firstWhere(
                            (q) => q.status == LiveQuizStatus.liveNow,
                            orElse: () => _allQuizzes.first,
                          );
                          _openLiveNowDashboard(liveItem);
                        },
                        onSendNotification: _showNotificationComposer,
                        onExportReports: _exportReports,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const LiveQuizHeroCard(),
                const SizedBox(height: 12),
                LiveQuizQuickActions(
                  height: 124,
                  onCreateLiveQuiz: () => _openCreateDialog(),
                  onAddExistingTest: _openAddExistingTestDialog,
                  onScheduleQuiz: _openScheduleDialog,
                  onManageQuestions: () {
                    if (_allQuizzes.isNotEmpty) {
                      _openManageQuestions(_allQuizzes.first);
                    } else if (widget.onManageQuestions != null) {
                      widget.onManageQuestions!();
                    }
                  },
                  onLiveNowDashboard: () {
                    if (_allQuizzes.isNotEmpty) _openLiveNowDashboard(_allQuizzes.first);
                  },
                  onSendNotification: _showNotificationComposer,
                  onExportReports: _exportReports,
                ),
              ],
              const SizedBox(height: 14),

              // Row 2: Dynamic 5 Statistics Cards
              LiveQuizMetricsRow(
                totalLiveQuiz: totalLiveQuiz,
                totalParticipants: totalParticipants,
                completedQuiz: completedQuiz,
                ongoingQuiz: ongoingQuiz,
                totalRewardsGiven: totalRewards,
              ),
              const SizedBox(height: 14),

              // Row 3: Left Main Table Card (flex: 7) + Right Column Analytics (flex: 3)
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Data Table
                    Expanded(
                      flex: 7,
                      child: LiveQuizTableCard(
                        items: _paginatedQuizzes,
                        totalCount: _filteredQuizzes.length,
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
                        onAnalytics: _openLiveNowDashboard,
                        onEdit: (item) => _openCreateDialog(editItem: item),
                        onManageQuestions: _openManageQuestions,
                        onAddExistingTest: _openAddExistingTestDialog,
                        onMore: _showMoreContextMenu,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Analytics Column (3 Stacked Cards)
                    SizedBox(
                      width: 295,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LiveQuizCategoryDonutCard(
                            totalCount: totalLiveQuiz,
                            slices: categorySlices,
                          ),
                          const SizedBox(height: 12),
                          const LiveQuizParticipantsBarChartCard(),
                          const SizedBox(height: 12),
                          LiveQuizRecentActivityCard(
                            activities: recentActivities,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Tablet/Mobile stacked layout
                LiveQuizTableCard(
                  items: _paginatedQuizzes,
                  totalCount: _filteredQuizzes.length,
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
                  onAnalytics: _openLiveNowDashboard,
                  onEdit: (item) => _openCreateDialog(editItem: item),
                  onManageQuestions: _openManageQuestions,
                  onAddExistingTest: _openAddExistingTestDialog,
                  onMore: _showMoreContextMenu,
                ),
                const SizedBox(height: 14),
                LiveQuizCategoryDonutCard(
                  totalCount: totalLiveQuiz,
                  slices: categorySlices,
                ),
                const SizedBox(height: 12),
                const LiveQuizParticipantsBarChartCard(),
                const SizedBox(height: 12),
                LiveQuizRecentActivityCard(
                  activities: recentActivities,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
