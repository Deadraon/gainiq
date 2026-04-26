import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // For now, we only setup the web configuration.
    // To add Android/iOS, we would use the flutterfire CLI.
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFEAVooLxhNlQxZk2QEpYjfHeDOJv44TY',
    appId: '1:274931184133:web:4c9c6d83dfd56c930e226c',
    messagingSenderId: '274931184133',
    projectId: 'gainiq-app-9922',
    authDomain: 'gainiq-app-9922.firebaseapp.com',
    storageBucket: 'gainiq-app-9922.firebasestorage.app',
  );
}
