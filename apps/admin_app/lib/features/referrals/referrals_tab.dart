import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class ReferralsTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialReferralLogs;
  const ReferralsTab({super.key, this.initialReferralLogs});

  @override
  State<ReferralsTab> createState() => _ReferralsTabState();
}

class _ReferralsTabState extends State<ReferralsTab> {
  String _activeSubTab = 'history'; // 'history' or 'settings'
  String _searchCode = '';
  List<Map<String, dynamic>> _referralLogs = [];
  bool _isLoading = true;

  // Settings controllers
  final _referrerBonusController = TextEditingController(text: '50');
  final _refereeBonusController = TextEditingController(text: '25');
  final _maxReferralsController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    if (widget.initialReferralLogs != null) {
      _referralLogs = List.from(widget.initialReferralLogs!);
      _isLoading = false;
    } else {
      _fetchReferrals();
    }
  }

  Future<void> _fetchReferrals() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await client
          .from('wallet_transactions')
          .select()
          .eq('category', 'referral')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _referralLogs = (res as List).map((tx) {
            final amount = (tx['amount'] is num) ? (tx['amount'] as num).toInt() : 50;
            return {
              'id': tx['id']?.toString() ?? '',
              'refereeName': tx['title']?.toString() ?? 'Referred Candidate',
              'refereeEmail': 'candidate@rankearn.com',
              'referrerName': 'Referrer User',
              'code': tx['reference_id']?.toString() ?? 'REF-EARN',
              'bonusCoins': amount,
              'date': tx['created_at'] != null ? tx['created_at'].toString().split('T').first : 'Recent',
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _referrerBonusController.dispose();
    _refereeBonusController.dispose();
    _maxReferralsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Header
          _buildMasterHeader(),
          const SizedBox(height: 20),

          if (_activeSubTab == 'history') ...[
            // Stats Overview Cards
            _buildStatsOverview(),
            const SizedBox(height: 20),

            // History Log Table or Empty State
            if (_referralLogs.isEmpty)
              _buildEmptyState()
            else
              _buildHistoryTable(),
          ] else ...[
            // Economics Settings
            _buildSettingsView(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard, color: AppColors.brandPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No Referral Conversions Yet', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'When candidates share invite codes and successfully onboard friends, their bonus distributions will track here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                child: const Icon(Icons.card_giftcard, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Referral Program & Growth', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Track viral loop acquisitions, referral codes, and bonus payouts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),

          // Sub-tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildSubTabButton('HISTORY', Icons.history, 'history'),
                _buildSubTabButton('SETTINGS', Icons.settings, 'settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(String label, IconData icon, String value) {
    final isSelected = _activeSubTab == value;
    return InkWell(
      onTap: () => setState(() => _activeSubTab = value),
      borderRadius: AppRadii.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: AppRadii.borderMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalCount = _referralLogs.length;
    final totalCoins = _referralLogs.fold<int>(0, (sum, r) => sum + ((r['bonusCoins'] as int?) ?? 0));

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL REFERRALS LOGGED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                    const SizedBox(height: 2),
                    Text('$totalCount Candidates', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: Color(0xFFFFFBEB), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.monetization_on_outlined, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BONUS DISTRIBUTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                    const SizedBox(height: 2),
                    Text('$totalCoins Coins', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTable() {
    final filtered = _referralLogs.where((r) {
      if (_searchCode.isEmpty) return true;
      return (r['code']?.toString() ?? '').toLowerCase().contains(_searchCode.toLowerCase());
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Referral Conversions', style: AppTypography.titleLarge),
                SizedBox(
                  width: 240,
                  child: AppTextField(
                    hintText: 'Filter by code...',
                    prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                    onChanged: (val) => setState(() => _searchCode = val),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
            itemBuilder: (context, idx) {
              final r = filtered[idx];
              final refereeName = r['refereeName']?.toString() ?? 'Candidate';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFECFDF5),
                  child: Text(refereeName.isNotEmpty ? refereeName[0] : 'U', style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                ),
                title: Text('$refereeName (${r['refereeEmail']})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Referred by ${r['referrerName']} using code: ${r['code']} • ${r['date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                trailing: Text('+${r['bonusCoins']} Coins', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Referral Economics Configuration', style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          const Text('Adjust bonus incentives awarded to referrers and newly joined candidates.', style: AppTypography.bodySmall),
          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 280,
                child: AppTextField(
                  controller: _referrerBonusController,
                  label: 'Referrer Bonus (Coins)',
                  hintText: '50',
                ),
              ),
              SizedBox(
                width: 280,
                child: AppTextField(
                  controller: _refereeBonusController,
                  label: 'Referee Welcome Bonus (Coins)',
                  hintText: '25',
                ),
              ),
              SizedBox(
                width: 280,
                child: AppTextField(
                  controller: _maxReferralsController,
                  label: 'Max Referrals Per User',
                  hintText: '100',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Save Referral Economics',
            onPressed: () async {
              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                try {
                  await client.from('app_configs').upsert({
                    'key': 'referral_settings',
                    'value': {
                      'referrer_bonus': int.tryParse(_referrerBonusController.text) ?? 50,
                      'referee_bonus': int.tryParse(_refereeBonusController.text) ?? 25,
                      'max_referrals': int.tryParse(_maxReferralsController.text) ?? 100,
                    },
                    'updated_at': DateTime.now().toIso8601String(),
                  });
                } catch (_) {}
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referral reward rules updated successfully.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
