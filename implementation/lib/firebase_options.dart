// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
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
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuKUvQ9nZXLUF0NqsFDXSdGHwToawxyvQ',
    appId: '1:351146855860:android:1d460bb507f7170d9276e1',
    messagingSenderId: '351146855860',
    projectId: 'endless-set-314517',
    authDomain: 'endless-set-314517.firebaseapp.com',
    storageBucket: 'endless-set-314517.appspot.com',
    databaseURL: 'https://endless-set-314517-default-rtdb.asia-southeast1.firebasedatabase.app',
    measurementId: 'G-Z479E0VRMN',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCI3VK_MMXG6VPkunF5bze1UefX0yJEHwc',
    appId: '1:351146855860:web:272b96d2fb255de39276e1',
    messagingSenderId: '351146855860',
    projectId: 'endless-set-314517',
    authDomain: 'endless-set-314517.firebaseapp.com',
    storageBucket: 'endless-set-314517.appspot.com',
    measurementId: 'G-Z479E0VRMN',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCgzOd_FoFxhRVyfiTxdy1_G6AiWUXFwq4',
    appId: '1:351146855860:ios:cc3ecdd0eeefbc029276e1',
    messagingSenderId: '351146855860',
    projectId: 'endless-set-314517',
    storageBucket: 'endless-set-314517.appspot.com',
    iosBundleId: 'com.example.senior',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCI3VK_MMXG6VPkunF5bze1UefX0yJEHwc',
    appId: '1:351146855860:web:e971b415154ab49b9276e1',
    messagingSenderId: '351146855860',
    projectId: 'endless-set-314517',
    authDomain: 'endless-set-314517.firebaseapp.com',
    storageBucket: 'endless-set-314517.appspot.com',
    measurementId: 'G-SJWFF0YG99',
  );
}
