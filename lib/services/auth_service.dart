import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Google Sign-In
  Future<auth.UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Check if this is a new user and create Firestore document
      if (userCredential.user != null) {
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          // New user - create Firestore document
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'name': userCredential.user!.displayName ?? 'User',
            'email': userCredential.user!.email,
            'phone': userCredential.user!.phoneNumber ?? '',
            'role': 'citizen',
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
}
