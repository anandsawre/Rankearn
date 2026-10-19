import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ReferralsTab extends StatefulWidget {
  const ReferralsTab({super.key});

  @override
  State<ReferralsTab> createState() => _ReferralsTabState();
}

class _ReferralsTabState extends State<ReferralsTab> {
  String _activeSubTab = 'history'; // 'history' or 'settings'
  String _searchCode = '';

  final List<Map<String, dynamic>> _referralLogs = [
    {
      'id': 'ref-1',
      'refereeName': 'Aakash Verma',
      'refereeEmail': 'aakash.v@gmail.com',
      'referrerName': 'Vikram Singh',
      'code': 'VIKRAM70',
      'bonusCoins': 50,
      'date': 'Today, 10:14 AM',
    },
    {
      'id': 'ref-2',
      'refereeName': 'Divya Soni',
      'refereeEmail': 'divya.soni@yahoo.com',
      'referrerName': 'Pooja Verma',
      'code': 'POOJA99',
      'bonusCoins': 50,
      'date': 'Yesterday, 04:30 PM',
    },
    {
      'id': 'ref-3',
      'refereeName': 'Kunal Kishore',
      'refereeEmail': 'kunal.k@outlook.com',
      'referrerName': 'Manish Kumar',
      'code': 'MANISH20',
      'bonusCoins': 50,
      'date': 'Yesterday, 11:20 AM',
    },
  ];

  // Settings controllers
  final _referrerBonusController = TextEditingController(text: '50');
  final _refereeBonusController = TextEditingController(text: '25');
  final _maxReferralsController = TextEditingController(text: '100');

  @override
  void dispose() {
    _referrerBonusController.dispose();
    _refereeBonusController.dispose();
    _maxReferralsController.dispose();
    super.dispose();
  }

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

          if (_activeSubTab == 'history') ...[
            // Stats Overview Cards
            _buildStatsOverview(),
            const SizedBox(height: 20),

            // History Log Table
            _buildHistoryTable(),
          ] else ...[
            // Economics Settings
            _buildSettingsView(),
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
                  children: const [
                    Text('TOTAL REFERRALS LOGGED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                    SizedBox(height: 2),
                    Text('1,480 Candidates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
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
                  children: const [
                    Text('BONUS DISTRIBUTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                    SizedBox(height: 2),
                    Text('74,000 Coins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
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
      return (r['code'] as String).toLowerCase().contains(_searchCode.toLowerCase());
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFECFDF5),
                  child: Text(r['refereeName'][0], style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                ),
                title: Text('${r['refereeName']} (${r['refereeEmail']})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral reward rules updated successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
