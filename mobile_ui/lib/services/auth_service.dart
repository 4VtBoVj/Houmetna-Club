import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  AuthService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user role (admin or user)
  Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'user';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['role'] ?? 'user';
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user role: $e');
      return 'user';
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  Future<void> saveDeviceToken(String token) async {
    try {
      final callable = _functions.httpsCallable('saveDeviceToken');
      await callable.call({'token': token});
    } catch (e) {
      // ignore: avoid_print
      print('Error saving device token: $e');
    }
  }
}
