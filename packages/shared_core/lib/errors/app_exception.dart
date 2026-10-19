/// Rankearn Domain & Application Exceptions
sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message ${code != null ? '($code)' : ''}';
}

class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

class InsufficientCoinsException extends AppException {
  final int requiredCoins;
  final int availableCoins;

  const InsufficientCoinsException(this.requiredCoins, this.availableCoins)
      : super('Insufficient coins. Required: $requiredCoins, Available: $availableCoins', 'INSUFFICIENT_COINS');
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network connection lost. Please check your internet.'])
      : super(message, 'NETWORK_ERROR');
}

class UnauthorizedAdminException extends AppException {
  const UnauthorizedAdminException([String message = 'Access denied: Admin authorization required.'])
      : super(message, 'UNAUTHORIZED_ADMIN');
}

class AccountSuspendedException extends AppException {
  final String? reason;
  final DateTime? banUntil;

  const AccountSuspendedException([this.reason, this.banUntil])
      : super(reason ?? 'Your account has been suspended by administration.', 'ACCOUNT_SUSPENDED');
}
