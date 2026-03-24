import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  final DatabaseService _databaseService = DatabaseService.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _useFirebase = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // ── Session helpers ──────────────────────────────────────────────────────

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_user', jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
  }

  Future<UserModel?> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_user');
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Initialize — restores session on every app launch ───────────────────

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try Firebase persistent session first
      final firebaseUser = _firebaseService.currentUser;
      if (firebaseUser != null) {
        // Firebase is still signed in — fetch profile from Firestore
        UserModel? user = await _firebaseService.getUserById(firebaseUser.uid);
        if (user != null) {
          _currentUser = user;
          await _saveSession(user); // keep local cache in sync
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 2. Fall back to locally cached session (SQLite users or offline)
      final cached = await _loadSession();
      if (cached != null) {
        _currentUser = cached;
      }
    } catch (e) {
      print('AuthProvider: initialize error: $e');
      // Still try local cache on any error
      final cached = await _loadSession();
      if (cached != null) _currentUser = cached;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserModel? user;

      if (_useFirebase) {
        try {
          user = await _firebaseService.loginUser(email, password);
        } catch (e) {
          print('Firebase login failed, trying SQLite: $e');
          _useFirebase = false;
        }
      }

      if (user == null) {
        user = await _databaseService.loginUser(email, password);
      }

      if (user != null) {
        _currentUser = user;
        await _saveSession(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register ─────────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? badgeNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserModel? user;

      if (_useFirebase) {
        try {
          user = await _firebaseService.registerUser(
            name: name,
            email: email,
            phone: phone,
            password: password,
            role: role,
            badgeNumber: badgeNumber,
          );
        } catch (e) {
          print('Firebase registration failed, trying SQLite: $e');
          _useFirebase = false;
        }
      }

      if (user == null) {
        user = await _databaseService.registerUser(
          name: name,
          email: email,
          phone: phone,
          password: password,
          role: role,
          badgeNumber: badgeNumber,
        );
      }

      if (user != null) {
        _currentUser = user;
        await _saveSession(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Google Sign-In ───────────────────────────────────────────────────────

  Future<bool> signInWithGoogle(UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _firebaseService.signInWithGoogle(role: role);

      if (user != null) {
        _currentUser = user;
        await _saveSession(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('AuthProvider: Google Sign-In error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _firebaseService.logout();
    await _clearSession();
    _currentUser = null;
    notifyListeners();
  }
}
