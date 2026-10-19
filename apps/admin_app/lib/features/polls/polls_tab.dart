import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PollsTab extends StatefulWidget {
  const PollsTab({super.key});

  @override
  State<PollsTab> createState() => _PollsTabState();
}

class _PollsTabState extends State<PollsTab> {
  final List<Map<String, dynamic>> _polls = [
    {
      'id': 'poll-1',
      'question': 'Which exam series should we prioritize next for the AI Test Intelligence generator?',
      'targetSegment': 'All Candidates',
      'isActive': true,
      'createdAt': 'Oct 18, 2026',
      'options': [
        {'text': '70th BPSC Mains Answer Writing', 'votes': 420},
        {'text': 'SSC CGL Tier 2 Quantitative Advance', 'votes': 310},
        {'text': 'Railway RRB NTPC Special', 'votes': 195},
        {'text': 'UPSC Prelims CSAT Speed Hacks', 'votes': 140},
      ],
    },
    {
      'id': 'poll-2',
      'question': 'What is your preferred duration for daily 1v1 coin battle speed duels?',
      'targetSegment': 'Pro Pass Candidates',
      'isActive': true,
      'createdAt': 'Oct 15, 2026',
      'options': [
        {'text': '5 Questions (60 Seconds)', 'votes': 580},
        {'text': '10 Questions (2 Minutes)', 'votes': 220},
        {'text': '15 Questions (Sprint Mode)', 'votes': 85},
      ],
    },
  ];

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

          // Poll Cards Grid
          Column(
            children: _polls.map((p) => _buildPollCard(p)).toList(),
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
    final options = poll['options'] as List<dynamic>;
    final totalVotes = options.fold<int>(0, (sum, o) => sum + (o['votes'] as int));

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
                  Text(poll['createdAt'], style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    onPressed: () {
                      setState(() => _polls.remove(poll));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Poll deleted.')),
                      );
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
              final votes = opt['votes'] as int;
              final pct = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(opt['text'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
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
            onPressed: () {
              if (qController.text.isNotEmpty && opt1Controller.text.isNotEmpty) {
                setState(() {
                  _polls.insert(0, {
                    'id': 'poll-${DateTime.now().millisecondsSinceEpoch}',
                    'question': qController.text,
                    'targetSegment': 'All Candidates',
                    'isActive': true,
                    'createdAt': 'Today',
                    'options': [
                      {'text': opt1Controller.text, 'votes': 0},
                      {'text': opt2Controller.text, 'votes': 0},
                    ],
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Poll published live!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
