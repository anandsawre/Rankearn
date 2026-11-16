import 'dart:async';
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

String _sanitizeUrl(String? input) {
  if (input == null) return '';
  var raw = input.trim();
  if (raw.isEmpty) return '';
  raw = raw.replaceAll('%22', '').replaceAll('&quot;', '');
  raw = raw.replaceAll(RegExp(r'''^["'`<(\s]+|["'`>)%\s]+$'''), '');
  if (raw.contains('"')) raw = raw.split('"').first;
  if (raw.contains("'")) raw = raw.split("'").first;
  raw = raw.trim();
  if (raw.isNotEmpty && !raw.startsWith('http://') && !raw.startsWith('https://')) {
    raw = 'https://$raw';
  }
  return raw;
}

class BannerItemData {
  final String id;
  final String imageUrl;
  final String title;
  final String link;
  final String type;
  final Map<String, dynamic>? spotlightData;

  const BannerItemData({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.link = '/tests',
    this.type = 'promotional',
    this.spotlightData,
  });
}

/// Dynamic, auto-sliding banner carousel component for promotional campaigns.
///
/// If [banners] is empty, displays the optional [fallbackWidget].
class BannerCarousel extends StatefulWidget {
  final List<BannerItemData> banners;
  final ValueChanged<BannerItemData>? onBannerTap;
  final Widget? fallbackWidget;
  /// Height of the banner carousel. If omitted, matches [TestsHeroBanner] / [AppHeroBanner]
  /// height (172px on compact mobile, 219px on tablet/desktop).
  final double? height;
  final BorderRadius? borderRadius;
  final Duration autoPlayInterval;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
    this.fallbackWidget,
    this.height,
    this.borderRadius,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.banners.length <= 1) return;

    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return widget.fallbackWidget ?? const SizedBox.shrink();
    }

    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final effectiveHeight = widget.height ?? (isCompact ? 172.0 : 219.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: effectiveHeight,
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.banners.length,
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                  },
                  itemBuilder: (context, index) {
                    final banner = widget.banners[index];
                    return _buildBannerSlide(banner);
                  },
                ),
              ),
            ),

            // Pagination Dots Indicator (outside banner, centered)
            if (widget.banners.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.banners.length, (i) {
                  final isSelected = i == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBannerSlide(BannerItemData banner) {
    final cleanUrl = _sanitizeUrl(banner.imageUrl);
    final hasImage = cleanUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onBannerTap?.call(banner),
        child: hasImage
            ? Image.network(
                cleanUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (ctx, err, stack) => _buildFallbackBanner(banner),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.adminPurpleLight,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.adminPurple),
                    ),
                  );
                },
              )
            : _buildFallbackBanner(banner),
      ),
    );
  }

  Widget _buildFallbackBanner(BannerItemData banner) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5636F5), Color(0xFF7628E8), Color(0xFF4C16A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    banner.type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  banner.title.isNotEmpty ? banner.title : 'Live Mock Test Extravaganza',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to explore: ${banner.link}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
