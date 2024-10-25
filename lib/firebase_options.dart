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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAMzbkT6pdQILgccMUqPPLzhKKYu1AvnY',
    appId: '1:735535025475:web:eab08b3a48a5fa08d2b3f6',
    messagingSenderId: '735535025475',
    projectId: 'signin-e8f00',
    authDomain: 'signin-e8f00.firebaseapp.com',
    storageBucket: 'signin-e8f00.appspot.com',
    measurementId: 'G-V5ZMZ64GT0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEfHI8AWqAtO9mV2-3aYYx-9Nk25e_HFk',
    appId: '1:735535025475:android:f98ebb64429fd2ebd2b3f6',
    messagingSenderId: '735535025475',
    projectId: 'signin-e8f00',
    storageBucket: 'signin-e8f00.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdAEdLzRQI9412RsvlZE3tSkhp4PGlydg',
    appId: '1:735535025475:ios:9ebf61a24eaaf472d2b3f6',
    messagingSenderId: '735535025475',
    projectId: 'signin-e8f00',
    storageBucket: 'signin-e8f00.appspot.com',
    iosBundleId: 'com.example.googleSign',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBdAEdLzRQI9412RsvlZE3tSkhp4PGlydg',
    appId: '1:735535025475:ios:9ebf61a24eaaf472d2b3f6',
    messagingSenderId: '735535025475',
    projectId: 'signin-e8f00',
    storageBucket: 'signin-e8f00.appspot.com',
    iosBundleId: 'com.example.googleSign',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAMzbkT6pdQILgccMUqPPLzhKKYu1AvnY',
    appId: '1:735535025475:web:cf613a3e840d817fd2b3f6',
    messagingSenderId: '735535025475',
    projectId: 'signin-e8f00',
    authDomain: 'signin-e8f00.firebaseapp.com',
    storageBucket: 'signin-e8f00.appspot.com',
    measurementId: 'G-V05V17B1DX',
  );
}
