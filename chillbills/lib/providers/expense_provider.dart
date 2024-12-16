import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  ExpenseProvider(this._apiService);

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchExpenses() async {
    try {
      _isLoading = true;
      _setError(null);
      notifyListeners();

      final response = await _apiService.get('/expenses');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _expenses = data.map((json) => Expense.fromJson(json)).toList();
        _expenses.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
      } else {
        _setError('Failed to fetch expenses: ${response.error}');
      }
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      _setError('Failed to fetch expenses: $e');
      _expenses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Expense?> addExpense(Expense expense) async {
    try {
      _isLoading = true;
      _setError(null);
      notifyListeners();

      final savedExpense = await _apiService.saveExpense(expense);
      _expenses.insert(0, savedExpense); // Add at the beginning since we sort by date
      return savedExpense;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      _setError('Failed to add expense: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Expense?> updateExpense(Expense expense) async {
    try {
      _isLoading = true;
      _setError(null);
      notifyListeners();

      if (expense.id == null) {
        _setError('Cannot update expense without an ID');
        return null;
      }

      final savedExpense = await _apiService.saveExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = savedExpense;
      }
      return savedExpense;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      _setError('Failed to update expense: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      _isLoading = true;
      _setError(null);
      notifyListeners();

      final response = await _apiService.delete('/expenses/$expenseId');

      if (response.statusCode == 200) {
        _expenses.removeWhere((e) => e.id == expenseId);
        return true;
      } else {
        _setError('Failed to delete expense: ${response.error}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      _setError('Failed to delete expense: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Insights methods
  Map<String, double> getCategoryTotals() {
    final totals = <String, double>{};
    for (final expense in _expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  List<ExpenseInsights> getMonthlyInsights() {
    final insights = <ExpenseInsights>[];
    if (_expenses.isEmpty) return insights;

    // Group expenses by month
    final expensesByMonth = <DateTime, List<Expense>>{};
    for (final expense in _expenses) {
      final date = DateTime(expense.date.year, expense.date.month);
      expensesByMonth[date] = [...(expensesByMonth[date] ?? []), expense];
    }

    // Calculate insights for each month
    expensesByMonth.forEach((date, expenses) {
      final totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
      final categoryTotals = <String, double>{};
      for (final expense in expenses) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      insights.add(ExpenseInsights(
        date: date,
        totalAmount: totalAmount,
        categoryTotals: categoryTotals,
      ));
    });

    // Sort insights by date (newest first)
    insights.sort((a, b) => b.date.compareTo(a.date));
    return insights;
  }

  List<DailyInsight> getDailyInsights() {
    final insights = <DailyInsight>[];
    if (_expenses.isEmpty) return insights;

    // Group expenses by day
    final expensesByDay = <DateTime, List<Expense>>{};
    for (final expense in _expenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      expensesByDay[date] = [...(expensesByDay[date] ?? []), expense];
    }

    // Calculate insights for each day
    expensesByDay.forEach((date, expenses) {
      final totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
      insights.add(DailyInsight(
        date: date,
        totalAmount: totalAmount,
        expenses: expenses,
      ));
    });

    // Sort insights by date (newest first)
    insights.sort((a, b) => b.date.compareTo(a.date));
    return insights;
  }
}

class ExpenseInsights {
  final DateTime date;
  final double totalAmount;
  final Map<String, double> categoryTotals;

  ExpenseInsights({
    required this.date,
    required this.totalAmount,
    required this.categoryTotals,
  });
}

class DailyInsight {
  final DateTime date;
  final double totalAmount;
  final List<Expense> expenses;

  DailyInsight({
    required this.date,
    required this.totalAmount,
    required this.expenses,
  });
}
