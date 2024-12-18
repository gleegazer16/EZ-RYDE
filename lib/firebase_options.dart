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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfjibPFCpfR1f2tz68VRCMk0rRqL_CMRQ',
    appId: '1:1075593005307:android:fd271d86afcfdce11a485e',
    messagingSenderId: '1075593005307',
    projectId: 'amigos-1a5ef',
    storageBucket: 'amigos-1a5ef.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgiE9H7-JfVh0pW0YiWwzq3CU7I_rwhVA',
    appId: '1:1075593005307:ios:e9b768238d2752d81a485e',
    messagingSenderId: '1075593005307',
    projectId: 'amigos-1a5ef',
    storageBucket: 'amigos-1a5ef.appspot.com',
    androidClientId: '1075593005307-qd0j64ss142kojm27lnrte9o2tdrbpc1.apps.googleusercontent.com',
    iosClientId: '1075593005307-d7iimpa9kocuulcs29b0735or0n8vppp.apps.googleusercontent.com',
    iosBundleId: 'com.example.greenTaxiMine',
  );

}