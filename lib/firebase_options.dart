import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // For simplicity, we'll only include web configuration
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyADtVWJBi-zIy2gWDggIN9tHvPJ8NROHK0',
    authDomain: 'gitsbites.firebaseapp.com',
    projectId: 'gitsbites',
    storageBucket: 'gitsbites.firebasestorage.app',
    messagingSenderId: '524013313932',
    appId: '1:524013313932:web:7c4d7b341ce9bea77880a9',
    measurementId: 'G-C5LB4FV54D',
  );
}