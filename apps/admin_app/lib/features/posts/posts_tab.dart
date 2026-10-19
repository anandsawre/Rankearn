import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 'post-1',
      'title': 'BPSC 70th CCE Notification Out: 1,957 Vacancies Declared',
      'category': 'Exam Alerts',
      'excerpt': 'Bihar Public Service Commission has officially published the 70th Combined Competitive Examination notification with key syllabus changes.',
      'imageUrl': 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&auto=format&fit=crop&q=60',
      'isActive': true,
      'date': 'Oct 18, 2026',
    },
    {
      'id': 'post-2',
      'title': 'Daily Current Affairs: Bihar Economic Survey & GSDP Growth',
      'category': 'Current Affairs',
      'excerpt': 'Comprehensive analytical breakdown of Bihar Economic Survey 2025-26 highlighting per capita income, agricultural subsidies, and industrial corridor progress.',
      'imageUrl': 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800&auto=format&fit=crop&q=60',
      'isActive': true,
      'date': 'Oct 17, 2026',
    },
    {
      'id': 'post-3',
      'title': 'SSC CGL Tier 1 Negative Marking Strategy & Time Budgeting',
      'category': 'Preparation Strategy',
      'excerpt': 'Mastering section sequence: Solving General Awareness in under 7 minutes to reserve 28 minutes for Quantitative Aptitude.',
      'imageUrl': 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800&auto=format&fit=crop&q=60',
      'isActive': true,
      'date': 'Oct 15, 2026',
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

          // Updates Grid
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
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(image: NetworkImage(post['imageUrl']), fit: BoxFit.cover),
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
                    Text(post['date'], style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(post['title'], style: AppTypography.titleMedium),
                const SizedBox(height: 6),
                Text(
                  post['excerpt'],
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
                      onPressed: () {
                        setState(() => _posts.remove(post));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted "${post['title']}"')),
                        );
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
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _posts.insert(0, {
                    'id': 'post-${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'category': catController.text,
                    'excerpt': excerptController.text.isEmpty ? 'Key updates published by Rankearn academic panel.' : excerptController.text,
                    'imageUrl': 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&auto=format&fit=crop&q=60',
                    'isActive': true,
                    'date': 'Today',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Article published live to candidate feeds!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
