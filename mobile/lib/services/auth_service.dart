import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Use local emulator for development (Android only, not web)
  AuthService() {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    if (isAndroid) {
      try {
        // Use 10.0.2.2 for Android emulator
        _auth.useAuthEmulator('10.0.2.2', 9099);
        _functions.useFunctionsEmulator('10.0.2.2', 5001);
        print('✅ Emulator connections enabled');
      } catch (e) {
        print('⚠️ Emulator connection failed: $e');
      }
    } else {
      print('ℹ️ Not on Android (or running on web) - skipping emulator');
    }
  }

  // Get auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Save device token for push notifications
  Future<void> saveDeviceToken(String token) async {
    try {
      final callable = _functions.httpsCallable('saveDeviceToken');
      await callable.call({'token': token});
    } catch (e) {
      print('Error saving device token: $e');
    }
  }
}
