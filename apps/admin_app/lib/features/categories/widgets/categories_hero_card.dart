import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../categories_hero_data.dart';

class CategoriesHeroCard extends StatelessWidget {
  const CategoriesHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFE8EEFF),
            Color(0xFFE0E8FE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFE3EAF7), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x065636F5),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Builder(
          builder: (context) {
            final isNarrow = MediaQuery.sizeOf(context).width < 800;

            if (isNarrow) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextSection(),
                    const SizedBox(height: 12),
                    Center(
                      child: Image.memory(
                        kCategoriesHeroIllustrationBytes,
                        height: 85,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTextSection(),
                  ),
                  const SizedBox(width: 12),
                  Image.memory(
                    kCategoriesHeroIllustrationBytes,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Categories ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101A3A),
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5636F5),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Create, manage and organize categories for your platform.\nKeep your content well structured and easy to access.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
