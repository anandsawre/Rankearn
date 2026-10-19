import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class PostsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialPosts;
  const PostsTab({super.key, this.initialPosts});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosts != null) {
      _posts = List.from(widget.initialPosts!);
      _isLoading = false;
    } else {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await client.from('posts').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _posts = (res as List).map((row) {
            return {
              'id': row['id']?.toString() ?? '',
              'title': row['title']?.toString() ?? '',
              'category': row['category']?.toString() ?? 'General',
              'excerpt': row['excerpt']?.toString() ?? '',
              'imageUrl': row['image_url']?.toString() ?? 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&auto=format&fit=crop&q=60',
              'isActive': row['is_active'] == true,
              'date': row['created_at'] != null ? row['created_at'].toString().split('T').first : 'Recent',
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

          // Updates Grid or Empty State
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppColors.brandPrimary),
              ),
            )
          else if (_posts.isEmpty)
            _buildEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _posts.map((p) {
                    final cardWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
                    return SizedBox(width: cardWidth, child: _buildPostCard(p));
                  }).toList(),
                );
              },
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
            child: const Icon(Icons.feed_outlined, color: AppColors.brandPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No Published Articles Yet', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Keep your candidates informed by publishing syllabus breakdowns, exam alerts, and current affairs analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: '+ Create First Article',
            onPressed: _showNewArticleDialog,
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
                child: const Icon(Icons.feed_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Official Updates & Articles', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Publish Exam Notifications, Current Affairs, and Editorial Articles', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),

          AppButton(
            label: '+ New Article',
            onPressed: _showNewArticleDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final imageUrl = post['imageUrl']?.toString() ?? '';

    return Container(
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
          // Banner Image
          if (imageUrl.isNotEmpty)
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (_, _) {},
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: AppRadii.borderPill,
                      ),
                      child: Text(
                        (post['category'] as String).toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.brandPrimaryDark),
                      ),
                    ),
                    Text(post['date'].toString(), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(post['title'].toString(), style: AppTypography.titleMedium),
                const SizedBox(height: 6),
                Text(
                  post['excerpt'].toString(),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('Published Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                      onPressed: () async {
                        final postId = post['id']?.toString() ?? '';
                        setState(() => _posts.remove(post));
                        final client = SupabaseConfig.clientSafe;
                        if (client != null && postId.isNotEmpty) {
                          try {
                            await client.from('posts').delete().eq('id', postId);
                          } catch (_) {}
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted "${post['title']}"')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewArticleDialog() {
    final titleController = TextEditingController();
    final catController = TextEditingController(text: 'Current Affairs');
    final excerptController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish New Article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Article Title', controller: titleController, hintText: 'e.g. 70th BPSC Prelims Strategy'),
            const SizedBox(height: 12),
            AppTextField(label: 'Category', controller: catController, hintText: 'Current Affairs'),
            const SizedBox(height: 12),
            AppTextField(label: 'Excerpt Summary', controller: excerptController, hintText: 'Short synopsis of the update...', maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Publish Live',
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final newId = 'post-${DateTime.now().millisecondsSinceEpoch}';
                final slug = titleController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
                final newPost = {
                  'id': newId,
                  'title': titleController.text.trim(),
                  'category': catController.text.trim(),
                  'excerpt': excerptController.text.isEmpty ? 'Key updates published by Rankearn academic panel.' : excerptController.text.trim(),
                  'imageUrl': 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&auto=format&fit=crop&q=60',
                  'isActive': true,
                  'date': 'Today',
                };

                setState(() {
                  _posts.insert(0, newPost);
                });
                Navigator.pop(ctx);

                final client = SupabaseConfig.clientSafe;
                if (client != null) {
                  try {
                    await client.from('posts').insert({
                      'id': newId,
                      'slug': slug,
                      'title': titleController.text.trim(),
                      'content': excerptController.text.trim(),
                      'excerpt': excerptController.text.trim(),
                      'category': catController.text.trim(),
                      'author_name': 'Rankearn Academic Team',
                      'is_active': true,
                      'image_url': 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&auto=format&fit=crop&q=60',
                    });
                  } catch (_) {}
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article published live to candidate feeds!')),
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
