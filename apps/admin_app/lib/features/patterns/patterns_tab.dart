import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PatternsTab extends StatefulWidget {
  const PatternsTab({super.key});

  @override
  State<PatternsTab> createState() => _PatternsTabState();
}

class _PatternsTabState extends State<PatternsTab> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _patterns = [
    {
      'id': 'pat-1',
      'examName': '70th BPSC Prelims CCE',
      'category': 'State PSC',
      'totalQuestions': 150,
      'durationMinutes': 120,
      'negativeMarking': 0.25,
      'marksPerQuestion': 1.0,
      'sections': [
        {'title': 'Ancient & Medieval History of Bihar', 'questions': 35},
        {'title': 'General Science & Tech', 'questions': 30},
        {'title': 'Indian Polity & Constitution', 'questions': 25},
        {'title': 'National & Bihar Current Affairs', 'questions': 35},
        {'title': 'Quantitative Aptitude & Reasoning', 'questions': 25},
      ],
    },
    {
      'id': 'pat-2',
      'examName': 'SSC CGL Tier 1 Standard',
      'category': 'Staff Selection',
      'totalQuestions': 100,
      'durationMinutes': 60,
      'negativeMarking': 0.50,
      'marksPerQuestion': 2.0,
      'sections': [
        {'title': 'General Intelligence & Reasoning', 'questions': 25},
        {'title': 'General Awareness', 'questions': 25},
        {'title': 'Quantitative Aptitude', 'questions': 25},
        {'title': 'English Comprehension', 'questions': 25},
      ],
    },
    {
      'id': 'pat-3',
      'examName': 'Railway RRB NTPC Stage 1 CBT',
      'category': 'Railways',
      'totalQuestions': 100,
      'durationMinutes': 90,
      'negativeMarking': 0.33,
      'marksPerQuestion': 1.0,
      'sections': [
        {'title': 'General Awareness', 'questions': 40},
        {'title': 'Mathematics', 'questions': 30},
        {'title': 'General Intelligence & Reasoning', 'questions': 30},
      ],
    },
    {
      'id': 'pat-4',
      'examName': 'UPSC Civil Services Prelims (GS Paper 1)',
      'category': 'Civil Services',
      'totalQuestions': 100,
      'durationMinutes': 120,
      'negativeMarking': 0.66,
      'marksPerQuestion': 2.0,
      'sections': [
        {'title': 'Indian History & Art & Culture', 'questions': 20},
        {'title': 'Geography & Environment', 'questions': 25},
        {'title': 'Indian Polity & Governance', 'questions': 20},
        {'title': 'Economic & Social Development', 'questions': 15},
        {'title': 'General Science & International Affairs', 'questions': 20},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _patterns.where((p) {
      final q = _searchQuery.toLowerCase();
      return _searchQuery.isEmpty ||
          (p['examName'] as String).toLowerCase().contains(q) ||
          (p['category'] as String).toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Header
          _buildMasterHeader(),
          const SizedBox(height: 20),

          // Search input
          AppTextField(
            hintText: 'Search patterns by exam name or category...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 20),

          // Patterns Grid
          Column(
            children: filtered.map((p) => _buildPatternCard(p)).toList(),
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
                    BoxShadow(
                      color: AppColors.brandPrimary.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.architecture_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exam Patterns & Blueprints', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Define section weighting, negative marking, and syllabus blueprints', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book, size: 16),
                label: const Text('Subjects', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                ),
                onPressed: _showSubjectsModal,
              ),
              const SizedBox(width: 10),
              AppButton(
                label: '+ New Pattern',
                onPressed: _showAddPatternDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(Map<String, dynamic> pattern) {
    final sections = (pattern['sections'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  Text(pattern['examName'], style: AppTypography.titleLarge),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: AppRadii.borderPill,
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      (pattern['category'] as String).toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Editing pattern: ${pattern['examName']}')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    onPressed: () {
                      setState(() => _patterns.remove(pattern));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted ${pattern['examName']}')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total: ${pattern['totalQuestions']} Questions • ${pattern['durationMinutes']} Minutes • ${pattern['marksPerQuestion']} Mark/Q • -${pattern['negativeMarking']} Negative Marking',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Sections Breakdown Pills
          const Text('SECTIONAL BLUEPRINT & QUESTION BREAKDOWN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sections.map<Widget>((sec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(sec['title'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withAlpha(30),
                        borderRadius: AppRadii.borderPill,
                      ),
                      child: Text(
                        '${sec['questions']} Qs',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.brandPrimaryDark),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showSubjectsModal() {
    final subjects = ['History of India & Bihar', 'General Science & Technology', 'Indian Polity & Governance', 'Quantitative Aptitude', 'Reasoning & Mental Ability', 'Current Affairs & GK'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manage Standard Syllabus Subjects'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: subjects.map((s) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.bookmark_outline, size: 18, color: AppColors.brandPrimary),
                title: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.check, size: 16, color: AppColors.brandPrimary),
              );
            }).toList(),
          ),
        ),
        actions: [
          AppButton(
            label: 'Close',
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showAddPatternDialog() {
    final nameController = TextEditingController();
    final catController = TextEditingController(text: 'State PSC');
    final qCountController = TextEditingController(text: '100');
    final durController = TextEditingController(text: '90');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Exam Pattern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Exam Name', controller: nameController, hintText: 'e.g. Haryana HSSC CET 2026'),
            const SizedBox(height: 12),
            AppTextField(label: 'Category', controller: catController, hintText: 'State PSC'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AppTextField(label: 'Questions', controller: qCountController, hintText: '100')),
                const SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'Duration (mins)', controller: durController, hintText: '90')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Save Pattern',
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _patterns.insert(0, {
                    'id': 'pat-${DateTime.now().millisecondsSinceEpoch}',
                    'examName': nameController.text,
                    'category': catController.text,
                    'totalQuestions': int.tryParse(qCountController.text) ?? 100,
                    'durationMinutes': int.tryParse(durController.text) ?? 90,
                    'negativeMarking': 0.25,
                    'marksPerQuestion': 1.0,
                    'sections': [
                      {'title': 'General Studies', 'questions': 50},
                      {'title': 'Aptitude & Reasoning', 'questions': 50},
                    ],
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exam pattern successfully registered!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
