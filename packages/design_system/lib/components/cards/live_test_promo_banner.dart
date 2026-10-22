import 'package:flutter/material.dart';
import 'app_promo_card.dart';

/// Reusable promotional banners matching Banner A & Banner B at the bottom of the Live Tests Tab.
/// Powered by the unified [AppPromoCard] engine.
class LiveTestPromoBanners extends StatelessWidget {
  final VoidCallback? onViewSeries;
  final VoidCallback? onCreateLiveTest;

  const LiveTestPromoBanners({
    super.key,
    this.onViewSeries,
    this.onCreateLiveTest,
  });

  @override
  Widget build(BuildContext context) {
    return AppPromoCard.responsivePair(
      first: AppPromoCard.liveTestSeries(onViewSeries: onViewSeries),
      second: AppPromoCard.createLiveTest(onCreateLiveTest: onCreateLiveTest),
    );
  }
}
