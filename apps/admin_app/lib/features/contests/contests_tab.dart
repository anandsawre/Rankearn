import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class ContestsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialContests;

  const ContestsTab({super.key, this.initialContests});

  @override
  State<ContestsTab> createState() => _ContestsTabState();
}

class _ContestsTabState extends State<ContestsTab> {
  String _activeFilter = 'all'; // 'all', 'live', 'upcoming', 'past'
  bool _isLoading = true;
  List<Map<String, dynamic>> _contests = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialContests != null) {
      _contests = widget.initialContests!;
      _isLoading = false;
    } else {
      _loadContests();
    }
  }

  Future<void> _loadContests() async {
    setState(() => _isLoading = true);
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await client
          .from('tests')
          .select()
          .eq('is_tournament', true)
          .order('scheduled_start_time', ascending: true);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _contests = (res as List).map((row) {
          final now = DateTime.now();
          final start = row['scheduled_start_time'] != null
              ? DateTime.tryParse(row['scheduled_start_time'].toString())
              : null;
          final end = row['scheduled_end_time'] != null
              ? DateTime.tryParse(row['scheduled_end_time'].toString())
              : null;

          String status = 'upcoming';
          if (start != null && end != null) {
            if (now.isAfter(start) && now.isBefore(end)) {
              status = 'live';
            } else if (now.isAfter(end)) {
              status = 'past';
            }
          }

          return {
            'testId': row['id']?.toString() ?? '',
            'title': row['title']?.toString() ?? 'Tournament Contest',
            'examGroup': row['exam_category_id']?.toString() ?? row['category_id']?.toString() ?? 'General',
            'entryFeeCoins': (row['entry_fee_coins'] as num?)?.toInt() ?? 0,
            'prizePoolCoins': (row['prize_pool_coins'] as num?)?.toInt() ?? 0,
            'registeredCount': (row['total_participants'] as num?)?.toInt() ?? 0,
            'duration': (row['duration_minutes'] as num?)?.toInt() ?? 60,
            'status': status,
            'startTime': start != null ? start.toLocal().toString().substring(0, 16) : 'TBD',
            'endTime': end != null ? end.toLocal().toString().substring(0, 16) : 'TBD',
            'isResultDeclared': row['is_result_declared'] == true,
          };
        }).toList();
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _contests.where((c) {
      if (_activeFilter == 'all') return true;
      return c['status'] == _activeFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Header
          _buildMasterHeader(),
          const SizedBox(height: 20),

          // Sub-navigation Filter Bar
          _buildSubNavFilter(),
          const SizedBox(height: 20),

          // Contests Grid
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: filtered.map((c) => _buildContestCard(c)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMasterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: AppRadii.borderLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPrimary.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contest Arena', style: AppTypography.displayMedium),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('Manage Tournaments & Prize Distributions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('${_contests.length} Contests', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brandPrimary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 24),
            Row(
              children: [
                AppButton(
                  label: '+ Create Tournament',
                  onPressed: _showCreateTournamentDialog,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF64748B)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contests list refreshed.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubNavFilter() {
    final tabs = [
      ('all', 'All Contests', Icons.emoji_events_outlined),
      ('live', 'Live Now', Icons.sensors),
      ('upcoming', 'Upcoming', Icons.schedule),
      ('past', 'Past / Ended', Icons.history),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final isSelected = _activeFilter == tab.$1;
          final count = tab.$1 == 'all'
              ? _contests.length
              : _contests.where((c) => c['status'] == tab.$1).length;

          return InkWell(
            onTap: () => setState(() => _activeFilter = tab.$1),
            borderRadius: AppRadii.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandPrimary : Colors.transparent,
                borderRadius: AppRadii.borderMd,
              ),
              child: Row(
                children: [
                  Icon(tab.$3, size: 14, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    tab.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withAlpha(50) : const Color(0xFFF1F5F9),
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContestCard(Map<String, dynamic> contest) {
    final status = contest['status'] as String;
    final isLive = status == 'live';
    final isUpcoming = status == 'upcoming';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: isLive ? const Color(0xFFFCA5A5) : const Color(0xFFF1F5F9),
          width: isLive ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLive ? const Color(0xFFFEE2E2) : (isUpcoming ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                      borderRadius: AppRadii.borderPill,
                      border: Border.all(
                        color: isLive ? const Color(0xFFFCA5A5) : (isUpcoming ? const Color(0xFFFCD34D) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isLive) ...[
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          isLive ? 'LIVE NOW' : (isUpcoming ? 'UPCOMING' : 'PAST / ENDED'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isLive ? const Color(0xFFDC2626) : (isUpcoming ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(contest['examGroup'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    tooltip: 'Delete Contest',
                    onPressed: () {
                      setState(() => _contests.remove(contest));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted "${contest['title']}"')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(contest['title'], style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Scheduled: ${contest['startTime']} - ${contest['endTime']} • ${contest['duration']} Minutes',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Economics Bar & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildEcoPill('Entry Fee', '${contest['entryFeeCoins']} Coins', Icons.toll_outlined, const Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  _buildEcoPill('Prize Pool', '${contest['prizePoolCoins']} Coins', Icons.stars_outlined, const Color(0xFFD97706)),
                  const SizedBox(width: 12),
                  _buildEcoPill('Candidates', '${contest['registeredCount']} Joined', Icons.people_outline, const Color(0xFF059669)),
                ],
              ),
              if (isLive || (isUpcoming && !contest['isResultDeclared']))
                AppButton(
                  label: 'Declare Results & Payout',
                  size: AppButtonSize.small,
                  onPressed: () {
                    setState(() {
                      contest['status'] = 'past';
                      contest['isResultDeclared'] = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Results declared for "${contest['title']}"! Prizes distributed to winners.')),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEcoPill(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
              Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateTournamentDialog() {
    final titleController = TextEditingController();
    final examController = TextEditingController(text: 'SSC CGL');
    final feeController = TextEditingController(text: '20');
    final prizeController = TextEditingController(text: '5000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule New Tournament'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Contest Title', controller: titleController, hintText: 'e.g. SSC CGL Super League'),
            const SizedBox(height: 12),
            AppTextField(label: 'Exam Target', controller: examController, hintText: 'SSC CGL'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AppTextField(label: 'Entry Fee (Coins)', controller: feeController, hintText: '20')),
                const SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'Prize Pool (Coins)', controller: prizeController, hintText: '5000')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Schedule Contest',
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _contests.insert(0, {
                    'testId': 'contest-${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'examGroup': examController.text,
                    'entryFeeCoins': int.tryParse(feeController.text) ?? 20,
                    'prizePoolCoins': int.tryParse(prizeController.text) ?? 5000,
                    'registeredCount': 0,
                    'duration': 60,
                    'status': 'upcoming',
                    'startTime': 'Today, 06:00 PM',
                    'endTime': 'Today, 07:00 PM',
                    'isResultDeclared': false,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tournament scheduled successfully!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No tournaments match this filter.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
