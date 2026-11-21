import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Rankearn cross-platform applications.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_Z5m1DwNSIXO0CsIienzILWXJ7a8R718',
    appId: '1:884271494365:web:5312788910abcd21',
    messagingSenderId: '884271494365',
    projectId: 'rankearn',
    authDomain: 'rankearn.firebaseapp.com',
    storageBucket: 'rankearn.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_Z5m1DwNSIXO0CsIienzILWXJ7a8R718',
    appId: '1:884271494365:android:49bb93593e07314ba11734',
    messagingSenderId: '884271494365',
    projectId: 'rankearn',
    storageBucket: 'rankearn.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_Z5m1DwNSIXO0CsIienzILWXJ7a8R718',
    appId: '1:884271494365:ios:49bb93593e07314ba11734',
    messagingSenderId: '884271494365',
    projectId: 'rankearn',
    storageBucket: 'rankearn.firebasestorage.app',
    iosBundleId: 'com.rankearn.app',
  );
}
