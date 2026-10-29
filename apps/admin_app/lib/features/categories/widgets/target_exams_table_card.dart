import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import '../models/category_item.dart';

class TargetExamsTableCard extends StatefulWidget {
  final List<ExamCategoryModel> exams;
  final List<CategoryItem> categories;
  final Set<String>? selectedIds;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final VoidCallback onAddExam;
  final ValueChanged<ExamCategoryModel> onEditExam;
  final ValueChanged<ExamCategoryModel> onDeleteExam;
  final ValueChanged<ExamCategoryModel>? onViewCurriculum;
  final bool isLoading;

  const TargetExamsTableCard({
    super.key,
    required this.exams,
    this.categories = const [],
    this.selectedIds,
    this.onSelectionChanged,
    required this.onAddExam,
    required this.onEditExam,
    required this.onDeleteExam,
    this.onViewCurriculum,
    this.isLoading = false,
  });

  @override
  State<TargetExamsTableCard> createState() => _TargetExamsTableCardState();
}

class _TargetExamsTableCardState extends State<TargetExamsTableCard> {
  String _searchQuery = '';
  late final TextEditingController _searchCtrl;
  Set<String> _localSelectedIds = {};

  Set<String> get _currentSelectedIds => widget.selectedIds ?? _localSelectedIds;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSelectAll(bool? val) {
    setState(() {
      final updated = <String>{};
      if (val == true) {
        for (final exam in _filteredExams) {
          updated.add(exam.id);
        }
      }
      if (widget.selectedIds != null) {
        widget.onSelectionChanged?.call(updated);
      } else {
        _localSelectedIds = updated;
      }
    });
  }

  void _toggleSelectRow(String id, bool? val) {
    setState(() {
      final updated = Set<String>.from(_currentSelectedIds);
      if (val == true) {
        updated.add(id);
      } else {
        updated.remove(id);
      }
      if (widget.selectedIds != null) {
        widget.onSelectionChanged?.call(updated);
      } else {
        _localSelectedIds = updated;
      }
    });
  }

  List<ExamCategoryModel> get _filteredExams {
    if (_searchQuery.trim().isEmpty) return widget.exams;
    final q = _searchQuery.toLowerCase().trim();
    return widget.exams.where((e) {
      final matchesExam = e.name.toLowerCase().contains(q) || e.id.toLowerCase().contains(q);
      final subjects = _getSubjectsForExam(e.id);
      final matchesSubject = subjects.any((s) => s.name.toLowerCase().contains(q));
      return matchesExam || matchesSubject;
    }).toList();
  }

  List<CategoryItem> _getSubjectsForExam(String examId) {
    return widget.categories
        .where((c) => c.examCategoryId != null && c.examCategoryId!.toLowerCase() == examId.toLowerCase())
        .toList();
  }

  Widget _buildExamIcon(String? iconUrl) {
    if (iconUrl == null || iconUrl.trim().isEmpty) {
      return const Text('🎯', style: TextStyle(fontSize: 18));
    }
    final clean = iconUrl.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          clean,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Text('🎯', style: TextStyle(fontSize: 18)),
        ),
      );
    }
    return Text(clean, style: const TextStyle(fontSize: 18));
  }

  void _showCurriculumDialog(ExamCategoryModel exam) {
    final subjects = _getSubjectsForExam(exam.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  alignment: Alignment.center,
                  child: _buildExamIcon(exam.iconUrl),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
                    ),
                    Text(
                      'Exam Curriculum (${subjects.length} Subjects)',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: subjects.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 36, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 8),
                      Text(
                        'No subjects linked to ${exam.name} yet.',
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Click "Edit Exam" to add subjects and chapters.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: subjects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final sub = subjects[idx];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: sub.parsedColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Icon(sub.iconData, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                                ),
                                if (sub.description.isNotEmpty)
                                  Text(
                                    sub.description,
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${sub.subcategoriesCount} Chapters',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Curriculum'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onEditExam(exam);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExams;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Title and Add Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5636F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.explore_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Target Exams & Syllabus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.exams.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5636F5),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Target Exam'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5636F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
                onPressed: widget.onAddExam,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 13, color: Color(0xFF101A3A)),
            decoration: InputDecoration(
              hintText: 'Search target exams (e.g. BPSC, Railway, SSC) or subjects...',
              hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF5636F5), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Exam List / Table
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF5636F5)),
              ),
            )
          else if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.explore_off_outlined, size: 40, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty ? 'No target exams match your search' : 'No target exams in database yet',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Try a different search keyword'
                        : 'Click "+ Add Target Exam" above to add your first exam and syllabus.',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                  ),
                ],
              ),
            )
          else if (isMobile)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final exam = filtered[index];
                final subjects = _getSubjectsForExam(exam.id);
                final isSelected = _currentSelectedIds.contains(exam.id);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF4F7FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? const Color(0xFF5636F5) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: const Color(0xFF5636F5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => _toggleSelectRow(exam.id, val),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            alignment: Alignment.center,
                            child: _buildExamIcon(exam.iconUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exam.name,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${subjects.length} Subjects • ${exam.totalTests} Tests',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFF64748B)),
                            tooltip: 'View Syllabus',
                            onPressed: () => _showCurriculumDialog(exam),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                            tooltip: 'Edit',
                            onPressed: () => widget.onEditExam(exam),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFF43F5E)),
                            tooltip: 'Delete',
                            onPressed: () => widget.onDeleteExam(exam),
                          ),
                        ],
                      ),
                      if (subjects.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: subjects.take(3).map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(s.name, style: const TextStyle(fontSize: 10.5, color: Color(0xFF334155))),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            )
          else
            Builder(
              builder: (context) {
                final allSelected = filtered.isNotEmpty && filtered.every((e) => _currentSelectedIds.contains(e.id));

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: math.max(MediaQuery.of(context).size.width - 380, 780.0),
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      headingRowHeight: 40,
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 56,
                      horizontalMargin: 12,
                      columnSpacing: 16,
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                          label: Checkbox(
                            value: allSelected,
                            activeColor: const Color(0xFF5636F5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: _toggleSelectAll,
                          ),
                        ),
                        const DataColumn(label: Text('#', style: _headerStyle)),
                        const DataColumn(label: Text('TARGET EXAM', style: _headerStyle)),
                        const DataColumn(label: Text('SUBJECTS INCLUDED', style: _headerStyle)),
                        const DataColumn(label: Text('CHAPTERS', style: _headerStyle)),
                        const DataColumn(label: Text('TOTAL TESTS', style: _headerStyle)),
                        const DataColumn(label: Text('STATUS', style: _headerStyle)),
                        const DataColumn(label: Text('ACTIONS', style: _headerStyle)),
                      ],
                      rows: filtered.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final exam = entry.value;
                        final subjects = _getSubjectsForExam(exam.id);
                        final totalChapters = subjects.fold<int>(0, (sum, s) => sum + s.subcategoriesCount);
                        final isSelected = _currentSelectedIds.contains(exam.id);

                        return DataRow(
                          selected: isSelected,
                          color: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return const Color(0xFFF4F7FF);
                            }
                            if (isSelected) {
                              return const Color(0xFFF4F7FF);
                            }
                            if (idx.isEven) {
                              return Colors.white;
                            }
                            return const Color(0xFFFDFDFE);
                          }),
                          cells: [
                            // 0. Checkbox
                            DataCell(
                              Checkbox(
                                value: isSelected,
                                activeColor: const Color(0xFF5636F5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => _toggleSelectRow(exam.id, val),
                              ),
                            ),
                            // 1. Row #
                            DataCell(
                              Text(
                                '${idx + 1}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ),
                        // 2. Exam Details (Icon + Name + ID)
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                alignment: Alignment.center,
                                child: _buildExamIcon(exam.iconUrl),
                              ),
                              const SizedBox(width: 10),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 190),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF101A3A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'ID: ${exam.id}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 3. Subjects Included (Badges)
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: subjects.isEmpty
                                ? const Text('None added yet', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic))
                                : Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      ...subjects.take(2).map((s) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          s.name,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5636F5)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                      if (subjects.length > 2)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '+${subjects.length - 2} more',
                                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                        // 4. Chapters Count
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$totalChapters Chapters',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                            ),
                          ),
                        ),
                        // 5. Total Tests
                        DataCell(
                          Text(
                            '${exam.totalTests} Tests',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ),
                        // 6. Status Badge
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: exam.isPublished ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              exam.isPublished ? 'Published' : 'Hidden',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: exam.isPublished ? const Color(0xFF10B981) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        // 7. Actions (View Syllabus, Edit, Delete)
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye_outlined, size: 17, color: Color(0xFF64748B)),
                                tooltip: 'View Syllabus',
                                onPressed: () => _showCurriculumDialog(exam),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 17, color: Color(0xFF2563EB)),
                                tooltip: 'Edit Exam & Syllabus',
                                onPressed: () => widget.onEditExam(exam),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 17, color: Color(0xFFF43F5E)),
                                tooltip: 'Delete Exam',
                                onPressed: () => widget.onDeleteExam(exam),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF64748B),
    letterSpacing: 0.5,
  );
}
