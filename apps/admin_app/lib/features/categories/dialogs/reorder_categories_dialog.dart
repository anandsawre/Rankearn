import 'package:flutter/material.dart';
import '../models/category_item.dart';

class ReorderCategoriesDialog extends StatefulWidget {
  final List<CategoryItem> categories;
  final ValueChanged<List<CategoryItem>> onSaveOrder;

  const ReorderCategoriesDialog({
    super.key,
    required this.categories,
    required this.onSaveOrder,
  });

  @override
  State<ReorderCategoriesDialog> createState() => _ReorderCategoriesDialogState();
}

class _ReorderCategoriesDialogState extends State<ReorderCategoriesDialog> {
  late List<CategoryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.categories);
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
    final updated = <CategoryItem>[];
    for (int i = 0; i < _items.length; i++) {
      updated.add(_items[i].copyWith(displayOrder: i + 1));
    }
    widget.onSaveOrder(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 650),
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
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.swap_vert_rounded, color: Color(0xFFF59E0B), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Reorder Categories',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101A3A),
                        ),
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
                'Drag and drop categories using the handle on the right to reorder how they appear to students.',
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
                    final item = _items[idx];
                    return Container(
                      key: ValueKey(item.id),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: item.parsedColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Icon(item.iconData, color: item.parsedColor, size: 15),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '#${idx + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Order'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
