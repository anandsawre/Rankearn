import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ReferralAnalyticsCard extends StatefulWidget {
  const ReferralAnalyticsCard({super.key});

  @override
  State<ReferralAnalyticsCard> createState() => _ReferralAnalyticsCardState();
}

class _ReferralAnalyticsCardState extends State<ReferralAnalyticsCard> {
  String _selectedRange = '30D'; // '7D', '30D', '90D'

  List<String> get _dates {
    if (_selectedRange == '7D') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
    if (_selectedRange == '90D') {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    }
    return ['Day 1', 'Day 5', 'Day 10', 'Day 15', 'Day 20', 'Day 25', 'Day 30'];
  }

  List<double> get _values {
    if (_selectedRange == '7D') {
      return [45, 62, 58, 85, 92, 120, 140];
    }
    if (_selectedRange == '90D') {
      return [420, 580, 720, 890, 1150, 1420];
    }
    return [35, 48, 65, 82, 110, 135, 175];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0810143A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Range Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, size: 20, color: AppColors.adminPurple),
                  SizedBox(width: 8),
                  Text(
                    'Referral Performance & Trends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.adminPrimaryText,
                    ),
                  ),
                ],
              ),
              _buildRangePills(),
            ],
          ),
          const SizedBox(height: 18),

          // Line Chart
          SizedBox(
            height: 180,
            child: AppLineChart(
              dates: _dates,
              values: _values,
              lineColor: AppColors.adminPurple,
              fillColor: AppColors.adminPurpleLight.withAlpha(90),
              tooltipValue: '175 Signups',
              tooltipDate: 'Latest Period',
            ),
          ),
          const SizedBox(height: 14),

          // Key Highlights Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.adminBackground,
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryStat(label: 'Avg Daily Invites', value: '114'),
                _SummaryStat(label: 'Activation Rate', value: '83.2%'),
                _SummaryStat(label: 'Top Referrer', value: '428 users'),
                _SummaryStat(label: 'Viral Coefficient', value: '1.42x'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangePills() {
    final ranges = ['7D', '30D', '90D'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ranges.map((r) {
          final isSel = _selectedRange == r;
          return InkWell(
            onTap: () => setState(() => _selectedRange = r),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSel ? AppColors.adminPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                r,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  color: isSel ? Colors.white : AppColors.adminSecondaryText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.adminPrimaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.adminSecondaryText,
          ),
        ),
      ],
    );
  }
}
