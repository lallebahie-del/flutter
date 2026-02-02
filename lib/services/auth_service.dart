import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is admin
  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Get user role
  Future<String> getUserRole() async {
    final user = currentUser;
    if (user == null) return 'user';

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] ?? 'user';
    } catch (e) {
      return 'user';
    }
  }

  // Create user document on registration
  Future<void> createUserDocument(User user, {String role = 'user'}) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@')[0],
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Update user display name
  Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await user.updateDisplayName(displayName);
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
      });
    } catch (e) {
      print('Error updating display name: $e');
    }
  }

  // Sign in
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register
  Future<UserCredential> register(String email, String password, {String? displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
    }

    // Create user document
    if (credential.user != null) {
      await createUserDocument(credential.user!, role: 'user');
    }

    return credential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
