import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  final List<Map<String, dynamic>> _feedbacks = const [
    {
      'id': 'fb-1',
      'name': 'Pooja Verma',
      'email': 'pooja.verma@gmail.com',
      'rating': 5,
      'date': '2 hours ago',
      'comment': 'The full 150-question BPSC simulated mocks with timer pressure helped me identify my weak spots in Medieval Bihar History. Great explanation notes!',
    },
    {
      'id': 'fb-2',
      'name': 'Aditya Sharma',
      'email': 'aditya.sharma@yahoo.com',
      'rating': 5,
      'date': 'Yesterday',
      'comment': '1v1 battle arena is an absolute game-changer. Speed calculations improved dramatically. Plus coin withdrawals are fast.',
    },
    {
      'id': 'fb-3',
      'name': 'Kavita Singh',
      'email': 'kavita.s@gmail.com',
      'rating': 4,
      'date': '2 days ago',
      'comment': 'Very helpful app for SSC CGL aspirants. Please add more sectional tests specifically for English comprehension idioms and phrases.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Three Top Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildFeedbackStatCard('AVG. RATING', '4.8 / 5.0', Icons.star, const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeedbackStatCard('TOTAL REVIEWS', '348 Feedback', Icons.chat_bubble_outline, const Color(0xFF059669), const Color(0xFFECFDF5)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeedbackStatCard('PERFECT 5-STARS', '294 (84.5%)', Icons.trending_up, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Feedback List Container
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
                    final rating = fb['rating'] as int;

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFECFDF5),
                            child: Text(
                              fb['name'][0],
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
                                        Text(fb['name'], style: AppTypography.titleMedium),
                                        Text(fb['email'], style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                    Text(fb['date'], style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
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
                                  fb['comment'],
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
