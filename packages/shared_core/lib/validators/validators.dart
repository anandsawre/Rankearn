/// Rankearn Input Form Validators
class AppValidators {
  AppValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateUtr(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UTR / Transaction ID is required';
    }
    final clean = value.trim();
    if (clean.length < 10 || clean.length > 20) {
      return 'UTR must be 10-20 alphanumeric characters';
    }
    return null;
  }

  static String? validateUpiId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID is required';
    }
    if (!value.contains('@') || value.trim().length < 5) {
      return 'Enter a valid UPI ID (e.g. user@okhdfcbank)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional in source
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? validateIfsc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$', caseSensitive: false);
    if (!ifscRegex.hasMatch(value.trim())) {
      return 'Enter a valid 11-character IFSC code';
    }
    return null;
  }
}
