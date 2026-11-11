import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

class ManageSubcategoriesDialog extends StatefulWidget {
  final List<CategoryItem> categories;
  final CategoryItem? initialCategory;
  final VoidCallback? onChaptersUpdated;

  const ManageSubcategoriesDialog({
    super.key,
    required this.categories,
    this.initialCategory,
    this.onChaptersUpdated,
  });

  @override
  State<ManageSubcategoriesDialog> createState() => _ManageSubcategoriesDialogState();
}

class _ManageSubcategoriesDialogState extends State<ManageSubcategoriesDialog> {
  CategoryItem? _selectedCategory;
  List<String> _chapters = [];
  bool _isSaving = false;
  String? _errorMessage;
  final _newChapterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ??
        (widget.categories.isNotEmpty ? widget.categories.first : null);
    if (_selectedCategory != null) {
      _chapters = List<String>.from(_selectedCategory!.topics);
    }
  }

  @override
  void dispose() {
    _newChapterCtrl.dispose();
    super.dispose();
  }

  Future<void> _persistChapters(List<String> updated) async {
    final category = _selectedCategory;
    if (category == null) return;

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      setState(() => _errorMessage = 'Database not connected. Cannot save chapters.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await client.from('categories').update({
        'topics': updated,
        'subcategories_count': updated.length,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', category.id);

      if (!mounted) return;
      setState(() {
        _chapters = updated;
        _selectedCategory = category.copyWith(
          topics: updated,
          subcategoriesCount: updated.length,
        );
        _isSaving = false;
      });
      widget.onChaptersUpdated?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to update chapters in Supabase: $e';
      });
    }
  }

  Future<void> _addChapter() async {
    final text = _newChapterCtrl.text.trim();
    if (text.isEmpty || _selectedCategory == null) return;
    if (_chapters.any((c) => c.toLowerCase() == text.toLowerCase())) {
      setState(() => _errorMessage = '"$text" is already in this subject.');
      return;
    }

    final updated = [..._chapters, text];
    _newChapterCtrl.clear();
    await _persistChapters(updated);
  }

  Future<void> _removeChapter(int index) async {
    final updated = List<String>.from(_chapters)..removeAt(index);
    await _persistChapters(updated);
  }

  @override
  Widget build(BuildContext context) {
    final cat = _selectedCategory;

    return AppModalDialog(
      title: 'Manage Chapters & Units',
      subtitle: cat != null
          ? '${_chapters.length} chapters configured for ${cat.name}'
          : 'Create a subject first to manage chapters',
      iconData: Icons.account_tree_outlined,
      gradientColors: const [Color(0xFF00B368), Color(0xFF10B981)],
      maxWidth: 620,
      maxHeight: 700,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B368),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: cat == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No subjects found in database. Create a subject first.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDA4AF)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                Row(
                  children: [
                    const Text('Select Subject:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppDropdown<String>(
                        value: cat.id,
                        items: widget.categories.map((c) {
                          return AppDropdownItem<String>(
                            value: c.id,
                            label: c.name,
                            leading: Icon(c.iconData, size: 16, color: c.parsedColor),
                          );
                        }).toList(),
                        onChanged: (newCatId) {
                          if (newCatId != null) {
                            final found = widget.categories.firstWhere(
                              (c) => c.id == newCatId,
                              orElse: () => cat,
                            );
                            setState(() {
                              _selectedCategory = found;
                              _chapters = List<String>.from(found.topics);
                              _errorMessage = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newChapterCtrl,
                        enabled: !_isSaving,
                        decoration: AppModalDialog.inputDecoration(
                          'Enter new chapter / unit name...',
                          focusColor: const Color(0xFF00B368),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        onSubmitted: (_) => _addChapter(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B368),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(_isSaving ? 'Saving...' : 'Add', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      onPressed: _isSaving ? null : _addChapter,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Existing Chapters / Units (${_chapters.length})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 280,
                  child: _chapters.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open_rounded, size: 36, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 6),
                              Text('No chapters saved for this subject yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _chapters.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 6),
                          itemBuilder: (context, idx) {
                            final chapterName = _chapters[idx];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                children: [
                                  Text('${idx + 1}.', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      chapterName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF101A3A)),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFF43F5E)),
                                    onPressed: _isSaving ? null : () => _removeChapter(idx),
                                  ),
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
