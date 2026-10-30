import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';

/// Pure Vector CustomPainter for Contest Entry Dialog background decoration
/// (Ambient watermark rings on top-left + flowing waves on top-right + floating particle accents)
class _DialogBackgroundPainter extends CustomPainter {
  final Color themeColor;

  const _DialogBackgroundPainter({required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top-Left Concentric Watermark Rings
    final ringPaint1 = Paint()
      ..color = themeColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, 0), 80, ringPaint1);

    final ringStrokePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(const Offset(0, 0), 105, ringStrokePaint);

    // 2. Top-Right Ambient Flowing Waves
    final wavePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(size.width * 0.42, 0)
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.12,
        size.width * 0.78,
        size.height * 0.22,
        size.width,
        size.height * 0.14,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(wavePath, wavePaint);

    final waveInnerPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final waveInnerPath = Path()
      ..moveTo(size.width * 0.62, 0)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.16,
        size.width * 0.88,
        size.height * 0.26,
        size.width,
        size.height * 0.22,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(waveInnerPath, waveInnerPaint);

    // 3. Subtle floating particles
    final dotPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.90, 42), 3.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.22, 54), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.12, 120), 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DialogBackgroundPainter oldDelegate) =>
      oldDelegate.themeColor != themeColor;
}

/// Professional, centralized Contest Entry Confirmation Dialog
/// matching the Rankearn high-end design system tokens & dialog standards.
Future<bool?> showContestEntryDialog({
  required BuildContext context,
  required TestModel test,
  required int userCoins,
  bool isPreRegister = false,
  VoidCallback? onOpenWallet,
}) {
  final entryFee = test.entryFeeCoins;
  final primaryColor = isPreRegister
      ? const Color(0xFFEA580C) // Vibrant Orange
      : const Color(0xFF4F46E5); // Rich Indigo/Purple

  String formatShortDate(DateTime? dt) {
    if (dt == null) return 'Live Now';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'pm' : 'am';
    return '${dt.day} $m, ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      final isInsufficient = userCoins < entryFee;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 14,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
            children: [
              // Background Vector Decoration (Waves + Concentric Rings)
              Positioned.fill(
                child: CustomPaint(
                  painter: _DialogBackgroundPainter(themeColor: primaryColor),
                ),
              ),

              // Main Dialog Content
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Solid distinct circular badge with WHITE icon
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.12),
                      ),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isPreRegister
                                ? const [Color(0xFFEA580C), Color(0xFFF97316)]
                                : const [Color(0xFF4F46E5), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.38),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isPreRegister
                                ? Icons.how_to_reg_rounded
                                : (test.isTournament ? Icons.emoji_events_rounded : Icons.podcasts_rounded),
                            color: Colors.white, // CRISP WHITE ICON
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Title & Status Badge
                    Text(
                      isPreRegister
                          ? (test.isTournament ? 'Pre-Register Tournament' : 'Pre-Register Live Quiz')
                          : (test.isTournament ? 'Confirm Tournament Entry' : 'Confirm Live Quiz Entry'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPreRegister
                            ? const Color(0xFFFFF7ED)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPreRegister
                              ? const Color(0xFFFFEDD5)
                              : const Color(0xFFDBEAFE),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPreRegister
                                ? Icons.calendar_today_rounded
                                : (test.isTournament ? Icons.emoji_events_outlined : Icons.sensors_rounded),
                            size: 11,
                            color: isPreRegister
                                ? const Color(0xFFEA580C)
                                : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPreRegister
                                ? (test.isTournament ? 'UPCOMING TOURNAMENT' : 'UPCOMING LIVE QUIZ')
                                : (test.isTournament ? 'LIVE TOURNAMENT' : 'LIVE QUIZ NOW'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: isPreRegister
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Test Title Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.school_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              test.title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black, // Solid Black!
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. Financial Breakdown Table
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Row 1: Entry Fee
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFF59E0B), // Solid Amber/Orange circle
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.confirmation_number_rounded,
                                        size: 13,
                                        color: Colors.white, // Crisp White Icon!
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Entry Fee',
                                    style: TextStyle(
                                      color: Colors.black, // Solid Black!
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFEF3C7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Color(0xFFD97706),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$entryFee Coins',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),

                          if (isPreRegister &&
                              test.scheduledStartTime != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2563EB), // Solid Blue circle
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.access_time_filled_rounded,
                                          size: 13,
                                          color: Colors.white, // Crisp White Icon!
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Starts At',
                                      style: TextStyle(
                                        color: Colors.black, // Solid Black!
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  formatShortDate(test.scheduledStartTime),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child:
                                  Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),
                          ],

                          // Row 2: Your Wallet Balance
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF10B981), // Solid Emerald Green circle
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 13,
                                        color: Colors.white, // Crisp White Icon!
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Your Wallet',
                                    style: TextStyle(
                                      color: Colors.black, // Solid Black!
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$userCoins Coins',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: isInsufficient
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),

                          if (!isInsufficient && entryFee > 0) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child:
                                  Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),
                            // Row 3: Remaining Balance After Joining
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF64748B), // Solid Slate circle
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.receipt_long_rounded,
                                          size: 13,
                                          color: Colors.white, // Crisp White Icon!
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Balance After',
                                      style: TextStyle(
                                        color: Colors.black, // Solid Black!
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${userCoins - entryFee} Coins',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: Colors.black, // Solid Black!
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 5. Warning banner if insufficient coins
                    if (isInsufficient) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Insufficient coins in wallet to enter this contest.',
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // 6. Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          flex: 4,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Confirm / Top-up Button
                        Expanded(
                          flex: 6,
                          child: isInsufficient
                              ? ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B96B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                    onOpenWallet?.call();
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 17,
                                  ),
                                  label: const Text(
                                    'Top-up Coins',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPreRegister
                                        ? const Color(0xFFEA580C)
                                        : const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    elevation: 1,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  icon: Icon(
                                    isPreRegister
                                        ? Icons.how_to_reg_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    isPreRegister
                                        ? (entryFee > 0
                                            ? 'Pay & Register'
                                            : 'Register Free')
                                        : (entryFee > 0
                                            ? 'Pay & Join Test'
                                            : 'Join Test'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
