import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class WheelTab extends StatefulWidget {
  const WheelTab({super.key});

  @override
  State<WheelTab> createState() => _WheelTabState();
}

class _WheelTabState extends State<WheelTab> {
  bool _isWheelActive = true;
  int _spinCost = 10;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _slices = [
    {'label': '50 Coins', 'coins': 50, 'probability': 25, 'color': const Color(0xFF10B981), 'isActive': true},
    {'label': 'Better Luck Next Time', 'coins': 0, 'probability': 30, 'color': const Color(0xFF64748B), 'isActive': true},
    {'label': '100 Coins', 'coins': 100, 'probability': 15, 'color': const Color(0xFF3B82F6), 'isActive': true},
    {'label': '20 Coins', 'coins': 20, 'probability': 15, 'color': const Color(0xFFF59E0B), 'isActive': true},
    {'label': '250 Coins (Jackpot)', 'coins': 250, 'probability': 5, 'color': const Color(0xFF8B5CF6), 'isActive': true},
    {'label': 'Try Again', 'coins': 0, 'probability': 5, 'color': const Color(0xFF94A3B8), 'isActive': true},
    {'label': '500 Coins (Super Mega)', 'coins': 500, 'probability': 2, 'color': const Color(0xFFEC4899), 'isActive': true},
    {'label': 'Free Re-Spin', 'coins': 10, 'probability': 3, 'color': const Color(0xFF06B6D4), 'isActive': true},
  ];

  int get _totalProbability => _slices.fold(0, (sum, s) => sum + (s['probability'] as int));

  void _saveConfig() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎡 Lucky Wheel reward slices and probabilities saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final is100 = _totalProbability == 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Header
          _buildMasterHeader(),
          const SizedBox(height: 20),

          // Two-column Layout: Config on Left, 8 Slices on Right
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: _buildSettingsSidebar(is100)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSlicesGrid()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildSettingsSidebar(is100),
                  const SizedBox(height: 24),
                  _buildSlicesGrid(),
                ],
              );
            },
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: AppRadii.borderLg,
                  boxShadow: const [
                    BoxShadow(color: Color(0x30F59E0B), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.rotate_right, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lucky Wheel Reward Engine', style: AppTypography.displayMedium),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text('Configure Coin Drops, Drop Probability Weights & Multipliers', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                      const SizedBox(width: 8),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('${_slices.length} Active Slices', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                    ],
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      _isWheelActive ? 'WHEEL ONLINE' : 'WHEEL OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _isWheelActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isWheelActive,
                      activeTrackColor: AppColors.brandPrimary,
                      onChanged: (val) => setState(() => _isWheelActive = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: _isSaving ? 'Saving...' : 'Save Configuration',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveConfig,
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildSettingsSidebar(bool is100) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SPIN ECONOMICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
          const SizedBox(height: 14),

          // Spin Cost input
          AppTextField(
            label: 'Spin Cost (Coins)',
            hintText: '10',
            controller: TextEditingController(text: '$_spinCost'),
            prefixIcon: const Icon(Icons.monetization_on_outlined, color: Color(0xFFF59E0B)),
            onChanged: (val) => _spinCost = int.tryParse(val) ?? 10,
          ),
          const SizedBox(height: 24),

          // Live Probability Tracker
          const Text('PROBABILITY AUDIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: is100 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: is100 ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text('Total Probability:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: is100 ? const Color(0xFF065F46) : const Color(0xFF991B1B))),
                    ),
                    Text('$_totalProbability%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: is100 ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_totalProbability / 100).clamp(0.0, 1.0),
                  backgroundColor: is100 ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                  valueColor: AlwaysStoppedAnimation<Color>(is100 ? AppColors.brandPrimary : const Color(0xFFDC2626)),
                ),
                const SizedBox(height: 8),
                Text(
                  is100
                      ? '✓ Probabilities sum perfectly to 100%.'
                      : '⚠ Slices must sum exactly to 100% to ensure fair RNG drops.',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: is100 ? const Color(0xFF047857) : const Color(0xFFB91C1C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlicesGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WHEEL SECTORS (8 REWARD SLICES)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
          const SizedBox(height: 14),

          ..._slices.asMap().entries.map((entry) {
            final idx = entry.key;
            final slice = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: slice['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slice['label'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                        Text('${slice['coins']} Coins Reward', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.borderSm,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      '${slice['probability']}% Weight',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
