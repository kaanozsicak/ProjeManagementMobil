// Firebase configuration placeholder
// Run: flutterfire configure to generate this file
// Or manually create with your Firebase project settings

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  // TODO: Replace with your Firebase project configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHmtPrEAt8sEeTdIQ5jc7HgBnZgsDFFSM',
    appId: '1:748755390668:android:e6fad6aa1133410a7bb269',
    messagingSenderId: '748755390668',
    projectId: 'kimneyapti-5eb34',
    storageBucket: 'kimneyapti-5eb34.firebasestorage.app',
  );

  // Run: flutterfire configure

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1j1IoLo8A-rnPyvvAinoWcEbYF6XMKsE',
    appId: '1:748755390668:ios:5d302e855ce17b267bb269',
    messagingSenderId: '748755390668',
    projectId: 'kimneyapti-5eb34',
    storageBucket: 'kimneyapti-5eb34.firebasestorage.app',
    iosBundleId: 'com.example.kimNeYapti',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDehXImNu-qRcKAiOSDQn6-8PZqZxIdPR0',
    appId: '1:748755390668:web:16abc8e763973bf57bb269',
    messagingSenderId: '748755390668',
    projectId: 'kimneyapti-5eb34',
    authDomain: 'kimneyapti-5eb34.firebaseapp.com',
    storageBucket: 'kimneyapti-5eb34.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1j1IoLo8A-rnPyvvAinoWcEbYF6XMKsE',
    appId: '1:748755390668:ios:5d302e855ce17b267bb269',
    messagingSenderId: '748755390668',
    projectId: 'kimneyapti-5eb34',
    storageBucket: 'kimneyapti-5eb34.firebasestorage.app',
    iosBundleId: 'com.example.kimNeYapti',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDehXImNu-qRcKAiOSDQn6-8PZqZxIdPR0',
    appId: '1:748755390668:web:7414b707f9a94a147bb269',
    messagingSenderId: '748755390668',
    projectId: 'kimneyapti-5eb34',
    authDomain: 'kimneyapti-5eb34.firebaseapp.com',
    storageBucket: 'kimneyapti-5eb34.firebasestorage.app',
  );

}