import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured');
      default:
        throw UnsupportedError('Platform not configured');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhEE1JVFmRRFHRqILNoV1tLy5L2ralNIc',
    appId: '1:618826760391:android:bf3bcd70fb9d69f9ca3ee2',
    messagingSenderId: '618826760391',
    projectId: 'lexi-33b14',
    storageBucket: 'lexi-33b14.firebasestorage.app',
  );
}
