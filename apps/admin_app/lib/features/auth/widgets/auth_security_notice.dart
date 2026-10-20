import 'package:flutter/material.dart';

/// Soft lavender security notice at the bottom of the login card
class AuthSecurityNotice extends StatelessWidget {
  final double? verticalPadding;

  const AuthSecurityNotice({super.key, this.verticalPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding ?? 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Purple Shield Icon Container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF5636F5),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // Title & Description
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Authorized Access Only',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'This area is restricted to authorized administrators only. All activities are logged and monitored.',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
