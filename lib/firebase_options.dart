// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0flwMGejg7rrLkGqs3D7qonB8H9E8Uxc',
    appId: '1:62094269732:web:a58b2a941f9af5f338a7b1',
    messagingSenderId: '62094269732',
    projectId: 'instaport-application',
    authDomain: 'instaport-application.firebaseapp.com',
    databaseURL: 'https://instaport-application-default-rtdb.firebaseio.com',
    storageBucket: 'instaport-application.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAp6a0NJIJFdO6e8BXS-eypMnC0XpDMaCE',
    appId: '1:62094269732:android:956fdd2303f2c5c938a7b1',
    messagingSenderId: '62094269732',
    projectId: 'instaport-application',
    databaseURL: 'https://instaport-application-default-rtdb.firebaseio.com',
    storageBucket: 'instaport-application.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApi9B0kXUWpzSFHcp2z182KunJ0bJZugU',
    appId: '1:62094269732:ios:6c2b441864db1ada38a7b1',
    messagingSenderId: '62094269732',
    projectId: 'instaport-application',
    databaseURL: 'https://instaport-application-default-rtdb.firebaseio.com',
    storageBucket: 'instaport-application.appspot.com',
    iosBundleId: 'com.instaport.customer',
  );
}
