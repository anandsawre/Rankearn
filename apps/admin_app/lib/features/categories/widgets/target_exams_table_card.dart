import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';
import '../models/exam_icon_helper.dart';

/// Target Exams Table Card powered by unified [AdminDataTableCard].
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
  Set<String> _localSelectedIds = {};

  Set<String> get _currentSelectedIds => widget.selectedIds ?? _localSelectedIds;

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

  Widget _buildExamIcon(String? iconUrl) => buildExamIconWidget(iconUrl, size: 20);

  void _showCurriculumDialog(ExamCategoryModel exam) {
    final subjects = _getSubjectsForExam(exam.id);

    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: exam.name,
        subtitle: 'Exam Curriculum (${subjects.length} Subjects mapped)',
        iconData: Icons.menu_book_outlined,
        gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
        maxWidth: 540,
        maxHeight: 650,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Curriculum', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onEditExam(exam);
            },
          ),
        ],
        child: subjects.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 36),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 40, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 10),
                    Text(
                      'No subjects linked to ${exam.name} yet.',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Click "Edit Curriculum" to add subjects and chapters.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
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
                      border: Border.all(color: const Color(0xFFCBD5E1)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExams;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final allSelected = filtered.isNotEmpty && filtered.every((e) => _currentSelectedIds.contains(e.id));

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    final double detailsWidth = (cardWidth * 0.22).clamp(180.0, 320.0);
    final double subjectsWidth = (cardWidth * 0.20).clamp(160.0, 280.0);
    const double fixedColumnsWidth = 24.0 + 24.0 + 95.0 + 85.0 + 85.0 + 110.0 + 32.0;
    final double totalNeededWidth = fixedColumnsWidth + detailsWidth + subjectsWidth;
    final double remainingSpace = cardWidth - totalNeededWidth;
    final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 7).clamp(8.0, 56.0) : 8.0;

    return AdminDataTableCard(
      title: 'Target Exams & Syllabus',
      totalCount: widget.exams.length,
      icon: Icons.explore_rounded,
      iconBgColor: AppColors.brandPurple,
      searchQuery: _searchQuery,
      searchHint: 'Search target exams (e.g. BPSC, Railway, SSC) or subjects...',
      onSearchChanged: (val) => setState(() => _searchQuery = val),
      itemLabel: 'target exams',
      columnSpacing: dynamicColumnSpacing,
      minWidth: 860.0,
      headerActions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Target Exam'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            elevation: 0,
            textStyle: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: widget.onAddExam,
        ),
      ],
      customBody: widget.isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandPurple),
              ),
            )
          : (isMobile && filtered.isNotEmpty
              ? ListView.separated(
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
                        border: Border.all(color: isSelected ? AppColors.brandPurple : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.brandPurple,
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
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontHeading,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${subjects.length} Subjects • ${exam.totalTests} Tests',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontHeading,
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AdminTableActionButton(
                                icon: Icons.remove_red_eye_outlined,
                                tooltip: 'View Syllabus',
                                onPressed: () => _showCurriculumDialog(exam),
                              ),
                              const SizedBox(width: 4),
                              AdminTableActionButton(
                                icon: Icons.edit_outlined,
                                tooltip: 'Edit',
                                onPressed: () => widget.onEditExam(exam),
                              ),
                              const SizedBox(width: 4),
                              AdminTableActionButton(
                                icon: Icons.delete_outline_rounded,
                                tooltip: 'Delete',
                                color: AppColors.errorRose,
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
                                child: Text(
                                  s.name,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontHeading,
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                )
              : null),
      columns: [
        DataColumn(
          label: SizedBox(
            width: 22,
            child: Checkbox(
              value: allSelected,
              activeColor: AppColors.brandPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: _toggleSelectAll,
            ),
          ),
        ),
        DataColumn(label: Text('#', style: _headerStyle)),
        DataColumn(
          label: SizedBox(
            width: detailsWidth,
            child: Text('Target Exam', style: _headerStyle),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: subjectsWidth,
            child: Text('Subjects Included', style: _headerStyle),
          ),
        ),
        DataColumn(label: Text('Chapters', style: _headerStyle)),
        DataColumn(label: Text('Total Tests', style: _headerStyle)),
        DataColumn(label: Text('Status', style: _headerStyle)),
        DataColumn(label: Text('Actions', style: _headerStyle)),
      ],
      rows: filtered.asMap().entries.map((entry) {
        final idx = entry.key;
        final exam = entry.value;
        final subjects = _getSubjectsForExam(exam.id);
        final totalChapters = subjects.fold<int>(0, (sum, s) => sum + s.subcategoriesCount);
        final isSelected = _currentSelectedIds.contains(exam.id);

        return DataRow(
          selected: isSelected,
          cells: [
            // 0. Checkbox
            DataCell(
              SizedBox(
                width: 22,
                child: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) => _toggleSelectRow(exam.id, val),
                ),
              ),
            ),
            // 1. Row #
            DataCell(
              Text(
                '${idx + 1}',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // 2. Exam Details
            DataCell(
              SizedBox(
                width: detailsWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      alignment: Alignment.center,
                      child: _buildExamIcon(exam.iconUrl),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.name,
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${exam.id}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 3. Subjects Included
            DataCell(
              SizedBox(
                width: subjectsWidth,
                child: subjects.isEmpty
                    ? Text(
                        'None added yet',
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      )
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
                              style: TextStyle(
                                fontFamily: AppTypography.fontHeading,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandPurple,
                              ),
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
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            // 4. Chapters Count
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$totalChapters Chapters',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ),
            // 5. Total Tests
            DataCell(
              Text(
                '${exam.totalTests} Tests',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // 6. Status Badge
            DataCell(
              AdminTableStatusBadge(
                label: exam.isPublished ? 'Published' : 'Hidden',
                backgroundColor: exam.isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                borderColor: exam.isPublished ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                textColor: exam.isPublished ? const Color(0xFF16A34A) : AppColors.textSecondary,
              ),
            ),
            // 7. Actions
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.remove_red_eye_outlined,
                    tooltip: 'View Syllabus',
                    onPressed: () => _showCurriculumDialog(exam),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit Exam & Syllabus',
                    onPressed: () => widget.onEditExam(exam),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete Exam',
                    color: AppColors.errorRose,
                    onPressed: () => widget.onDeleteExam(exam),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
      emptyState: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.explore_off_outlined, size: 40, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty ? 'No target exams match your search' : 'No target exams in database yet',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search keyword'
                  : 'Click "+ Add Target Exam" above to add your first exam and syllabus.',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle get _headerStyle => TextStyle(
        fontFamily: AppTypography.fontHeading,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );
}
