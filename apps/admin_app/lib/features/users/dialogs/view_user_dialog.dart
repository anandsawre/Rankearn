import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

class ViewUserDialog extends StatelessWidget {
  final UserManagementItem user;
  final VoidCallback onEdit;
  final VoidCallback? onManageCoins;

  const ViewUserDialog({
    super.key,
    required this.user,
    required this.onEdit,
    this.onManageCoins,
  });

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: user.name,
      subtitle: '${user.email} • ID: ${user.id}',
      iconData: Icons.person_outline_rounded,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 520,
      scrollable: true,
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onEdit();
          },
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Key Badges Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.role.bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Role: ${user.role.label}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: user.role.color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.status.bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Status: ${user.status.label}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: user.status.color,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onManageCoins,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10194F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC928), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${user.coins} Coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00B96B),
                        ),
                        child: const Icon(Icons.add, size: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Enrollments', user.enrollmentsCount.toString(), Icons.school_rounded, const Color(0xFF0284C7)),
                Container(height: 36, width: 1, color: const Color(0xFFCBD5E1)),
                _buildStatItem('Tests Attempted', user.testsAttemptedCount.toString(), Icons.assignment_turned_in_rounded, const Color(0xFF10B981)),
                Container(height: 36, width: 1, color: const Color(0xFFCBD5E1)),
                _buildStatItem('Joined', user.joinedDateFormatted, Icons.calendar_today_rounded, const Color(0xFF6B4EFF)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Activity & Phone
          _buildInfoRow(Icons.phone_outlined, 'Phone', user.phone ?? 'Not provided'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time_rounded, 'Last Activity', user.lastActive),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.fingerprint_rounded, 'User ID', user.id),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF101A3A))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF101A3A)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
