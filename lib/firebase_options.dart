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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFEAVooLxhNlQxZk2QEpYjfHeDOJv44TY',
    appId: '1:274931184133:web:4c9c6d83dfd56c930e226c',
    messagingSenderId: '274931184133',
    projectId: 'gainiq-app-9922',
    authDomain: 'gainiq-app-9922.firebaseapp.com',
    storageBucket: 'gainiq-app-9922.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAG3bH9LCAANAntNKqU55lLvtULwPgMqKA',
    appId: '1:274931184133:android:7f11b917b3a7d6cc0e226c',
    messagingSenderId: '274931184133',
    projectId: 'gainiq-app-9922',
    storageBucket: 'gainiq-app-9922.firebasestorage.app',
  );
}
