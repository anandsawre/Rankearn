import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'widgets/community_hero_card.dart';
import 'widgets/community_quick_actions.dart';
import 'widgets/community_kpi_row.dart';
import 'widgets/create_post_card.dart';
import 'widgets/community_post_card.dart';
import 'widgets/community_poll_card.dart';

class PostsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialPosts;
  const PostsTab({super.key, this.initialPosts});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  String _filterType = 'all'; // 'all', 'published', 'scheduled', 'draft'
  String _sortOrder = 'latest'; // 'latest', 'oldest'
  String _activeSubTab = 'posts';

  static final List<Map<String, dynamic>> _defaultMockPosts = [
    {
      'id': 'post-1',
      'title': 'RRB Technician Grade 3 – Daily Practice Set 🔥',
      'content': 'आज का विषय: Cell Biology 🧬\n10 महत्वपूर्ण MCQs के साथ अभी प्रैक्टिस करें।',
      'excerpt': 'आज का विषय: Cell Biology 🧬 10 महत्वपूर्ण MCQs के साथ अभी प्रैक्टिस करें।',
      'category': 'RRB',
      'type': 'announcement',
      'date': 'Nov 11, 2026 • 10:30 AM',
      'isPinned': true,
      'views': '12,480',
      'likes': '1,426',
      'comments': '278',
      'shares': '86',
      'imageUrl': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&auto=format&fit=crop&q=60',
    },
    {
      'id': 'post-2',
      'title': 'अगला Live Quiz किस विषय पर हो? 🤔',
      'type': 'poll',
      'category': 'Quiz',
      'date': 'Nov 10, 2026 • 06:15 PM • Poll',
      'isPinned': false,
      'views': '9,840',
      'likes': '782',
      'comments': '412',
      'shares': '45',
      'options': [
        {'label': 'General Science', 'pct': 0.42, 'count': '42% (3,920)'},
        {'label': 'Mathematics', 'pct': 0.28, 'count': '28% (2,610)'},
        {'label': 'Reasoning', 'pct': 0.18, 'count': '18% (1,680)'},
        {'label': 'General Awareness', 'pct': 0.12, 'count': '12% (1,120)'},
      ],
    },
    {
      'id': 'post-3',
      'title': 'RRB Technician – Cell Biology Handwritten Notes 📑',
      'content': 'Cell Biology के महत्वपूर्ण और परीक्षा-उपयोगी नोट्स PDF में डाउनलोड करें!',
      'excerpt': 'Cell Biology के महत्वपूर्ण और परीक्षा-उपयोगी नोट्स PDF में डाउनलोड करें!',
      'category': 'Study',
      'type': 'document',
      'isPdf': true,
      'date': 'Nov 09, 2026 • 09:00 AM',
      'isPinned': false,
      'views': '18,320',
      'likes': '2,146',
      'comments': '564',
      'shares': '192',
    },
  ];

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _posts = List.from(_defaultMockPosts);
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final res = await client.from('posts').select().order('created_at', ascending: false);
      if (mounted) {
        final list = (res as List).map((row) {
          return {
            'id': row['id']?.toString() ?? '',
            'title': row['title']?.toString() ?? '',
            'category': row['category']?.toString() ?? 'General',
            'excerpt': row['excerpt']?.toString() ?? row['content']?.toString() ?? '',
            'content': row['content']?.toString() ?? '',
            'imageUrl': row['image_url']?.toString() ?? '',
            'type': row['category'] == 'Poll' ? 'poll' : 'announcement',
            'date': row['created_at'] != null ? row['created_at'].toString().split('T').first : 'Recent',
            'views': '1,240',
            'likes': '145',
            'comments': '28',
            'shares': '12',
            'isPinned': false,
          };
        }).toList();

        setState(() {
          _posts = list.isNotEmpty ? list : List.from(_defaultMockPosts);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _posts = List.from(_defaultMockPosts);
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredPosts() {
    return _posts.where((p) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final title = (p['title'] ?? '').toString().toLowerCase();
        final content = (p['content'] ?? p['excerpt'] ?? '').toString().toLowerCase();
        if (!title.contains(query) && !content.contains(query)) {
          return false;
        }
      }

      if (_activeSubTab == 'polls' && p['type'] != 'poll') return false;
      if (_filterType == 'polls' && p['type'] != 'poll') return false;
      if (_filterType == 'announcements' && p['type'] != 'announcement') return false;

      return true;
    }).toList();
  }

  Future<void> _handlePublishPost(Map<String, dynamic> post) async {
    setState(() {
      _posts.insert(0, post);
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        final slug = post['title'].toString().trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        await client.from('posts').insert({
          'id': post['id'],
          'slug': slug,
          'title': post['title'],
          'content': post['content'],
          'excerpt': post['excerpt'],
          'category': post['category'],
          'author_name': 'Rankearn Academic Team',
          'is_active': true,
          'image_url': post['imageUrl'] ?? '',
        });
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community post broadcast live to students!')),
      );
    }
  }

  void _handleDeletePost(Map<String, dynamic> post) async {
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
        SnackBar(content: Text('Deleted post "${post['title']}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.adminPurple),
        ),
      );
    }

    final filteredPosts = _getFilteredPosts();

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner (Left) + Quick Actions (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              final heroCard = CommunityHeroCard(
                onRefresh: _fetchPosts,
              );
              final quickActions = CommunityQuickActions(
                onCommunityPost: () {
                  setState(() {
                    _activeSubTab = 'posts';
                    _filterType = 'all';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched to Community Post feed')),
                  );
                },
                onPoll: () {
                  setState(() {
                    _activeSubTab = 'polls';
                    _filterType = 'poll';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched to Live Polls')),
                  );
                },
                onComments: () {
                  setState(() => _activeSubTab = 'comments');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Community Comments Moderation...')),
                  );
                },
                onReports: () {
                  setState(() => _activeSubTab = 'reports');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing Reported Community Posts...')),
                  );
                },
                onSettings: () {
                  setState(() => _activeSubTab = 'settings');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Community Rules & Moderation Settings...')),
                  );
                },
              );

              if (constraints.maxWidth > 980) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 52,
                      child: heroCard,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 48,
                      child: quickActions,
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heroCard,
                    const SizedBox(height: 16),
                    quickActions,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),

          // 2. Community Overview Horizontal KPI Row (Dashboard Style)
          const CommunityKpiRow(),
          const SizedBox(height: 18),

          // 3. Post Creation & Stream Feed Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 980;

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel: Create Community Post (340px)
                    SizedBox(
                      width: 340,
                      child: CreatePostCard(
                        onPublish: _handlePublishPost,
                        onReset: () {},
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Center/Right Panel: Post Feed (Expanded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFeedHeader(filteredPosts.length),
                          const SizedBox(height: 14),
                          ...filteredPosts.map((p) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: p['type'] == 'poll'
                                  ? CommunityPollCard(
                                      poll: p,
                                      onPin: () => setState(() => p['isPinned'] = !(p['isPinned'] == true)),
                                      onEdit: () {},
                                      onAnalytics: () {},
                                      onDelete: () => _handleDeletePost(p),
                                    )
                                  : CommunityPostCard(
                                      post: p,
                                      onPin: () => setState(() => p['isPinned'] = !(p['isPinned'] == true)),
                                      onEdit: () {},
                                      onDuplicate: () => _handlePublishPost(Map<String, dynamic>.from(p)),
                                      onDelete: () => _handleDeletePost(p),
                                    ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    CreatePostCard(
                      onPublish: _handlePublishPost,
                      onReset: () {},
                    ),
                    const SizedBox(height: 18),
                    _buildFeedHeader(filteredPosts.length),
                    const SizedBox(height: 14),
                    ...filteredPosts.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: p['type'] == 'poll'
                            ? CommunityPollCard(
                                poll: p,
                                onPin: () => setState(() => p['isPinned'] = !(p['isPinned'] == true)),
                                onEdit: () {},
                                onAnalytics: () {},
                                onDelete: () => _handleDeletePost(p),
                              )
                            : CommunityPostCard(
                                post: p,
                                onPin: () => setState(() => p['isPinned'] = !(p['isPinned'] == true)),
                                onEdit: () {},
                                onDuplicate: () => _handlePublishPost(Map<String, dynamic>.from(p)),
                                onDelete: () => _handleDeletePost(p),
                              ),
                      );
                    }),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, size: 18, color: AppColors.adminPurple),
          const SizedBox(width: 8),
          Text(
            'Posts ($count)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.adminPrimaryText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AppTextField(
              controller: _searchController,
              hintText: 'Search posts...',
              prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.adminSecondaryText),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: AppDropdown<String>(
              inlineLabel: true,
              value: _filterType,
              items: const [
                AppDropdownItem(value: 'all', label: 'All Posts'),
                AppDropdownItem(value: 'announcements', label: 'Articles'),
                AppDropdownItem(value: 'polls', label: 'Polls'),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _filterType = v);
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: AppDropdown<String>(
              inlineLabel: true,
              value: _sortOrder,
              items: const [
                AppDropdownItem(value: 'latest', label: 'Latest'),
                AppDropdownItem(value: 'oldest', label: 'Oldest'),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _sortOrder = v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
