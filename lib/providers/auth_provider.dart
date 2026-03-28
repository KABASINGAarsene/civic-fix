import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  auth.User? _currentUser;
  bool _isLoading = false;
  late final StreamSubscription<auth.User?> _authStateSubscription;

  AuthProvider() {
    _currentUser = auth.FirebaseAuth.instance.currentUser;
    _authStateSubscription = auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {
          _currentUser = user;
          notifyListeners();
        });
  }

  auth.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<auth.UserCredential?> loginCitizen({
    required String phone,
    required String password,
  }) async {
    return _runWithLoading(
      () => _authService.loginCitizen(phone: phone, password: password),
    );
  }

  Future<auth.UserCredential?> signUpCitizen({
    required String phone,
    required String name,
    required String email,
    required String password,
  }) async {
    return _runWithLoading(
      () => _authService.signUpCitizen(
        phone: phone,
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<auth.UserCredential?> signUpAdmin({
    required String phone,
    required String name,
    required String email,
    required String password,
    required String district,
  }) async {
    return _runWithLoading(
      () => _authService.signUpAdmin(
        phone: phone,
        name: name,
        email: email,
        password: password,
        district: district,
      ),
    );
  }

  Future<void> signOut() async {
    await _runWithLoading(() => _authService.signOut());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _runWithLoading(() => _authService.sendPasswordResetEmail(email));
  }

  Future<T> _runWithLoading<T>(Future<T> Function() action) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
