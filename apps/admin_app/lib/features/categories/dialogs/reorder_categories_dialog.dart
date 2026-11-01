import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
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
    return AppModalDialog(
      title: 'Reorder Categories',
      subtitle: 'Drag and drop categories to reorder student visibility',
      iconData: Icons.swap_vert_rounded,
      gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      maxWidth: 540,
      maxHeight: 650,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Save Order', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Drag using the handles on the right to reorder categories.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 380,
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
                    border: Border.all(color: const Color(0xFFCBD5E1)),
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
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
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
        ],
      ),
    );
  }
}
