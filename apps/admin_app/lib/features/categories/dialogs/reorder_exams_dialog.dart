import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';

class ReorderExamsDialog extends StatefulWidget {
  final List<ExamCategoryModel> exams;
  final ValueChanged<List<ExamCategoryModel>> onSaveOrder;

  const ReorderExamsDialog({
    super.key,
    required this.exams,
    required this.onSaveOrder,
  });

  @override
  State<ReorderExamsDialog> createState() => _ReorderExamsDialogState();
}

class _ReorderExamsDialogState extends State<ReorderExamsDialog> {
  late List<ExamCategoryModel> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.exams);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  void _save() {
    final updated = <ExamCategoryModel>[];
    for (int i = 0; i < _items.length; i++) {
      updated.add(_items[i].copyWith(displayOrder: i + 1));
    }
    widget.onSaveOrder(updated);
    Navigator.of(context).pop();
  }

  Widget _buildIcon(String? iconUrl) {
    if (iconUrl == null || iconUrl.trim().isEmpty) {
      return const Text('🎯', style: TextStyle(fontSize: 16));
    }
    final clean = iconUrl.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          clean,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text('🎯', style: TextStyle(fontSize: 16)),
        ),
      );
    }
    return Text(clean, style: const TextStyle(fontSize: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.swap_vert_rounded, color: Color(0xFFF59E0B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reorder Target Exams',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101A3A),
                          ),
                        ),
                        Text(
                          'Change order shown on mobile app homepage',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),

            const Text(
              'Drag using the handles on the right to set the display priority of target exams.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),

            // Reorderable List
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _items.length,
                // ignore: deprecated_member_use
                onReorder: _onReorder,
                itemBuilder: (context, idx) {
                  final exam = _items[idx];
                  return Container(
                    key: ValueKey(exam.id),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          alignment: Alignment.center,
                          child: _buildIcon(exam.iconUrl),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '#${idx + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'ID: ${exam.id}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.drag_handle_rounded, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Save Order', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        child: content,
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: content,
    );
  }
}
