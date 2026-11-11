import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';

class AnalyticsTestSeriesDialog extends StatefulWidget {
  final TestSeriesItem item;

  const AnalyticsTestSeriesDialog({super.key, required this.item});

  @override
  State<AnalyticsTestSeriesDialog> createState() =>
      _AnalyticsTestSeriesDialogState();
}

class _AnalyticsTestSeriesDialogState extends State<AnalyticsTestSeriesDialog> {
  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  bool _isLoading = true;
  String? _errorMessage;

  int _totalAttempts = 0;
  double _completionRate = 0.0;
  double _avgScore = 0.0;
  double _avgAccuracy = 0.0;
  List<({String day, int count, double fraction})> _velocityBars = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Database connection is not initialized.';
        });
      }
      return;
    }

    try {
      final res = await client
          .from('attempts')
          .select('id, score, accuracy, status, created_at')
          .eq('test_id', widget.item.id)
          .order('created_at', ascending: false)
          .limit(2000);

      final rows = List<Map<String, dynamic>>.from(res as List);
      final total = rows.length;
      int completed = 0;
      double scoreSum = 0;
      double accuracySum = 0;

      final nowLocal = DateTime.now();
      final todayStart = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
      final dayCounts = List<int>.filled(7, 0);

      for (final r in rows) {
        final statusStr = (r['status'] ?? 'completed').toString().toLowerCase();
        if (statusStr == 'completed' || statusStr == 'submitted') {
          completed++;
        }
        scoreSum += (r['score'] as num?)?.toDouble() ?? 0.0;
        accuracySum += (r['accuracy'] as num?)?.toDouble() ?? 0.0;

        final createdAt =
            DateTime.tryParse(r['created_at']?.toString() ?? '')?.toLocal();
        if (createdAt != null) {
          final dayOnly =
              DateTime(createdAt.year, createdAt.month, createdAt.day);
          final diff = todayStart.difference(dayOnly).inDays;
          if (diff >= 0 && diff < 7) {
            dayCounts[6 - diff]++;
          }
        }
      }

      final maxDayCount = dayCounts.fold<int>(0, math.max);
      final bars = <({String day, int count, double fraction})>[];
      for (int i = 0; i < 7; i++) {
        final dayDate = todayStart.subtract(Duration(days: 6 - i));
        final dayLabel = _weekdayLabels[dayDate.weekday - 1];
        final cnt = dayCounts[i];
        final frac = maxDayCount > 0 ? (cnt / maxDayCount) : 0.0;
        bars.add((day: dayLabel, count: cnt, fraction: frac));
      }

      if (!mounted) return;
      setState(() {
        _totalAttempts = total;
        _completionRate = total > 0 ? (completed / total) * 100 : 0.0;
        _avgScore = total > 0 ? (scoreSum / total) : 0.0;
        _avgAccuracy = total > 0 ? (accuracySum / total) : 0.0;
        _velocityBars = bars;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load live analytics: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollments = math.max(widget.item.enrollments, _totalAttempts);
    final estimatedRevenue = enrollments * widget.item.priceInr;

    return AppModalDialog(
      title: '${widget.item.title} — Analytics',
      subtitle: 'Live student performance and attempt metrics from database',
      iconData: Icons.insights_rounded,
      gradientColors: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
      maxWidth: 560,
      actions: [
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _loadAnalytics,
          icon: const Icon(Icons.refresh_rounded, size: 15),
          label: const Text('Refresh',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1D4ED8),
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Done',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            )
          : _errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorRoseLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _buildMetricBlock(
                          'Total Enrollments',
                          _formatNumber(enrollments),
                          '$_totalAttempts recorded attempts',
                          const Color(0xFF10B981),
                        ),
                        _buildMetricBlock(
                          'Estimated Revenue',
                          '₹${_formatNumber(estimatedRevenue)}',
                          widget.item.priceInr > 0
                              ? 'At ₹${widget.item.priceInr} / unlock'
                              : 'Free Test Series',
                          const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildMetricBlock(
                          'Completion Rate',
                          _totalAttempts > 0
                              ? '${_completionRate.toStringAsFixed(1)}%'
                              : '0.0%',
                          _totalAttempts > 0
                              ? 'Based on $_totalAttempts attempts'
                              : 'No attempts submitted yet',
                          const Color(0xFF7C3AED),
                        ),
                        _buildMetricBlock(
                          'Avg. Score',
                          _totalAttempts > 0
                              ? _avgScore.toStringAsFixed(1)
                              : 'N/A',
                          _totalAttempts > 0
                              ? 'Avg accuracy: ${_avgAccuracy.toStringAsFixed(1)}%'
                              : 'Awaiting first attempt',
                          const Color(0xFFD97706),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Weekly Attempt Velocity (Last 7 Days)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 110,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: _velocityBars
                            .map(
                              (b) => Expanded(
                                child: _Bar(
                                  day: b.day,
                                  count: b.count,
                                  fraction: b.fraction,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMetricBlock(
      String label, String value, String sub, Color color) {
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
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF101A3A))),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(
                    fontSize: 9.5, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final int count;
  final double fraction;

  const _Bar({
    required this.day,
    required this.count,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$day: $count attempts',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: fraction <= 0
                  ? Container(
                      width: 16,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  : FractionallySizedBox(
                      heightFactor: fraction.clamp(0.08, 1.0),
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
      ),
    );
  }
}
