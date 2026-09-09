// File: lib/firebase_options_example.dart
// -------------------------------------------------------------
// This is a template configuration file for FlutterFire.
// When connecting your own Firebase project:
// 1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
// 2. Run: flutterfire configure
// 3. This will generate a live `firebase_options.dart` file automatically!
// -------------------------------------------------------------

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyYourApiKeyHereForWeb1234567890',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'recipe-app-demo',
    authDomain: 'recipe-app-demo.firebaseapp.com',
    storageBucket: 'recipe-app-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyYourApiKeyHereForAndroid1234567',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'recipe-app-demo',
    storageBucket: 'recipe-app-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyYourApiKeyHereForIOS1234567890',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'recipe-app-demo',
    storageBucket: 'recipe-app-demo.appspot.com',
    iosBundleId: 'com.example.recipeApp',
  );
}
