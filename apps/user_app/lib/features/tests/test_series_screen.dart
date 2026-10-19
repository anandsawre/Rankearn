import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class TestSeriesScreen extends StatefulWidget {
  final int userCoins;
  final void Function(TestModel test) onStartTest;

  const TestSeriesScreen({
    super.key,
    required this.userCoins,
    required this.onStartTest,
  });

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;
  String _selectedMode = 'all';
  bool _onlyPurchased = false;

  final List<String> _categories = const [
    'All Categories',
    'BPSC',
    'SSC CGL',
    'Railway RRB',
    'UPSC CSE',
    'Banking',
    'Teaching',
    'Defence',
  ];

  final List<TestModel> _allTests = const [
    TestModel(
      id: 'test_bpsc_01',
      title: '70th BPSC Prelims Full Mock Test 1',
      categoryId: 'BPSC',
      testMode: 'mock',
      durationMinutes: 120,
      totalQuestions: 150,
      negativeMarking: 0.25,
      isPremium: false,
    ),
    TestModel(
      id: 'test_bpsc_02',
      title: '70th BPSC History of Bihar Special Test',
      categoryId: 'BPSC',
      testMode: 'sectional',
      durationMinutes: 45,
      totalQuestions: 50,
      negativeMarking: 0.25,
      isPremium: true,
      unlockPriceCoins: 50,
    ),
    TestModel(
      id: 'test_ssc_01',
      title: 'SSC CGL 2026 Tier 1 Full Practice Paper 3',
      categoryId: 'SSC CGL',
      testMode: 'mock',
      durationMinutes: 60,
      totalQuestions: 100,
      negativeMarking: 0.50,
      isPremium: false,
    ),
    TestModel(
      id: 'test_ssc_02',
      title: 'SSC CGL Quantitative Aptitude Speed Test',
      categoryId: 'SSC CGL',
      testMode: 'sectional',
      durationMinutes: 30,
      totalQuestions: 25,
      negativeMarking: 0.50,
      isPremium: true,
      unlockPriceCoins: 30,
    ),
    TestModel(
      id: 'test_rrb_01',
      title: 'RRB NTPC CBT 1 General Awareness 2026',
      categoryId: 'Railway RRB',
      testMode: 'mock',
      durationMinutes: 90,
      totalQuestions: 100,
      negativeMarking: 0.33,
      isPremium: false,
    ),
    TestModel(
      id: 'test_upsc_01',
      title: 'UPSC CSE Prelims GS Paper 1 All India Mock',
      categoryId: 'UPSC CSE',
      testMode: 'previous-year',
      durationMinutes: 120,
      totalQuestions: 100,
      negativeMarking: 0.66,
      isPremium: true,
      unlockPriceCoins: 100,
    ),
  ];

  List<TestModel> get _filteredTests {
    return _allTests.filter((test) {
      if (_searchQuery.isNotEmpty &&
          !test.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedCategoryIndex > 0) {
        final cat = _categories[_selectedCategoryIndex];
        if (test.categoryId != cat) return false;
      }
      if (_selectedMode != 'all' && test.testMode != _selectedMode) {
        return false;
      }
      if (_onlyPurchased && !test.isPremium) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showPurchaseDialog(TestModel test) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
        title: Row(
          children: [
            const Icon(Icons.lock_open, color: AppColors.coinGold),
            const SizedBox(width: 8),
            const Text('Unlock Test Series', style: AppTypography.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(test.title, style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.borderMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price to Unlock:'),
                  Text(
                    '${test.unlockPriceCoins} Coins',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.coinGold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your current balance: ${widget.userCoins} Coins',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Unlock & Start',
            size: AppButtonSize.small,
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onStartTest(test);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          AppTextField(
            hintText: 'Search test series, syllabus, or exam...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 16),

          // 2. Exam Category Selector
          SizedBox(
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
          ),
          const SizedBox(height: 12),

          // 3. Mode Filter Pills (Full Mock, Sectional, Previous Year)
          Row(
            children: [
              _buildModeChip('all', 'All Modes'),
              const SizedBox(width: 8),
              _buildModeChip('mock', 'Full Mocks'),
              const SizedBox(width: 8),
              _buildModeChip('sectional', 'Sectional'),
              const SizedBox(width: 8),
              _buildModeChip('previous-year', 'PYQ Papers'),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Test Catalog Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Tests (${_filteredTests.length})',
                style: AppTypography.titleLarge,
              ),
              InkWell(
                onTap: () => setState(() => _onlyPurchased = !_onlyPurchased),
                child: Row(
                  children: [
                    Icon(
                      _onlyPurchased ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 18,
                      color: AppColors.brandPrimary,
                    ),
                    const SizedBox(width: 4),
                    const Text('Premium Only', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 5. Test Cards List
          if (_filteredTests.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text('No test series matching your filter.', style: AppTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text('Try selecting "All Categories" or clear the search query.', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            )
          else
            for (final test in _filteredTests)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildTestCard(test),
              ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String mode, String label) {
    final isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      borderRadius: AppRadii.borderPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimaryLight : AppColors.surfaceSubtle,
          borderRadius: AppRadii.borderPill,
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? AppColors.brandPrimaryDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(TestModel test) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppStatusPill(
                    label: test.categoryId ?? 'General',
                    bg: AppColors.infoBlueLight,
                    fg: AppColors.infoBlue,
                  ),
                  const SizedBox(width: 6),
                  if (test.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.coinGoldLight,
                        borderRadius: AppRadii.borderPill,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 12, color: AppColors.coinGold),
                          const SizedBox(width: 2),
                          Text('${test.unlockPriceCoins} Coins', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.coinGold)),
                        ],
                      ),
                    )
                  else
                    const AppStatusPill(label: 'Free', bg: AppColors.brandPrimaryLight, fg: AppColors.brandPrimaryDark),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${test.durationMinutes} mins', style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(test.title, style: AppTypography.titleMedium),
          const SizedBox(height: 4),
          Text(
            '${test.totalQuestions} Questions • -${test.negativeMarking} Negative Marking • Mode: ${test.testMode.toUpperCase()}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                test.isPremium ? 'Unlock with ${test.unlockPriceCoins} Coins' : '100% Free Access',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: test.isPremium ? AppColors.coinGold : AppColors.brandPrimaryDark,
                ),
              ),
              AppButton(
                label: test.isPremium ? 'Unlock Test' : 'Start Test Now',
                size: AppButtonSize.small,
                onPressed: () {
                  if (test.isPremium) {
                    _showPurchaseDialog(test);
                  } else {
                    widget.onStartTest(test);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension _IterableExtension<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T) test) sync* {
    for (final element in this) {
      if (test(element)) yield element;
    }
  }
}
