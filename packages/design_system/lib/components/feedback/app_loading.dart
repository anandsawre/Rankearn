import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';

/// Rankearn Branded Loading Screen / Spinner
/// Pixel-accurate visual parity with React `AppLoadingState`.
class AppLogoLoader extends StatefulWidget {
  final bool fullScreen;
  final String message;

  const AppLogoLoader({
    super.key,
    this.fullScreen = false,
    this.message = 'Start Learning with Earning',
  });

  @override
  State<AppLogoLoader> createState() => _AppLogoLoaderState();
}

class _AppLogoLoaderState extends State<AppLogoLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brandPrimary.withAlpha(40),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3310B981),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'R',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Rankearn',
            style: AppTypography.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            widget.message.toUpperCase(),
            style: AppTypography.microTag.copyWith(
              letterSpacing: 2.0,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
            ),
          ),
        ],
      ),
    );

    if (widget.fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: content,
    );
  }
}
