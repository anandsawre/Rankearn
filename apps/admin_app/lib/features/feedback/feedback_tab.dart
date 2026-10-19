import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class FeedbackTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialFeedbacks;
  const FeedbackTab({super.key, this.initialFeedbacks});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialFeedbacks != null) {
      _feedbacks = List.from(widget.initialFeedbacks!);
      _isLoading = false;
    } else {
      _fetchFeedbacks();
    }
  }

  Future<void> _fetchFeedbacks() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await client.from('feedbacks').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _feedbacks = (res as List).map((row) {
            final ratingVal = row['rating'];
            final int parsedRating = (ratingVal is num) ? ratingVal.toInt() : 5;

            return {
              'id': row['id']?.toString() ?? '',
              'name': row['user_name']?.toString() ?? 'Candidate',
              'email': row['user_email']?.toString() ?? 'user@rankearn.com',
              'rating': parsedRating,
              'date': row['created_at'] != null ? row['created_at'].toString().split('T').first : 'Recent',
              'comment': row['comment']?.toString() ?? '',
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      );
    }

    final totalCount = _feedbacks.length;
    final double avgRating = totalCount > 0
        ? _feedbacks.fold<int>(0, (sum, f) => sum + ((f['rating'] as int?) ?? 0)) / totalCount
        : 0.0;
    final fiveStarCount = _feedbacks.where((f) => (f['rating'] as int? ?? 0) >= 5).length;
    final fiveStarPct = totalCount > 0 ? (fiveStarCount / totalCount * 100).toStringAsFixed(1) : '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Three Top Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildFeedbackStatCard(
                  'AVG. RATING',
                  totalCount > 0 ? '${avgRating.toStringAsFixed(1)} / 5.0' : '0.0 / 5.0',
                  Icons.star,
                  const Color(0xFFF59E0B),
                  const Color(0xFFFFFBEB),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeedbackStatCard(
                  'TOTAL REVIEWS',
                  '$totalCount Feedback',
                  Icons.chat_bubble_outline,
                  const Color(0xFF059669),
                  const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeedbackStatCard(
                  'PERFECT 5-STARS',
                  '$fiveStarCount ($fiveStarPct%)',
                  Icons.trending_up,
                  const Color(0xFF2563EB),
                  const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Feedback List Container or Empty State
          if (_feedbacks.isEmpty)
            _buildEmptyState()
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.borderXl,
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Candidate Testimonials & App Reviews', style: AppTypography.titleLarge),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _feedbacks.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
                    itemBuilder: (context, idx) {
                      final fb = _feedbacks[idx];
                      final rating = (fb['rating'] as int?) ?? 5;
                      final name = fb['name']?.toString() ?? 'Candidate';

                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFECFDF5),
                              child: Text(
                                name.isNotEmpty ? name[0] : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandPrimary),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: AppTypography.titleMedium),
                                          Text(fb['email']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                        ],
                                      ),
                                      Text(fb['date']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: List.generate(5, (starIdx) {
                                      return Icon(
                                        starIdx < rating ? Icons.star : Icons.star_border,
                                        size: 16,
                                        color: const Color(0xFFF59E0B),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    fb['comment']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
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
              color: const Color(0xFFFFFBEB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_outline, color: Color(0xFFF59E0B), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No Candidate Reviews Yet', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Candidate ratings and feedback submitted from the mobile test conclusion screen will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackStatCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
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
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}
