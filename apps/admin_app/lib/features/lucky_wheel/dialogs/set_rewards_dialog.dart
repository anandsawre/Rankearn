import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/lucky_wheel_item.dart';

class SetRewardsDialog extends StatefulWidget {
  final List<WheelRewardSegment>? initialSlices;
  final int initialDailyLimit;
  final void Function(List<WheelRewardSegment> slices, int dailyLimit)? onSave;

  const SetRewardsDialog({
    super.key,
    this.initialSlices,
    this.initialDailyLimit = 5,
    this.onSave,
  });

  @override
  State<SetRewardsDialog> createState() => _SetRewardsDialogState();
}

class _SetRewardsDialogState extends State<SetRewardsDialog> {
  late final TextEditingController _dailyLimitController;
  final List<Map<String, dynamic>> _slices = [
    {'label': '100 Coins', 'type': WheelRewardType.coins, 'value': 100, 'probability': 17, 'color': const Color(0xFFF59E0B), 'isActive': true},
    {'label': '50 Coins', 'type': WheelRewardType.coins, 'value': 50, 'probability': 25, 'color': const Color(0xFF10B981), 'isActive': true},
    {'label': 'Rank Booster', 'type': WheelRewardType.gift, 'value': 0, 'probability': 5, 'color': const Color(0xFFD97706), 'isActive': true},
    {'label': 'Surprise Gift', 'type': WheelRewardType.gift, 'value': 150, 'probability': 3, 'color': const Color(0xFFF43F5E), 'isActive': true},
    {'label': '10 Coins', 'type': WheelRewardType.coins, 'value': 10, 'probability': 30, 'color': const Color(0xFFF59E0B), 'isActive': true},
    {'label': '500 Coins (Jackpot)', 'type': WheelRewardType.coins, 'value': 500, 'probability': 2, 'color': const Color(0xFFEF4444), 'isActive': true},
    {'label': '200 Coins', 'type': WheelRewardType.coins, 'value': 200, 'probability': 10, 'color': const Color(0xFF8B5CF6), 'isActive': true},
    {'label': 'Extra Attempt', 'type': WheelRewardType.gift, 'value': 0, 'probability': 8, 'color': const Color(0xFF0284C7), 'isActive': true},
  ];

  @override
  void initState() {
    super.initState();
    _dailyLimitController = TextEditingController(
      text: widget.initialDailyLimit.toString(),
    );
    if (widget.initialSlices != null && widget.initialSlices!.isNotEmpty) {
      _slices.clear();
      for (final s in widget.initialSlices!) {
        _slices.add({
          'label': s.label,
          'type': s.rewardType,
          'value': s.rewardValue,
          'probability': s.probability,
          'color': s.color,
          'isActive': s.isActive,
        });
      }
    }
  }

  @override
  void dispose() {
    _dailyLimitController.dispose();
    super.dispose();
  }

  int get _totalProbability => _slices.fold(0, (sum, s) => sum + (s['probability'] as int));

  void _save() {
    if (_totalProbability != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total probability must equal 100% (currently $_totalProbability%)'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final segments = _slices.map((s) {
      return WheelRewardSegment(
        label: s['label'] as String,
        rewardType: s['type'] as WheelRewardType,
        rewardValue: s['value'] as int,
        probability: s['probability'] as int,
        color: s['color'] as Color,
        isActive: s['isActive'] as bool,
      );
    }).toList();

    final limit = int.tryParse(_dailyLimitController.text.trim()) ?? widget.initialDailyLimit;
    if (widget.onSave != null) widget.onSave!(segments, limit);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wheel rewards and Daily Spin limit saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _totalProbability == 100;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2587F8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF2587F8), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set Wheel Rewards & Probabilities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Configure 8 wheel slices. Total probability must sum to 100% (Current: $_totalProbability%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),

              // Daily Spin Limit Configuration Bar
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B96B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: Color(0xFF00B96B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Spin Limit (Per User)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            'Users will be able to spin exactly this many times per day',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _dailyLimitController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF00B96B)),
                        decoration: InputDecoration(
                          suffixText: 'Spins',
                          suffixStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content: Wheel Preview (Left) + Slices List (Right)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Wheel Graphic Preview
                    SizedBox(
                      width: 220,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(170, 170),
                                  painter: _WheelPreviewPainter(slices: _slices),
                                ),
                                // Center Gold Pin
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                                ),
                                // Pointer on top
                                Positioned(
                                  top: 0,
                                  child: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 32,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isValid ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isValid ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isValid ? Icons.check_circle_rounded : Icons.warning_rounded,
                                    size: 14,
                                    color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Total Probability: $_totalProbability%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isValid ? const Color(0xFF059669) : const Color(0xFFE11D48),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(width: 16),

                    // Right: Slices Configuration Table / List
                    Expanded(
                      child: ListView.separated(
                        itemCount: _slices.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final slice = _slices[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: slice['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: slice['label'] as String,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (v) => slice['label'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 56,
                                  child: TextFormField(
                                    initialValue: (slice['probability'] as int).toString(),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    decoration: const InputDecoration(
                                      suffixText: '%',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (v) {
                                      final val = int.tryParse(v) ?? 0;
                                      setState(() => slice['probability'] = val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Transform.scale(
                                  scale: 0.72,
                                  child: Switch(
                                    value: slice['isActive'] as bool,
                                    activeThumbColor: const Color(0xFF5636F5),
                                    onChanged: (val) => setState(() => slice['isActive'] = val),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: isValid ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Save Reward Slices'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPreviewPainter extends CustomPainter {
  final List<Map<String, dynamic>> slices;

  const _WheelPreviewPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final totalProb = slices.fold(0, (sum, s) => sum + (s['probability'] as int));
    if (totalProb == 0) return;

    double startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweepAngle = ((slice['probability'] as int) / totalProb) * 2 * math.pi;
      final paint = Paint()
        ..color = slice['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // Slice border line
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, startAngle, sweepAngle, true, linePaint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPreviewPainter oldDelegate) => true;
}
