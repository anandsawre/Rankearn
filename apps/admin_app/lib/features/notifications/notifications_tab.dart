import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  String _targetSegment = 'all'; // 'all', 'pro', 'free', 'specific'
  String _targetRoute = '/tests';
  String _notifType = 'contest'; // 'info', 'success', 'warning', 'transaction', 'contest'
  bool _showAsBanner = false;
  bool _isDispatching = false;

  final _titleController = TextEditingController(text: '70th BPSC Grand League Starts in 30 Mins! 🏆');
  final _bodyController = TextEditingController(text: 'Join the mock championship now to test your accuracy and compete for 15,000 Coins in prizes.');
  final _actionLabelController = TextEditingController(text: 'Join League');

  final List<Map<String, dynamic>> _history = [
    {
      'id': 'notif-1',
      'title': '70th BPSC Prelims Mock 1 Live Now',
      'body': 'Join candidates across Bihar in today\'s full mock test.',
      'segment': 'All Users',
      'type': 'contest',
      'date': 'Today, 09:00 AM',
    },
    {
      'id': 'notif-2',
      'title': 'Lucky Wheel Weekend Multiplier 🎡',
      'body': 'Spin today for 2x coin drops on all slices!',
      'segment': 'Free Users',
      'type': 'info',
      'date': 'Yesterday, 06:00 PM',
    },
    {
      'id': 'notif-3',
      'title': 'Payout Processed: ₹250 Credited',
      'body': 'Your coin redemption has been settled to your UPI VPA.',
      'segment': 'Specific User',
      'type': 'transaction',
      'date': 'Yesterday, 02:30 PM',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _actionLabelController.dispose();
    super.dispose();
  }

  void _dispatchNotification() async {
    setState(() => _isDispatching = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() {
      _isDispatching = false;
      _history.insert(0, {
        'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
        'title': _titleController.text,
        'body': _bodyController.text,
        'segment': _targetSegment.toUpperCase(),
        'type': _notifType,
        'date': 'Just Now',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚀 Notification broadcast dispatched via FCM!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layout: Form on Left, Phone Mockup Preview on Right
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 960;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildComposeForm()),
                    const SizedBox(width: 24),
                    SizedBox(width: 340, child: _buildPhoneMockupPreview()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildComposeForm(),
                  const SizedBox(height: 24),
                  _buildPhoneMockupPreview(),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Dispatch History Table
          _buildDispatchHistory(),
        ],
      ),
    );
  }

  Widget _buildComposeForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: AppRadii.borderLg,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.notifications_active_outlined, color: AppColors.brandPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Broadcast Push Notification', style: AppTypography.titleLarge),
                    Text('Dispatch high-priority alerts via Firebase Cloud Messaging', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Target Segment Selection
          const Text('AUDIENCE SEGMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSegmentPill('All Candidates', Icons.people_outline, 'all', AppColors.brandPrimary),
              const SizedBox(width: 10),
              _buildSegmentPill('Pro Pass Users', Icons.bolt, 'pro', const Color(0xFFD97706)),
              const SizedBox(width: 10),
              _buildSegmentPill('Free Tier Users', Icons.person_outline, 'free', const Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 20),

          // Title & Body
          AppTextField(
            controller: _titleController,
            label: 'Notification Title',
            hintText: 'e.g. 70th BPSC Grand League Starts in 30 Mins! 🏆',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _bodyController,
            label: 'Message Body',
            hintText: 'Write clear and compelling notification message...',
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Target Route & Action Label
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Redirect Target Route', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.borderMd,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _targetRoute,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: '/tests', child: Text('/tests (Test Series Catalog)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                            DropdownMenuItem(value: '/earn', child: Text('/earn (Live Contests Arena)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                            DropdownMenuItem(value: '/wheel', child: Text('/wheel (Lucky Spin Wheel)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                            DropdownMenuItem(value: '/battle', child: Text('/battle (1v1 Live Arena)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                          ],
                          onChanged: (val) => setState(() => _targetRoute = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _actionLabelController,
                  label: 'Action Button Text',
                  hintText: 'e.g. Join League',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Show as Banner Toggle
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: _showAsBanner,
              activeColor: AppColors.brandPrimary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Show as Full-Screen Modal Image Banner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              subtitle: const Text('Candidate will see an interactive modal pop-up instead of a simple tray notification.', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              onChanged: (val) => setState(() => _showAsBanner = val ?? false),
            ),
          ),
          const SizedBox(height: 14),

          // Theme Color Pills
          const Text('NOTIFICATION COLOR THEME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeThemePill('Contest', 'contest', const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _buildTypeThemePill('Success', 'success', const Color(0xFF059669)),
              const SizedBox(width: 8),
              _buildTypeThemePill('Info', 'info', const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              _buildTypeThemePill('Warning', 'warning', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 24),

          // Dispatch Action
          AppButton(
            label: _isDispatching ? 'Transmitting FCM Broadcast...' : '🚀 Dispatch FCM Push Notification',
            isLoading: _isDispatching,
            onPressed: _isDispatching ? null : _dispatchNotification,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentPill(String label, IconData icon, String value, Color color) {
    final isSelected = _targetSegment == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _targetSegment = value),
        borderRadius: AppRadii.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(20) : Colors.white,
            borderRadius: AppRadii.borderMd,
            border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1.0),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? color : const Color(0xFF64748B)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeThemePill(String label, String value, Color color) {
    final isSelected = _notifType == value;
    return InkWell(
      onTap: () => setState(() => _notifType = value),
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(25),
          borderRadius: AppRadii.borderSm,
          border: Border.all(color: color),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneMockupPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x20000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('11:42', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Row(
                children: const [
                  Icon(Icons.wifi, size: 14, color: Colors.white70),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full, size: 14, color: Colors.white70),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('LIVE PREVIEW', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 12),

          // Notification Banner Mockup
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: const Text('R', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Rankearn', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Text('now', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _titleController.text.isEmpty ? 'Notification Title' : _titleController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _bodyController.text.isEmpty ? 'Notification body text...' : _bodyController.text,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _actionLabelController.text.isEmpty ? 'Open' : _actionLabelController.text,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchHistory() {
    return Container(
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
            child: Text('Recent Notification Dispatch History', style: AppTypography.titleLarge),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ..._history.map((item) {
            return Material(
              color: Colors.transparent,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFECFDF5),
                  child: const Icon(Icons.send_outlined, size: 16, color: AppColors.brandPrimary),
                ),
                title: Text(item['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('${item['body']} • Target: ${item['segment']} • ${item['date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                  onPressed: () => setState(() => _history.remove(item)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
