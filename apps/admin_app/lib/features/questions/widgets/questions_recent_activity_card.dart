import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class QuestionsRecentActivityCard extends StatelessWidget {
  final bool fillHeight;
  final VoidCallback? onViewAll;

  const QuestionsRecentActivityCard({
    super.key,
    this.fillHeight = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Recent Activity + View All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5636F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.history_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101A3A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5636F5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4 Activity Items
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ActivityRow(
                  icon: Icons.check_rounded,
                  iconBg: Color(0xFF10B981),
                  text: 'New question added: What is the SI unit of force?',
                  time: '5 minutes ago',
                ),
                _ActivityRow(
                  icon: Icons.edit_rounded,
                  iconBg: Color(0xFFF59E0B),
                  text: 'Question updated: Find the missing number?',
                  time: '18 minutes ago',
                ),
                _ActivityRow(
                  icon: Icons.file_upload_outlined,
                  iconBg: Color(0xFF0284C7),
                  text: '50 questions imported from CSV',
                  time: '1 hour ago',
                ),
                _ActivityRow(
                  icon: Icons.inventory_2_outlined,
                  iconBg: Color(0xFFF43F5E),
                  text: 'Question archived: Old current affairs set',
                  time: '2 hours ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (fillHeight) return content;
    return SizedBox(height: 140, child: content);
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String text;
  final String time;

  const _ActivityRow({
    required this.icon,
    required this.iconBg,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 11),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
