import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;
  bool _isLoading = false;
  String? _token;
  bool _isAuthenticated = false;

  AuthProvider(this._apiService);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final loginData = await _apiService.login(usernameOrEmail, password);
      
      // Fetch user details or create a User object
      _currentUser = User(
        id: loginData['user_id'],
        username: loginData['username'],
        email: '', // Note: we don't get email from login response
        name: loginData['name'] ?? loginData['username'],
        photoUrl: loginData['photoUrl'] ?? '', // Add if needed
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Rethrow to be handled by the UI
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final registerData = await _apiService.register(
        username: username, 
        email: email, 
        password: password
      );
      
      _currentUser = User(
        id: registerData['user_id'] ?? registerData['_id'],
        username: registerData['username'],
        email: registerData['email'],
        name: registerData['name'] ?? registerData['username'],
        photoUrl: registerData['photoUrl'] ?? '', // Add if needed
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Rethrow to be handled by the UI
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiService.deleteToken();
    await _apiService.deleteUserId();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final userId = await _apiService.getUserId();
    final username = await _apiService.getUsername();
    
    if (userId != null && username != null) {
      _currentUser = User(
        id: userId,
        username: username,
        email: '', // Note: we don't persist email
        name: username,
        photoUrl: '', // Add if needed
      );
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<void> updateProfile(User updatedUser) async {
    // Implement profile update logic
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> validateToken(String token) async {
    try {
      // Basic token validation
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = User(
          id: userData['id'],
          email: userData['email'],
          username: userData['username'] ?? userData['email'].split('@').first,
          name: userData['name'],
          photoUrl: userData['photoUrl'],
        );
        _token = token;
        _isAuthenticated = true;
        notifyListeners();
      } else {
        _isAuthenticated = false;
        _token = null;
      }
    } catch (e) {
      // Any error means token is invalid
      _isAuthenticated = false;
      _token = null;
      print('Token validation error: $e');
    }
    
    notifyListeners();
  }

  Future<String?> _refreshToken(String expiredToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend-url.com/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $expiredToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['access_token'];
      }
    } catch (e) {
      print('Token refresh error: $e');
    }
    
    return null;
  }
}
