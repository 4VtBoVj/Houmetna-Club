import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCl4TO1MK9nR8Ov7IQWdOYzWTbkLCPPywk',
    appId: '1:210162568512:web:115ec2df8f71010f7e3ea5',
    messagingSenderId: '210162568512',
    projectId: 'houmetna-club',
    authDomain: 'houmetna-club.firebaseapp.com',
    storageBucket: 'houmetna-club.firebasestorage.app',
    measurementId: 'G-Y1BX3HJ4YW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyDFp120vnrYHRm8lGRQvfWzUEUAqnkug',
    appId: '1:210162568512:android:5ab5dae966a0f1bc7e3ea5',
    messagingSenderId: '210162568512',
    projectId: 'houmetna-club',
    storageBucket: 'houmetna-club.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForEmulator',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'houmetna-club',
    databaseURL: 'https://houmetna-club.firebaseio.com',
    storageBucket: 'houmetna-club.appspot.com',
    iosBundleId: 'com.example.houmetnaClub',
  );
}
