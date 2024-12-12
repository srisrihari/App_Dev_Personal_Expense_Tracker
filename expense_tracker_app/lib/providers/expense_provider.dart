import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await _apiService.getExpenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();

    final success = await _apiService.createExpense(expense);
    if (success) {
      await fetchExpenses();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateExpense(String id, Expense expense) async {
    _isLoading = true;
    notifyListeners();

    final success = await _apiService.updateExpense(id, expense);
    if (success) {
      await fetchExpenses();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteExpense(String id) async {
    _isLoading = true;
    notifyListeners();

    final success = await _apiService.deleteExpense(id);
    if (success) {
      await fetchExpenses();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
