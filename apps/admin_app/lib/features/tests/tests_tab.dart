import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class TestsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialTests;

  const TestsTab({super.key, this.initialTests});

  @override
  State<TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<TestsTab> {
  String _selectedExamGroup = 'all';
  String _searchQuery = '';
  final Set<String> _selectedTestIds = {};
  bool _isLoading = true;
  List<Map<String, dynamic>> _tests = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialTests != null) {
      _tests = widget.initialTests!;
      _isLoading = false;
    } else {
      _loadTests();
    }
  }

  Future<void> _loadTests() async {
    setState(() => _isLoading = true);
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await client.from('tests').select().order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _tests = (res as List).map((row) => {
          'id': row['id']?.toString() ?? '',
          'title': row['title']?.toString() ?? 'Untitled Test',
          'examGroup': row['exam_category_id']?.toString() ?? row['category_id']?.toString() ?? 'General',
          'category': row['category_id']?.toString() ?? 'General Studies',
          'questions': (row['total_questions'] as num?)?.toInt() ?? 0,
          'duration': (row['duration_minutes'] as num?)?.toInt() ?? 60,
          'negativeMarking': (row['negative_marking'] as num?)?.toDouble() ?? 0.0,
          'marksPerQuestion': (row['marks_per_question'] as num?)?.toDouble() ?? 1.0,
          'tier': row['is_premium'] == true ? 'PRO' : 'Free',
          'isPublished': row['status'] == 'published',
          'attempts': (row['total_attempts'] as num?)?.toInt() ?? (row['total_participants'] as num?)?.toInt() ?? 0,
        }).toList();
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTests = _tests.where((t) {
      final matchesGroup = _selectedExamGroup == 'all' || t['examGroup'] == _selectedExamGroup;
      final matchesQuery = _searchQuery.isEmpty ||
          (t['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t['category'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesGroup && matchesQuery;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Unified Master Header
          _buildMasterHeader(),
          const SizedBox(height: 20),

          // 2. Search & Filter Bar
          _buildSearchBar(),
          const SizedBox(height: 20),

          // 3. Tests List
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredTests.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: filteredTests.map((test) => _buildTestCard(test)).toList(),
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
                child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Test Repository', style: AppTypography.displayMedium),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        'Manage Exam Content & Syllabus',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        '${_tests.length} Items Syncing',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brandPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Actions Row
          Row(
            children: [
              if (_selectedTestIds.isNotEmpty) ...[
                AppButton(
                  label: 'Delete Selected (${_selectedTestIds.length})',
                  variant: AppButtonVariant.destructive,
                  size: AppButtonSize.small,
                  onPressed: () {
                    setState(() {
                      _tests.removeWhere((t) => _selectedTestIds.contains(t['id']));
                      _selectedTestIds.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selected tests deleted.')),
                    );
                  },
                ),
                const SizedBox(width: 10),
              ],

              // Download / Upload Utilities Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download_outlined, size: 18, color: Color(0xFF64748B)),
                      tooltip: 'Download Sample JSON',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloaded sample JSON format template.')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.upload_file_outlined, size: 18, color: Color(0xFF64748B)),
                      tooltip: 'Import JSON Test Paper',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opened JSON file selector for import.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // + New Test Button
              AppButton(
                label: '+ New Test',
                size: AppButtonSize.medium,
                onPressed: _showCreateTestDialog,
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildSearchBar() {
    final groups = ['all', '70th BPSC', 'SSC CGL', 'Railway NTPC', 'UPSC CSE', 'Banking'];

    return Row(
      children: [
        Expanded(
          child: AppTextField(
            hintText: 'Search by test title, exam group or category...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderMd,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedExamGroup,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
              items: groups.map((g) {
                return DropdownMenuItem(
                  value: g,
                  child: Text(
                    g == 'all' ? 'All Exam Groups' : g,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedExamGroup = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    final isSelected = _selectedTestIds.contains(test['id']);
    final isPro = test['tier'] == 'PRO';
    final isPublished = test['isPublished'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: isSelected ? AppColors.brandPrimary : const Color(0xFFF1F5F9),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isSelected,
            activeColor: AppColors.brandPrimary,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedTestIds.add(test['id']);
                } else {
                  _selectedTestIds.remove(test['id']);
                }
              });
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        test['title'],
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPro ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF),
                        borderRadius: AppRadii.borderPill,
                        border: Border.all(color: isPro ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        test['tier'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isPro ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isPublished)
                      AppStatusPill.active(label: 'Published')
                    else
                      const AppStatusPill(label: 'Draft', bg: Color(0xFFF1F5F9), fg: Color(0xFF64748B)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${test['examGroup']} • ${test['category']} • ${test['questions']} Qs • ${test['duration']} Mins • -${test['negativeMarking']} Negative • ${test['attempts']} Candidates Attempted',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              AppButton(
                label: 'View Questions (${test['questions']})',
                variant: AppButtonVariant.outlined,
                size: AppButtonSize.small,
                onPressed: () => _showQuestionBankViewer(test),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                tooltip: 'Edit Parameters',
                onPressed: () => _showEditTestDialog(test),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                tooltip: 'Delete Test',
                onPressed: () {
                  setState(() => _tests.remove(test));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${test['title']}"')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateTestDialog() {
    final titleController = TextEditingController();
    final examGroupController = TextEditingController(text: '70th BPSC');
    final categoryController = TextEditingController(text: 'General Studies');
    final qCountController = TextEditingController(text: '150');
    final durationController = TextEditingController(text: '120');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Test Series'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Test Series Title', controller: titleController, hintText: 'e.g. 70th BPSC Full Mock 2'),
              const SizedBox(height: 12),
              AppTextField(label: 'Exam Group', controller: examGroupController, hintText: '70th BPSC'),
              const SizedBox(height: 12),
              AppTextField(label: 'Subject / Category', controller: categoryController, hintText: 'General Studies'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Questions', controller: qCountController, hintText: '150')),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Duration (mins)', controller: durationController, hintText: '120')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Create Test',
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _tests.insert(0, {
                    'id': 'test-${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'examGroup': examGroupController.text,
                    'category': categoryController.text,
                    'questions': int.tryParse(qCountController.text) ?? 100,
                    'duration': int.tryParse(durationController.text) ?? 90,
                    'negativeMarking': 0.25,
                    'marksPerQuestion': 1.0,
                    'tier': 'Free',
                    'isPublished': true,
                    'attempts': 0,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New test series created successfully!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditTestDialog(Map<String, dynamic> test) {
    final titleController = TextEditingController(text: test['title']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Test Series Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Test Title', controller: titleController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Save Changes',
            onPressed: () {
              setState(() => test['title'] = titleController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updated test details.')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showQuestionBankViewer(Map<String, dynamic> test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(test['title'], style: AppTypography.titleLarge),
                      const SizedBox(height: 2),
                      Text('Viewing ${test['questions']} MCQs • Bilingual Hindi & English', style: AppTypography.bodySmall),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: 5,
                itemBuilder: (context, idx) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: AppRadii.borderLg,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${idx + 1}. Which treaty concluded the First Anglo-Maratha War in 1782?', style: AppTypography.titleMedium),
                        const SizedBox(height: 2),
                        const Text('प्रथम आंग्ल-मराठा युद्ध (1782) किस संधि द्वारा समाप्त हुआ था?', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 10),
                        _buildOptionRow('A', 'Treaty of Salbai (सालबाई की संधि)', true),
                        _buildOptionRow('B', 'Treaty of Purandar (पुरंदर की संधि)', false),
                        _buildOptionRow('C', 'Treaty of Bassein (बेसिन की संधि)', false),
                        _buildOptionRow('D', 'Treaty of Surat (सूरत की संधि)', false),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(String opt, String text, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.brandPrimary : Colors.white,
              border: Border.all(color: isCorrect ? AppColors.brandPrimary : const Color(0xFFCBD5E1)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                color: isCorrect ? AppColors.brandPrimaryDark : const Color(0xFF334155),
              ),
            ),
          ),
          if (isCorrect)
            const Icon(Icons.check_circle, size: 16, color: AppColors.brandPrimary),
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
          Icon(Icons.search_off_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No test series match your filter criteria.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
