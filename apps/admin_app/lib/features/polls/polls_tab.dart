import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class PollsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialPolls;
  const PollsTab({super.key, this.initialPolls});

  @override
  State<PollsTab> createState() => _PollsTabState();
}

class _PollsTabState extends State<PollsTab> {
  List<Map<String, dynamic>> _polls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialPolls != null) {
      _polls = List.from(widget.initialPolls!);
      _isLoading = false;
    } else {
      _fetchPolls();
    }
  }

  Future<void> _fetchPolls() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await client.from('polls').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _polls = (res as List).map((row) {
            final opts = row['options'] ?? [];
            final votesMap = row['votes'] ?? {};
            final List<Map<String, dynamic>> parsedOpts = [];
            if (opts is List) {
              for (int i = 0; i < opts.length; i++) {
                final o = opts[i];
                if (o is Map) {
                  parsedOpts.add({
                    'text': o['text']?.toString() ?? 'Option ${i + 1}',
                    'votes': (o['votes'] is num) ? (o['votes'] as num).toInt() : 0,
                  });
                } else {
                  final text = o.toString();
                  final votesCount = votesMap is Map ? (votesMap['$i'] ?? votesMap[text] ?? 0) : 0;
                  parsedOpts.add({
                    'text': text,
                    'votes': (votesCount is num) ? votesCount.toInt() : 0,
                  });
                }
              }
            }
            return {
              'id': row['id']?.toString() ?? '',
              'question': row['question']?.toString() ?? '',
              'targetSegment': row['target_segment']?.toString() ?? 'All Candidates',
              'isActive': row['is_active'] == true,
              'createdAt': row['created_at'] != null ? row['created_at'].toString().split('T').first : 'Recent',
              'options': parsedOpts,
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Header
          _buildMasterHeader(),
          const SizedBox(height: 24),

          // Poll Cards or Empty State
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppColors.brandPrimary),
              ),
            )
          else if (_polls.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: _polls.map((p) => _buildPollCard(p)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.poll_outlined, color: AppColors.brandPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No Community Polls Found', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Create interactive polls to survey candidates on preferred exam topics, mock timings, or feedback.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: '+ Create First Poll',
            onPressed: _showCreatePollDialog,
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
                    BoxShadow(color: AppColors.brandPrimary.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.poll_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Community Polls & Surveys', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Gather candidate sentiment, syllabus demand, and feature feedback', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),

          AppButton(
            label: '+ Create New Poll',
            onPressed: _showCreatePollDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(Map<String, dynamic> poll) {
    final options = (poll['options'] as List<dynamic>?) ?? [];
    final totalVotes = options.fold<int>(0, (sum, o) => sum + ((o['votes'] as int?) ?? 0));

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: const Text('ACTIVE POLL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                  ),
                  const SizedBox(width: 8),
                  Text('Target: ${poll['targetSegment']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  Text(poll['createdAt'].toString(), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    onPressed: () async {
                      final pollId = poll['id']?.toString() ?? '';
                      setState(() => _polls.remove(poll));
                      final client = SupabaseConfig.clientSafe;
                      if (client != null && pollId.isNotEmpty) {
                        try {
                          await client.from('polls').delete().eq('id', pollId);
                        } catch (_) {}
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Poll deleted.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(poll['question'], style: AppTypography.titleLarge),
          const SizedBox(height: 16),

          // Options with live progress bars
          Column(
            children: options.map((opt) {
              final votes = (opt['votes'] as int?) ?? 0;
              final pct = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(opt['text']?.toString() ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        Text('${pct.toStringAsFixed(1)}% ($votes votes)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: AppRadii.borderPill,
                      child: LinearProgressIndicator(
                        value: (pct / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text('Total Votes Cast: $totalVotes Candidates', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  void _showCreatePollDialog() {
    final qController = TextEditingController();
    final opt1Controller = TextEditingController();
    final opt2Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Community Poll'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Poll Question', controller: qController, hintText: 'e.g. Which subject is most challenging?'),
            const SizedBox(height: 12),
            AppTextField(label: 'Option 1', controller: opt1Controller, hintText: 'Option A'),
            const SizedBox(height: 12),
            AppTextField(label: 'Option 2', controller: opt2Controller, hintText: 'Option B'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Publish Poll',
            onPressed: () async {
              if (qController.text.isNotEmpty && opt1Controller.text.isNotEmpty) {
                final newPollId = 'poll-${DateTime.now().millisecondsSinceEpoch}';
                final optionsList = [
                  {'text': opt1Controller.text.trim(), 'votes': 0},
                  if (opt2Controller.text.trim().isNotEmpty) {'text': opt2Controller.text.trim(), 'votes': 0},
                ];

                final newPollMap = {
                  'id': newPollId,
                  'question': qController.text.trim(),
                  'targetSegment': 'All Candidates',
                  'isActive': true,
                  'createdAt': 'Today',
                  'options': optionsList,
                };

                setState(() {
                  _polls.insert(0, newPollMap);
                });
                Navigator.pop(ctx);

                final client = SupabaseConfig.clientSafe;
                if (client != null) {
                  try {
                    await client.from('polls').insert({
                      'id': newPollId,
                      'question': qController.text.trim(),
                      'options': optionsList,
                      'votes': {},
                      'target_segment': 'all',
                      'is_active': true,
                    });
                  } catch (_) {}
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Poll published live!')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
