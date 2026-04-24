import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_model.dart';

class AuthServices {
  AuthServices._();
  static final AuthServices instance = AuthServices._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AdminModel?> login(String email, String password) async {
    try {
      final UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // map Firebase user to AdminModel
      return AdminModel(
        aid: user.user!.uid,
        name: user.user!.displayName ?? "Admin",
        email: user.user!.email ?? email,
        imgUrl: user.user!.photoURL ?? "",
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Something went wrong");
    }
  }

  Future<void>  signOut()async{
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Something went wrong");
    }


  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await user.delete(); // Deletes from Firebase Authentication
      } else {
        throw Exception("No user currently signed in");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception("Please log in again before deleting your account.");
      } else {
        throw Exception(e.message ?? "Failed to delete account");
      }
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }


}

