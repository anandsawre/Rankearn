import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BannersTab extends StatefulWidget {
  const BannersTab({super.key});

  @override
  State<BannersTab> createState() => _BannersTabState();
}

class _BannersTabState extends State<BannersTab> {
  String _activeSubTab = 'all'; // 'all', 'promotional', 'spotlights'

  final List<Map<String, dynamic>> _promotionalBanners = [
    {
      'id': 'ban-1',
      'title': '70th BPSC Prelims Maha Mock Series 2026',
      'link': '/tests/bpsc-prelims-mega',
      'priority': 1,
      'isActive': true,
      'imageUrl': 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=800&auto=format&fit=crop&q=60',
    },
    {
      'id': 'ban-2',
      'title': 'SSC CGL Tier 1 All-India Mock Championship',
      'link': '/contests/ssc-cgl-grand',
      'priority': 2,
      'isActive': true,
      'imageUrl': 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800&auto=format&fit=crop&q=60',
    },
  ];

  final List<Map<String, dynamic>> _spotlights = [
    {
      'id': 'spot-1',
      'name': 'Pooja Verma',
      'examName': '70th BPSC Prelims Mock',
      'rank': 'AIR 1',
      'score': '142.5 / 150',
      'message': 'Rankearn speed tests and negative marking simulation were instrumental in my BPSC accuracy preparation!',
      'isActive': true,
      'priority': 1,
    },
    {
      'id': 'spot-2',
      'name': 'Aditya Sharma',
      'examName': 'SSC CGL Tier 1 Full Mock',
      'rank': 'AIR 3',
      'score': '186.0 / 200',
      'message': 'The 1v1 battle arena sharpened my quantitative shortcut calculation under intense time pressure.',
      'isActive': true,
      'priority': 2,
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
          const SizedBox(height: 20),

          // Sub-navigation Filter Bar
          _buildSubNavFilter(),
          const SizedBox(height: 20),

          // Content Area
          if (_activeSubTab == 'all' || _activeSubTab == 'promotional') ...[
            _buildSectionHeader('Promotional Banners (${_promotionalBanners.length})', Icons.image_outlined),
            const SizedBox(height: 12),
            Column(
              children: _promotionalBanners.map((b) => _buildBannerCard(b)).toList(),
            ),
            const SizedBox(height: 24),
          ],

          if (_activeSubTab == 'all' || _activeSubTab == 'spotlights') ...[
            _buildSectionHeader('Candidate Hall of Fame & Spotlight (${_spotlights.length})', Icons.star_outline),
            const SizedBox(height: 12),
            Column(
              children: _spotlights.map((s) => _buildSpotlightCard(s)).toList(),
            ),
          ],
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
                    BoxShadow(
                      color: AppColors.brandPrimary.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Banner & Spotlight Management', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Control Home Screen Hero Carousel and Candidate Spotlight Testimonials', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),

          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.star, size: 16),
                label: const Text('Spotlight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                ),
                onPressed: _showAddSpotlightDialog,
              ),
              const SizedBox(width: 10),
              AppButton(
                label: '+ Banner',
                onPressed: _showAddBannerDialog,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF64748B)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Banners and spotlights refreshed.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubNavFilter() {
    final tabs = [
      ('all', 'All Items', Icons.layers_outlined),
      ('promotional', 'Promotional Banners', Icons.image_outlined),
      ('spotlights', 'Candidate Spotlights', Icons.star_outline),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final isSelected = _activeSubTab == tab.$1;
          return InkWell(
            onTap: () => setState(() => _activeSubTab = tab.$1),
            borderRadius: AppRadii.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandPrimary : Colors.transparent,
                borderRadius: AppRadii.borderMd,
              ),
              child: Row(
                children: [
                  Icon(tab.$3, size: 14, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    tab.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.brandPrimary),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.titleMedium),
      ],
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> banner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: AppRadii.borderMd,
              image: DecorationImage(
                image: NetworkImage(banner['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(banner['title'], style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text('Redirect: ${banner['link']} • Priority: ${banner['priority']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Row(
            children: [
              Switch(
                value: banner['isActive'] == true,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (val) => setState(() => banner['isActive'] = val),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                onPressed: () {
                  setState(() => _promotionalBanners.remove(banner));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed banner "${banner['title']}"')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(Map<String, dynamic> spot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFFFBEB),
            child: const Icon(Icons.military_tech, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(spot['name'], style: AppTypography.titleMedium),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: AppRadii.borderPill,
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Text(
                        spot['rank'],
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Score: ${spot['score']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(spot['examName'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                Text(
                  '“${spot['message']}”',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
            onPressed: () {
              setState(() => _spotlights.remove(spot));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed spotlight for "${spot['name']}"')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddBannerDialog() {
    final titleController = TextEditingController();
    final linkController = TextEditingController(text: '/tests');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Promotional Banner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Banner Title', controller: titleController, hintText: 'e.g. 70th BPSC Mega League'),
            const SizedBox(height: 12),
            AppTextField(label: 'Redirect Route / URL', controller: linkController, hintText: '/tests/bpsc'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Add Banner',
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _promotionalBanners.insert(0, {
                    'id': 'ban-${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'link': linkController.text,
                    'priority': 1,
                    'isActive': true,
                    'imageUrl': 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=800&auto=format&fit=crop&q=60',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Banner added to home carousel.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddSpotlightDialog() {
    final nameController = TextEditingController();
    final examController = TextEditingController(text: '70th BPSC');
    final rankController = TextEditingController(text: 'AIR 1');
    final scoreController = TextEditingController(text: '145 / 150');
    final quoteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Candidate Spotlight'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Candidate Name', controller: nameController, hintText: 'e.g. Sneha Patel'),
              const SizedBox(height: 12),
              AppTextField(label: 'Exam Target', controller: examController, hintText: '70th BPSC'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Rank', controller: rankController, hintText: 'AIR 1')),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Score', controller: scoreController, hintText: '145 / 150')),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(label: 'Testimonial Quote', controller: quoteController, hintText: 'How Rankearn helped...', maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Save Spotlight',
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _spotlights.insert(0, {
                    'id': 'spot-${DateTime.now().millisecondsSinceEpoch}',
                    'name': nameController.text,
                    'examName': examController.text,
                    'rank': rankController.text,
                    'score': scoreController.text,
                    'message': quoteController.text.isEmpty ? 'Rankearn helped me ace my exam preparation!' : quoteController.text,
                    'isActive': true,
                    'priority': 1,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Candidate spotlight added successfully!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
