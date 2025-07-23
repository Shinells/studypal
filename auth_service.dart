import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null means success
    } catch (e) {
      print('Register Error: $e');
      return e.toString(); // return error message
    }
  }

  // Login
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null means success
    } catch (e) {
      print('Login Error: $e');
      return e.toString(); // return error message
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  Stream<User?> get userChanges => _auth.authStateChanges();
}
