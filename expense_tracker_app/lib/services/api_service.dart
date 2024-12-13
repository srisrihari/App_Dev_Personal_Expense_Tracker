import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/expense.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to host machine's localhost
  // For physical device, use your computer's local IP address
  // For Linux desktop, use 127.0.0.1
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<String?> getUserId() async {
    return await storage.read(key: 'user_id');
  }

  Future<void> saveUserId(String userId) async {
    await storage.write(key: 'user_id', value: userId);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
          'grant_type': 'password',
        },
      );

      print('Login request: $baseUrl/token');
      print('Login request body: username=$username');
      print('Login response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['access_token']);
        await saveUserId(data['user_id']);
        return true;
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        // You can add more specific error handling here
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      print('Register response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/expenses'),
        headers: headers,
      );

      print('Get expenses response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get expenses error: $e');
      return [];
    }
  }

  Future<bool> createExpense(Expense expense) async {
    try {
      final headers = {
        ...await _getHeaders(),
        'Accept': 'application/json',
      };
      
      final userId = await getUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      final expenseData = expense.toJson();
      expenseData['user_id'] = userId;
      
      // Format the date in ISO format
      final DateTime date = DateTime.parse(expense.date);
      expenseData['date'] = date.toIso8601String().split('T')[0];

      print('Creating expense with data: $expenseData');
      final uri = Uri.parse('$baseUrl/expenses/');
      print('Request URI: ${uri.toString()}');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(expenseData),
      );

      print('Create expense response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 307) {
        final redirectUrl = response.headers['location'];
        print('Redirect URL: $redirectUrl');
        if (redirectUrl != null) {
          final redirectResponse = await http.post(
            Uri.parse(redirectUrl),
            headers: headers,
            body: jsonEncode(expenseData),
          );
          print('Redirect response: ${redirectResponse.statusCode} ${redirectResponse.body}');
          return redirectResponse.statusCode == 201 || redirectResponse.statusCode == 200;
        }
      }
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Create expense error: $e');
      return false;
    }
  }

  Future<bool> updateExpense(String id, Expense expense) async {
    try {
      final headers = await _getHeaders();
      final userId = await getUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      final expenseData = expense.toJson();
      expenseData['user_id'] = userId;

      print('Updating expense with data: $expenseData');

      final response = await http.put(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: headers,
        body: jsonEncode(expenseData),
      );

      print('Update expense response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Update expense error: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: headers,
      );

      print('Delete expense response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete expense error: $e');
      return false;
    }
  }
}
