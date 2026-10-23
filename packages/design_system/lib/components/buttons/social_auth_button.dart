import 'package:flutter/material.dart';
import '../display/google_logo.dart';

enum SocialAuthType { google, phone }

/// Rankearn Social Authentication Button (Google / Phone)
class SocialAuthButton extends StatelessWidget {
  final SocialAuthType type;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  factory SocialAuthButton.google({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialAuthButton(
      key: key,
      type: SocialAuthType.google,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  factory SocialAuthButton.phone({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialAuthButton(
      key: key,
      type: SocialAuthType.phone,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGoogle = type == SocialAuthType.google;
    final label = isGoogle ? 'Continue with Google' : 'Continue with Phone';

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2EBF8),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0610194F),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10194F)),
                    ),
                  )
                else if (isGoogle)
                  const GoogleLogo(size: 18)
                else
                  const Icon(
                    Icons.phone_rounded,
                    color: Color(0xFF1677FF),
                    size: 19,
                  ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10194F),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
