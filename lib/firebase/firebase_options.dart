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
        return macos;
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
    apiKey: 'AIzaSyDVuOSVNarmLEYiMU3h9axenBQiEO1YtKA',
    appId: '1:1051480448383:web:7626a9d86b555981790e4a',
    messagingSenderId: '1051480448383',
    projectId: 'fir-flutter-codelab-ffb06',
    authDomain: 'fir-flutter-codelab-ffb06.firebaseapp.com',
    storageBucket: 'fir-flutter-codelab-ffb06.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiAbLODntYFNzsrs1c6L89frh-PgucpLQ',
    appId: '1:1051480448383:android:d4f50daab0df876b790e4a',
    messagingSenderId: '1051480448383',
    projectId: 'fir-flutter-codelab-ffb06',
    storageBucket: 'fir-flutter-codelab-ffb06.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAr-MiXcYfJ8tosu6C6GGkG2Mck5Sanq-0',
    appId: '1:1051480448383:ios:0d14f7fdc0ecd3a8790e4a',
    messagingSenderId: '1051480448383',
    projectId: 'fir-flutter-codelab-ffb06',
    storageBucket: 'fir-flutter-codelab-ffb06.appspot.com',
    iosClientId: '1051480448383-pcckjs23itbn6b5cj9h60duu3vuelpfh.apps.googleusercontent.com',
    iosBundleId: 'com.example.bugle',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAr-MiXcYfJ8tosu6C6GGkG2Mck5Sanq-0',
    appId: '1:1051480448383:ios:0d14f7fdc0ecd3a8790e4a',
    messagingSenderId: '1051480448383',
    projectId: 'fir-flutter-codelab-ffb06',
    storageBucket: 'fir-flutter-codelab-ffb06.appspot.com',
    iosClientId: '1051480448383-pcckjs23itbn6b5cj9h60duu3vuelpfh.apps.googleusercontent.com',
    iosBundleId: 'com.example.bugle',
  );
}
