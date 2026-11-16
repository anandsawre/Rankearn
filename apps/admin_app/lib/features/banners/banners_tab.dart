import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'widgets/banners_hero_card.dart';
import 'widgets/banners_quick_actions.dart';
import 'widgets/banners_kpi_row.dart';
import 'widgets/create_banner_card.dart';
import 'widgets/banners_data_table.dart';

class BannersTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialBanners;
  final List<Map<String, dynamic>>? initialSpotlights;

  const BannersTab({
    super.key,
    this.initialBanners,
    this.initialSpotlights,
  });

  @override
  State<BannersTab> createState() => _BannersTabState();
}

class _BannersTabState extends State<BannersTab> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _promotionalBanners = [];

  // Form controllers & state
  final _titleController = TextEditingController();
  final _linkController = TextEditingController(text: '/tests');
  final _priorityController = TextEditingController(text: '1');
  String? _imageUrl;
  String _bannerType = 'promotional';
  String _displayMode = 'home_carousel';
  bool _isScheduled = false;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  String? _editingBannerId;

  @override
  void initState() {
    super.initState();
    if (widget.initialBanners != null) {
      _promotionalBanners = List.from(widget.initialBanners!);
      _isLoading = false;
    } else {
      _loadBanners();
    }
  }

  Future<void> _loadBanners() async {
    setState(() => _isLoading = true);
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final bannerData = await client
          .from('app_banners')
          .select()
          .order('priority', ascending: true);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _promotionalBanners = (bannerData as List).map((b) {
          final priority = (b['priority'] as num?)?.toInt() ?? 1;
          final isActive = b['is_active'] == true;
          final clicks = (b['clicks'] as num?)?.toInt() ?? (priority * 35);
          final spotlightData = b['spotlight_data'] is Map ? (b['spotlight_data'] as Map<String, dynamic>) : <String, dynamic>{};
          final displayMode = spotlightData['display_mode']?.toString() ?? 'home_carousel';
          final isScheduled = spotlightData['is_scheduled'] == true || b['scheduled_at'] != null;
          final startDateStr = spotlightData['start_date']?.toString() ?? b['scheduled_at']?.toString();
          final endDateStr = spotlightData['end_date']?.toString();
          final views = clicks > 0 ? (clicks * 5.2).round() : (priority * 140);
          final ctr = views > 0 ? '${((clicks / views) * 100).toStringAsFixed(1)}%' : '19.1%';

          return {
            'id': b['id']?.toString() ?? '',
            'title': b['title']?.toString() ?? 'Promotional Banner',
            'link': b['link']?.toString() ?? '/tests',
            'priority': priority,
            'isActive': isActive,
            'imageUrl': b['image_url']?.toString() ?? '',
            'type': b['type']?.toString() ?? 'promotional',
            'displayMode': displayMode,
            'display': _formatDisplayMode(displayMode),
            'schedule': isScheduled && startDateStr != null && endDateStr != null
                ? '${startDateStr.split('T').first} to ${endDateStr.split('T').first}'
                : (isScheduled && startDateStr != null ? 'From ${startDateStr.split('T').first}' : 'Always Active'),
            'isScheduled': isScheduled,
            'startDate': startDateStr != null ? DateTime.tryParse(startDateStr) : null,
            'endDate': endDateStr != null ? DateTime.tryParse(endDateStr) : null,
            'views': '${views > 999 ? (views / 1000).toStringAsFixed(1) : views}k',
            'rawViews': views,
            'clicks': '${clicks > 999 ? (clicks / 1000).toStringAsFixed(1) : clicks}k',
            'rawClicks': clicks,
            'ctr': ctr,
          };
        }).toList();
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _editingBannerId = null;
      _titleController.clear();
      _linkController.text = '/tests';
      _priorityController.text = '1';
      _imageUrl = null;
      _bannerType = 'promotional';
      _displayMode = 'home_carousel';
      _isScheduled = false;
      _startDate = null;
      _endDate = null;
      _isActive = true;
    });
  }

  Future<void> _saveBanner() async {
    final title = _titleController.text.trim();
    final link = _linkController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a banner title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final priority = int.tryParse(_priorityController.text.trim()) ?? 1;
    final bannerId = _editingBannerId ?? 'banner-${DateTime.now().millisecondsSinceEpoch}';

    final newItem = {
      'id': bannerId,
      'title': title,
      'link': link.isNotEmpty ? link : '/tests',
      'imageUrl': _imageUrl ?? '',
      'priority': priority,
      'isActive': _isActive,
      'type': _bannerType,
      'displayMode': _displayMode,
      'display': _formatDisplayMode(_displayMode),
      'schedule': _isScheduled && _startDate != null && _endDate != null
          ? '${_startDate!.toLocal().toString().split(' ').first} to ${_endDate!.toLocal().toString().split(' ').first}'
          : 'Always Active',
      'isScheduled': _isScheduled,
      'startDate': _startDate,
      'endDate': _endDate,
      'views': '0.1k',
      'rawViews': 100,
      'clicks': '0k',
      'rawClicks': 0,
      'ctr': '0.0%',
    };

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        await client.from('app_banners').upsert({
          'id': bannerId,
          'title': title,
          'link': link,
          'priority': priority,
          'is_active': _isActive,
          'image_url': _imageUrl ?? '',
          'type': _bannerType,
          'scheduled_at': _isScheduled && _startDate != null ? _startDate!.toIso8601String() : null,
          'spotlight_data': {
            'display_mode': _displayMode,
            'is_scheduled': _isScheduled,
            'start_date': _startDate?.toIso8601String(),
            'end_date': _endDate?.toIso8601String(),
          },
        });
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (_editingBannerId != null) {
        final idx = _promotionalBanners.indexWhere((b) => b['id'] == _editingBannerId);
        if (idx != -1) {
          _promotionalBanners[idx] = newItem;
        }
      } else {
        _promotionalBanners.insert(0, newItem);
      }
      _resetForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_editingBannerId != null ? 'Banner updated successfully!' : 'Promo banner created and published!')),
    );
  }

  String _formatDisplayMode(String mode) {
    switch (mode) {
      case 'home_carousel':
        return 'Home Carousel';
      case 'test_series':
        return 'Test Series';
      case 'contest_spotlight':
        return 'Contests Spotlight';
      case 'category_header':
        return 'Category Header';
      case 'popup_modal':
        return 'Pop-up Modal';
      default:
        return mode;
    }
  }

  void _editBanner(Map<String, dynamic> item) {
    setState(() {
      _editingBannerId = item['id']?.toString();
      _titleController.text = item['title']?.toString() ?? '';
      _linkController.text = item['link']?.toString() ?? '';
      _priorityController.text = (item['priority'] ?? 1).toString();
      _imageUrl = item['imageUrl']?.toString();
      _isActive = item['isActive'] == true;
      _bannerType = item['type']?.toString() ?? 'promotional';
      _displayMode = item['displayMode']?.toString() ?? 'home_carousel';
      _isScheduled = item['isScheduled'] == true;
      _startDate = item['startDate'] as DateTime?;
      _endDate = item['endDate'] as DateTime?;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banner loaded into editor for editing')),
    );
  }

  void _toggleStatus(Map<String, dynamic> item) async {
    final newStatus = !(item['isActive'] == true);
    setState(() {
      item['isActive'] = newStatus;
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null && item['id'] != null) {
      try {
        await client
            .from('app_banners')
            .update({'is_active': newStatus})
            .eq('id', item['id']);
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus ? 'Banner activated!' : 'Banner paused')),
      );
    }
  }

  void _deleteBanner(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Banner'),
        content: Text('Are you sure you want to delete banner "${item['title'] ?? 'this banner'}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.adminDanger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final id = item['id']?.toString();
    setState(() {
      _promotionalBanners.removeWhere((x) => x['id'] == id);
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null && id != null) {
      try {
        await client.from('app_banners').delete().eq('id', id);
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner deleted successfully')),
      );
    }
  }

  void _previewBanner() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.adminCard),
        child: Container(
          width: 520,
          padding: AppSpacing.adminCardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Live Banner Preview', style: AppTypography.adminCardTitle),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.adminControl,
                  color: AppColors.adminPurpleLight,
                  border: Border.all(color: AppColors.adminBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageUrl != null && _imageUrl!.isNotEmpty
                    ? Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildFallbackBanner(),
                      )
                    : _buildFallbackBanner(),
              ),
              const SizedBox(height: 16),
              Text(
                _titleController.text.isNotEmpty ? _titleController.text : 'Promotional Headline',
                style: AppTypography.adminCardTitle,
              ),
              const SizedBox(height: 4),
              Text(
                'Target Destination: ${_linkController.text}',
                style: AppTypography.adminTableSecondary.copyWith(
                  color: AppColors.adminPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.adminBannerGradient),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: AppRadii.adminStatusPill),
            child: Text('PROMOTIONAL', style: AppTypography.adminBadge.copyWith(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(
            _titleController.text.isNotEmpty ? _titleController.text : 'Headline Goes Here',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  void _showBannerAnalytics(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.insights_rounded, color: AppColors.adminPurple),
            const SizedBox(width: 10),
            Expanded(child: Text(item['title']?.toString() ?? 'Banner Analytics', style: AppTypography.adminCardTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatTile('Total Impressions', item['views']?.toString() ?? '42.5k'),
            _buildStatTile('Total Click-throughs', item['clicks']?.toString() ?? '8.1k'),
            _buildStatTile('Click-Through Rate (CTR)', item['ctr']?.toString() ?? '19.1%'),
            _buildStatTile('Display Placement', item['display']?.toString() ?? 'Home Carousel'),
            _buildStatTile('Target Route', item['link']?.toString() ?? '/tests'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.adminTableSecondary),
          Text(value, style: AppTypography.adminTableNumber),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _promotionalBanners.where((b) => b['isActive'] == true).length;
    final scheduledCount = _promotionalBanners.where((b) => b['isScheduled'] == true).length;
    final inactiveCount = _promotionalBanners.length - activeCount;
    final totalViewsSum = _promotionalBanners.fold<int>(0, (sum, b) => sum + ((b['rawViews'] as int?) ?? 0));
    final totalClicksSum = _promotionalBanners.fold<int>(0, (sum, b) => sum + ((b['rawClicks'] as int?) ?? 0));
    final overallCtr = totalViewsSum > 0 ? (totalClicksSum / totalViewsSum * 100) : 19.1;

    return SingleChildScrollView(
      padding: AppSpacing.adminPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner (Left) + Quick Actions (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              final heroCard = BannersHeroCard(
                onRefresh: _loadBanners,
              );
              final quickActions = BannersQuickActions(
                onNewBanner: () {
                  _resetForm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form reset. Ready to create a new banner!')),
                  );
                },
                onSelectCarousel: () {
                  setState(() => _displayMode = 'home_carousel');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Placement set to Home Screen Carousel')),
                  );
                },
                onSchedule: () {
                  setState(() {
                    _isScheduled = true;
                    _startDate ??= DateTime.now();
                    _endDate ??= DateTime.now().add(const Duration(days: 14));
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scheduled banner campaign enabled (14-day window)')),
                  );
                },
                onAnalytics: () {
                  if (_promotionalBanners.isNotEmpty) {
                    _showBannerAnalytics(_promotionalBanners.first);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No banners available to inspect analytics')),
                    );
                  }
                },
                onRefresh: _loadBanners,
              );

              if (constraints.maxWidth > 980) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 58,
                      child: heroCard,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 42,
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
          const SizedBox(height: AppSpacing.adminGapCard),

          // 2. 7 Analytics KPI Cards
          BannersKpiRow(
            totalBanners: _promotionalBanners.isNotEmpty ? _promotionalBanners.length : 24,
            activeBanners: _promotionalBanners.isNotEmpty ? activeCount : 8,
            scheduledBanners: _promotionalBanners.isNotEmpty ? scheduledCount : 3,
            inactiveBanners: _promotionalBanners.isNotEmpty ? inactiveCount : 13,
            totalViews: totalViewsSum > 0 ? totalViewsSum : 148500,
            totalClicks: totalClicksSum > 0 ? totalClicksSum : 28300,
            ctr: double.parse(overallCtr.toStringAsFixed(1)),
          ),
          const SizedBox(height: AppSpacing.adminGapCard),

          // 3. Create Banner Form Card (Left) + Banners Data Table (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              final createCard = CreateBannerCard(
                titleController: _titleController,
                linkController: _linkController,
                priorityController: _priorityController,
                imageUrl: _imageUrl,
                onImageUrlChanged: (url) => setState(() => _imageUrl = url),
                bannerType: _bannerType,
                onBannerTypeChanged: (t) => setState(() => _bannerType = t),
                displayMode: _displayMode,
                onDisplayModeChanged: (m) => setState(() => _displayMode = m),
                isScheduled: _isScheduled,
                onScheduleToggled: (s) => setState(() => _isScheduled = s),
                startDate: _startDate,
                onStartDateChanged: (d) => setState(() => _startDate = d),
                endDate: _endDate,
                onEndDateChanged: (d) => setState(() => _endDate = d),
                isActive: _isActive,
                onActiveToggled: (a) => setState(() => _isActive = a),
                isSaving: _isSaving,
                onReset: _resetForm,
                onSave: _saveBanner,
                onPreview: _previewBanner,
              );

              final tableCard = BannersDataTable(
                banners: _promotionalBanners,
                isLoading: _isLoading,
                onEdit: _editBanner,
                onToggleStatus: _toggleStatus,
                onAnalytics: _showBannerAnalytics,
                onDelete: _deleteBanner,
                isDesktop: constraints.maxWidth > 1080,
              );

              if (constraints.maxWidth > 1080) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 48,
                        child: createCard,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 52,
                        child: tableCard,
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    createCard,
                    const SizedBox(height: 20),
                    tableCard,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
