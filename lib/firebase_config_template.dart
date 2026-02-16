// Firebase configuration template - DO NOT COMMIT ACTUAL KEYS
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Environment-based Firebase configuration
/// 
/// Set these environment variables in your development environment:
/// - FIREBASE_WEB_API_KEY
/// - FIREBASE_ANDROID_API_KEY  
/// - FIREBASE_IOS_API_KEY
/// - FIREBASE_PROJECT_ID
class FirebaseConfig {
  // Web configuration
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: const String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: const String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  // Android configuration
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: const String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: const String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  // iOS configuration
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
  );

  // Windows configuration
  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: const String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: const String.fromEnvironment('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );
}

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_config.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseConfig.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseConfig.android;
      case TargetPlatform.iOS:
        return FirebaseConfig.ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return FirebaseConfig.windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
