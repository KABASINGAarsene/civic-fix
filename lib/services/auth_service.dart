import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '180208394444-8jmbo2kvv8johktl8jta0k8g0ma54sel.apps.googleusercontent.com' : null,
  );

  // Sign in with Google
  Future<auth.UserCredential?> signInWithGoogle({required String role}) async {
    try {
      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // 2. Obtain details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Once signed in, return the UserCredential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user profile exists in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // New user: Create profile
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? 'Citizen',
            'email': user.email,
            'phone': '', // Google doesn't provide phone by default
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Sign up a citizen
  Future<auth.UserCredential?> signUpCitizen({
    required String phone,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create the user in Firebase Auth using Email and Password
      // Firebase doesn't natively support Phone + Password creation easily, 
      // so we use email/password for the core auth token.
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save the metadata (Phone, Name, Role) to Firestore Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'phone': phone,
          'name': name,
          'email': email,
          'role': 'citizen',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. We also need a mapping to look up email by phone during login
        await _firestore.collection('phoneMappings').doc(phone).set({
          'email': email,
        });

        // 4. Send Firebase Verification Email
        if (!credential.user!.emailVerified) {
          await credential.user!.sendEmailVerification();
        }
        
        // Force sign out so they have to verify before logging in
        await _firebaseAuth.signOut();
      }

      return credential;
    } catch (e) {
      print('Signup Error: $e');
      rethrow;
    }
  }

  // Sign in a citizen using Phone and Password
  Future<auth.UserCredential?> loginCitizen({
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Look up the email associated with this phone number
      final mappingDoc = await _firestore.collection('phoneMappings').doc(phone).get();
      
      if (!mappingDoc.exists) {
        throw Exception('No account found for this phone number.');
      }

      final email = mappingDoc.data()?['email'] as String;

      // 2. Sign in using the retrieved email and the provided password
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && !credential.user!.emailVerified) {
        await _firebaseAuth.signOut();
        throw Exception('Please check your spam folder for the link to verify your sign up before logging in.');
      }

      return credential;
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  // Sign up an Admin
  Future<auth.UserCredential?> signUpAdmin({
    required String email,
    required String password,
    required String phone,
    required String name,
    required String district,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'phone': phone,
          'name': name,
          'email': email,
          'role': 'admin',
          'district': district,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('phoneMappings').doc(phone).set({
          'email': email,
        });

        if (!credential.user!.emailVerified) {
          await credential.user!.sendEmailVerification();
        }
        
        // Force sign out so they have to verify before logging in
        await _firebaseAuth.signOut();
      }

      return credential;
    } catch (e) {
      print('Admin Signup Error: $e');
      rethrow;
    }
  }

  // Check if current user is logged in
  auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print('Password Reset Error: $e');
      rethrow;
    }
  }
}
