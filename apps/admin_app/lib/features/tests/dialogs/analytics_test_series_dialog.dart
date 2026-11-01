import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';

class AnalyticsTestSeriesDialog extends StatelessWidget {
  final TestSeriesItem item;

  const AnalyticsTestSeriesDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final estimatedRevenue = item.enrollments * item.priceInr;

    return AppModalDialog(
      title: '${item.title} — Analytics',
      subtitle: 'Live student performance and enrollment metrics',
      iconData: Icons.insights_rounded,
      gradientColors: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
      maxWidth: 560,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildMetricBlock('Total Enrollments', '${item.enrollments}', '+18% vs last month', const Color(0xFF10B981)),
              _buildMetricBlock('Estimated Revenue', '₹${_formatNumber(estimatedRevenue)}', 'Platform GMV', const Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricBlock('Completion Rate', '78.4%', 'High student retention', const Color(0xFF7C3AED)),
              _buildMetricBlock('Avg. Score', '64.2 / 100', 'Standard benchmark', const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Weekly Attempt Velocity',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Expanded(child: _Bar(day: 'Mon', fraction: 0.45)),
                Expanded(child: _Bar(day: 'Tue', fraction: 0.60)),
                Expanded(child: _Bar(day: 'Wed', fraction: 0.72)),
                Expanded(child: _Bar(day: 'Thu', fraction: 0.55)),
                Expanded(child: _Bar(day: 'Fri', fraction: 0.82)),
                Expanded(child: _Bar(day: 'Sat', fraction: 0.95)),
                Expanded(child: _Bar(day: 'Sun', fraction: 0.75)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBlock(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF101A3A))),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      final part1 = s.substring(0, len - 3);
      final part2 = s.substring(len - 3);
      return '$part1,$part2';
    }
    return n.toString();
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final double fraction;

  const _Bar({required this.day, required this.fraction});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction.clamp(0.1, 1.0),
              child: Container(
                width: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
