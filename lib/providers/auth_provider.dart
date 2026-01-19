import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

/// Authentication provider for managing user sessions
/// Handles login, registration, and session persistence
class AuthProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize and check for saved session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        // Load user from database
        // For demo, we'll just mark as not authenticated
        // In production, fetch user details from database
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _dbService.loginUser(email, password);
      
      if (user != null) {
        _currentUser = user;
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.id);
        
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

  /// Register new user
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
      final user = await _dbService.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
        badgeNumber: badgeNumber,
      );

      if (user != null) {
        _currentUser = user;
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.id);
        
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

  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    
    notifyListeners();
  }
}
