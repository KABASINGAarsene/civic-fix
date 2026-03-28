import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Sign in with Google
  Future<auth.UserCredential?> signInWithGoogle() async {
    try {
      // For Flutter Web, Google Sign-In strictly requires the Web Client ID
      // to be passed explicitly if it wasn't auto-configured in firebase_options.
      // Replace the string below with your actual Web Client ID from the Firebase Console:
      // Project Settings > General > Web apps > your app > Web Client ID
      // (or from Google Cloud Console's Credentials page)
      const String webClientId = '180208394444-8jmbo2kvv8johktl8jta0k8g0ma54sel.apps.googleusercontent.com';

      // Only pass the Web Client ID when running on Flutter Web.
      // Android auto-detects it through `google-services.json`.
      final String? clientId = kIsWeb && webClientId != 'REPLACE_ME_WITH_YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' 
          ? webClientId 
          : null;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: clientId,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in flow
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final auth.OAuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          // Create a new citizen profile for the Google user
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? 'Citizen User',
            'email': user.email,
            'phone': '', // Optional or omitted for Google users
            'role': 'citizen',
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          if (user.email != null) {
            // Mapping for consistency with phone mappings logic, though phone is empty
            await _firestore.collection('phoneMappings').doc(user.uid).set({
              'email': user.email,
            });
          }
        }
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Check if current user is logged in
  auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
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
