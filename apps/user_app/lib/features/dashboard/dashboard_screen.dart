import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onStartTest;
  final VoidCallback onExploreTests;
  final VoidCallback onJoinContest;
  final VoidCallback onSpinWheel;
  final VoidCallback onOpenWallet;

  const DashboardScreen({
    super.key,
    required this.profile,
    required this.onStartTest,
    required this.onExploreTests,
    required this.onJoinContest,
    required this.onSpinWheel,
    required this.onOpenWallet,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _countdownTimer;
  int _contestSecondsRemaining = 3 * 3600 + 42 * 60 + 15; // 03:42:15
  int _selectedCategoryIndex = 0;
  int? _selectedPollOption;
  bool _hasVotedPoll = false;

  final List<String> _categories = const [
    'All Exams',
    'BPSC',
    'SSC CGL',
    'Railway RRB',
    'UPSC CSE',
    'Teaching (CTET)',
    'Defence (NDA)',
  ];

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_contestSecondsRemaining > 0) {
        setState(() => _contestSecondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final h = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingMobile,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Tournament Master Spotlight Banner (Matching React ContestBannerSlide)
          _buildSpotlightBanner(),
          const SizedBox(height: 20),

          // 2. Performance KPI Quick Stats (2x2 Grid matching React Dashboard stats)
          _buildPerformanceStatsGrid(),
          const SizedBox(height: 24),

          // 3. Exam Category Horizontal Selector Chips
          _buildExamCategoryChips(),
          const SizedBox(height: 20),

          // 4. Recommended & Popular Tests Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Popular Mock Tests', style: AppTypography.titleLarge),
              TextButton(
                onPressed: widget.onExploreTests,
                child: const Text('View All →', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _buildTestCard(
            title: '70th BPSC Prelims Full Mock Test 1',
            examName: 'BPSC',
            questions: 150,
            durationMins: 120,
            negativeMark: '0.25',
            isPro: false,
          ),
          const SizedBox(height: 12),

          _buildTestCard(
            title: 'SSC CGL Tier 1 Quantitative Practice',
            examName: 'SSC CGL',
            questions: 25,
            durationMins: 30,
            negativeMark: '0.50',
            isPro: true,
          ),
          const SizedBox(height: 12),

          _buildTestCard(
            title: 'Railway RRB NTPC General Awareness',
            examName: 'RRB',
            questions: 40,
            durationMins: 45,
            negativeMark: '0.33',
            isPro: false,
          ),
          const SizedBox(height: 24),

          // 5. Daily Community Poll Widget (Matching React PollWidget.tsx)
          _buildCommunityPollCard(),
          const SizedBox(height: 24),

          // 6. Current Affairs & Updates Preview (Matching React Updates.tsx)
          _buildCurrentAffairsCard(),
        ],
      ),
    );
  }

  // --- 1. Spotlight Banner ---
  Widget _buildSpotlightBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Corner Decorative Angles
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(64, 64),
              painter: _CornerDecoPainter(color: AppColors.errorRose),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Status & Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRose,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE CONTEST',
                          style: TextStyle(
                            color: AppColors.errorRose,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.errorRoseLight,
                        borderRadius: AppRadii.borderPill,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.errorRose),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimer(_contestSecondsRemaining),
                            style: const TextStyle(
                              color: AppColors.errorRose,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Contest Title
                const Text(
                  '70th BPSC Grand Mock League 🏆',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Win up to 5,000 Coins in the live timed competitive league.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),

                // Prize Pool & Join CTA
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prize Pool', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        const Row(
                          children: [
                            Icon(Icons.monetization_on, color: AppColors.coinGold, size: 18),
                            SizedBox(width: 4),
                            Text('5,000 Coins', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Entry Fee', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text('20 Coins', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.brandPrimaryDark)),
                      ],
                    ),
                    const Spacer(),
                    AppButton(
                      label: 'Join Now →',
                      size: AppButtonSize.small,
                      onPressed: widget.onJoinContest,
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

  // --- 2. Performance Stats Grid (4 Cards matching React) ---
  Widget _buildPerformanceStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                label: 'Avg Score',
                value: '78%',
                icon: Icons.track_changes,
                iconColor: const Color(0xFF6366F1),
                iconBgColor: const Color(0xFFEEF2FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppStatCard(
                label: 'Accuracy',
                value: '84%',
                icon: Icons.bolt,
                iconColor: AppColors.brandPrimary,
                iconBgColor: AppColors.brandPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                label: 'Global Rank',
                value: '#14',
                icon: Icons.emoji_events_outlined,
                iconColor: AppColors.coinGold,
                iconBgColor: AppColors.coinGoldLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppStatCard(
                label: 'Tests Done',
                value: '18 Attempts',
                icon: Icons.check_circle_outline,
                iconColor: AppColors.errorRose,
                iconBgColor: AppColors.errorRoseLight,
                onTap: widget.onExploreTests,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 3. Exam Category Chips ---
  Widget _buildExamCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              borderRadius: AppRadii.borderPill,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandPrimary : Colors.white,
                  borderRadius: AppRadii.borderPill,
                  border: Border.all(
                    color: isSelected ? AppColors.brandPrimary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 4. Test Card Item ---
  Widget _buildTestCard({
    required String title,
    required String examName,
    required int questions,
    required int durationMins,
    required String negativeMark,
    required bool isPro,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppStatusPill(label: examName, bg: AppColors.infoBlueLight, fg: AppColors.infoBlue),
                  if (isPro) ...[
                    const SizedBox(width: 6),
                    const AppProBadge(scale: 0.8),
                  ],
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('$durationMins mins', style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: 4),
          Text(
            '$questions Questions • -$negativeMark Negative Marking',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPro ? 'Included in Pro' : 'Free Practice Test',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPro ? AppColors.coinGold : AppColors.brandPrimaryDark,
                ),
              ),
              AppButton(
                label: 'Start Test Now',
                size: AppButtonSize.small,
                onPressed: widget.onStartTest,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 5. Community Poll Card ---
  Widget _buildCommunityPollCard() {
    final pollOptions = [
      ('Ashoka the Great', '64%'),
      ('Chandragupta Maurya', '21%'),
      ('Bindusara', '10%'),
      ('Brihadratha', '5%'),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.poll_outlined, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              const Text('Daily Exam Poll 🗳️', style: AppTypography.titleMedium),
              const Spacer(),
              const Text('1,240 votes', style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Q: Which Mauryan ruler embraced Buddhism after the Kalinga War in 261 BCE?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),

          for (int i = 0; i < pollOptions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () => setState(() {
                  _selectedPollOption = i;
                  _hasVotedPoll = true;
                }),
                borderRadius: AppRadii.borderMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedPollOption == i ? AppColors.brandPrimaryLight : AppColors.surfaceSubtle,
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(
                      color: _selectedPollOption == i ? AppColors.brandPrimary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(pollOptions[i].$1, style: AppTypography.bodyMedium),
                      if (_hasVotedPoll)
                        Text(pollOptions[i].$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.brandPrimaryDark)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- 6. Current Affairs News Brief ---
  Widget _buildCurrentAffairsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, color: AppColors.infoBlue, size: 20),
              const SizedBox(width: 8),
              const Text('Daily Current Affairs 📰', style: AppTypography.titleMedium),
              const Spacer(),
              const Text('Updated Today', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Important National & Bihar State Appointments (October 2026)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Key highlights for upcoming 70th BPSC Prelims, SSC CGL and state civil exams. Read the 5-point summary.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening daily current affairs brief...')),
              );
            },
            child: const Text('Read Full Brief →', style: TextStyle(color: AppColors.infoBlue, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _CornerDecoPainter extends CustomPainter {
  final Color color;

  _CornerDecoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
