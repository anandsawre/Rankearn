/// Conditional barrel export for Rankearn Withdrawal Feature.
///
/// On Web targets (`dart.library.js_interop`), exports full UPI payout module.
/// On Native targets (Android APK/AAB for Google Play Store), exports zero-footprint
/// stub ensuring no real-money or banking code is compiled into the binary.
library;

export 'withdrawal_feature_stub.dart'
    if (dart.library.js_interop) 'withdrawal_feature_web.dart';

