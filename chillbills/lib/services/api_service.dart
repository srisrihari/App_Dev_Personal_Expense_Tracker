import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }
  
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // Helper method to get token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Helper method to get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Ensure URL always has a trailing slash
  String _ensureTrailingSlash(String url) {
    return url.endsWith('/') ? url : '$url/';
  }

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Try multiple possible endpoints
      final possibleUrls = [
        _ensureTrailingSlash('$baseUrl/token'),
        _ensureTrailingSlash('$baseUrl/token/'),
      ];

      for (final url in possibleUrls) {
        debugPrint('Attempting Login URL: $url');
        
        final response = await client.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: 'username=$email&password=$password',
        );

        debugPrint('Login Response Status Code: ${response.statusCode}');
        debugPrint('Login Response Body: ${response.body}');
        debugPrint('Login Response Headers: ${response.headers}');

        // Handle redirects
        if (response.statusCode == 307 || response.statusCode == 308) {
          final redirectUrl = response.headers['location'];
          if (redirectUrl != null) {
            debugPrint('Redirecting to: $redirectUrl');
            final redirectResponse = await client.post(
              Uri.parse(redirectUrl),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json',
              },
              body: 'username=$email&password=$password',
            );

            debugPrint('Redirect Response Status Code: ${redirectResponse.statusCode}');
            debugPrint('Redirect Response Body: ${redirectResponse.body}');

            if (redirectResponse.statusCode == 200) {
              final responseBody = jsonDecode(redirectResponse.body);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('access_token', responseBody['access_token']);
              await prefs.setString('user_id', responseBody['user_id']?.toString() ?? '');
              await prefs.setString('username', responseBody['username']);
              return responseBody;
            }
          }
        }

        // Direct success case
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', responseBody['access_token']);
          await prefs.setString('user_id', responseBody['user_id']?.toString() ?? '');
          await prefs.setString('username', responseBody['username']);
          return responseBody;
        }
      }

      // If no successful login found
      throw Exception('Login failed. Unable to authenticate.');
    } catch (e) {
      debugPrint('Login error details: $e');
      rethrow;
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> deleteUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<Map<String, dynamic>> register({
    required String username, 
    required String email, 
    required String password
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password
        }),
      );

      debugPrint('Registration Request: username=$username, email=$email');
      debugPrint('Registration Response Status Code: ${response.statusCode}');
      debugPrint('Registration Response Body: ${response.body}');
      debugPrint('Registration Response Headers: ${response.headers}');

      // Parse the response body
      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Successful registration
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseBody['access_token']);
        await prefs.setString('user_id', responseBody['user_id']?.toString() ?? '');
        await prefs.setString('username', responseBody['username']);
        
        return responseBody;
      } else {
        // Handle error response
        final errorMessage = responseBody['detail'] ?? 
                             responseBody['message'] ?? 
                             'Registration failed';
        
        debugPrint('Registration Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Registration Error Details: $e');
      
      // If it's a network or parsing error
      if (e is SocketException) {
        throw Exception('Network error. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Invalid server response');
      }
      
      rethrow;
    }
  }

  // Get all expenses
  Future<List<Expense>> getExpenses() async {
    try {
      final headers = await _getHeaders();
      final userId = await getUserId();
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await client.get(
        Uri.parse('$baseUrl/expenses'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> expenseList = jsonDecode(response.body);
        return expenseList.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch expenses: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getExpenses: $e');
      rethrow;
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    try {
      final headers = await _getHeaders();
      final userId = await getUserId();
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final expenseData = expense.toJson();
      expenseData['user_id'] = userId;

      final response = await client.post(
        Uri.parse('$baseUrl/expenses'),
        headers: headers,
        body: jsonEncode(expenseData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Expense.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create expense: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in createExpense: $e');
      rethrow;
    }
  }

  Future<Expense> updateExpense(Expense expense) async {
    try {
      final headers = await _getHeaders();
      final userId = await getUserId();
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (expense.id.isEmpty) {
        throw Exception('Expense ID is required for update');
      }

      final response = await client.put(
        Uri.parse('$baseUrl/expenses/${expense.id}'),
        headers: headers,
        body: jsonEncode(expense.toJson()),
      );

      if (response.statusCode == 200) {
        return Expense.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update expense: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in updateExpense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      final headers = await _getHeaders();
      final userId = await getUserId();
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await client.delete(
        Uri.parse('$baseUrl/expenses/$expenseId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in deleteExpense: $e');
      rethrow;
    }
  }

  // Budget methods
  Future<Map<String, dynamic>> createBudget({
    required double amount, 
    required String category, 
    required int month, 
    required int year
  }) async {
    try {
      final url = _ensureTrailingSlash('$baseUrl/budgets');
      final headers = await _getHeaders();
      
      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'category': category,
          'month': month,
          'year': year,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody;
      } else {
        throw Exception(responseBody['detail'] ?? 'Failed to create budget');
      }
    } catch (e) {
      debugPrint('Create budget error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getBudgets(int month, int year) async {
    try {
      final url = _ensureTrailingSlash('$baseUrl/budgets/$month/$year');
      final headers = await _getHeaders();
      
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['detail'] ?? 'Failed to retrieve budgets');
      }
    } catch (e) {
      debugPrint('Get budgets error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAllBudgets() async {
    try {
      final url = _ensureTrailingSlash('$baseUrl/budgets');
      final headers = await _getHeaders();
      
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['detail'] ?? 'Failed to retrieve all budgets');
      }
    } catch (e) {
      debugPrint('Get all budgets error: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}\n${response.body}');
    }
  }
}
