import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedExpenses = await _apiService.getExpenses();
      _expenses = fetchedExpenses;
      debugPrint('Fetched ${_expenses.length} expenses');
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      _expenses = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      final newExpense = await _apiService.createExpense(expense);
      _expenses.add(newExpense);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      final updatedExpense = await _apiService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _apiService.deleteExpense(expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      return false;
    }
  }

  double getTotalExpenses() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> getExpensesByCategory() {
    final categoryTotals = <String, double>{};
    for (var expense in _expenses) {
      categoryTotals[expense.category.toString().split('.').last] = 
        (categoryTotals[expense.category.toString().split('.').last] ?? 0) + expense.amount;
    }
    return _expenses;
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((expense) {
      return expense.date.isAfter(start) && expense.date.isBefore(end);
    }).toList();
  }

  Future<String?> getUserId() async {
    try {
      return await _apiService.getUserId();
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<void> fetchExpenseInsights() async {
    try {
      // Removed this method as it was not present in the updated code
    } catch (e) {
      debugPrint('Error fetching expense insights: $e');
    }
  }

  String getInsightMessage(DailyInsight insight) {
    if (insight.performance == 'below_average') {
      return 'Great job! You spent ${insight.differencePercentage.toStringAsFixed(2)}% less than your average today.';
    } else {
      return 'You spent ${insight.differencePercentage.toStringAsFixed(2)}% more than your average today. Try to be more mindful of your expenses.';
    }
  }

  String getMonthlyInsightMessage() {
    // Removed this method as it was not present in the updated code
    return '';
  }
}

class ExpenseInsights {
  final double totalMonthlyExpense;
  final double averageMonthlyExpense;
  final double averageWeeklyExpense;
  final List<DailyInsight> dailyInsights;

  ExpenseInsights({
    required this.totalMonthlyExpense,
    required this.averageMonthlyExpense,
    required this.averageWeeklyExpense,
    required this.dailyInsights,
  });

  factory ExpenseInsights.fromJson(Map<String, dynamic> json) {
    return ExpenseInsights(
      totalMonthlyExpense: (json['total_monthly_expense'] ?? 0.0).toDouble(),
      averageMonthlyExpense: (json['average_monthly_expense'] ?? 0.0).toDouble(),
      averageWeeklyExpense: (json['average_weekly_expense'] ?? 0.0).toDouble(),
      dailyInsights: (json['daily_insights'] as List<dynamic>?)
          ?.map((insight) => DailyInsight.fromJson(insight))
          .toList() ?? [],
    );
  }
}

class DailyInsight {
  final String date;
  final double amount;
  final String performance;
  final double differencePercentage;

  DailyInsight({
    required this.date,
    required this.amount,
    required this.performance,
    required this.differencePercentage,
  });

  factory DailyInsight.fromJson(Map<String, dynamic> json) {
    return DailyInsight(
      date: json['date'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      performance: json['performance'] ?? 'neutral',
      differencePercentage: (json['difference_percentage'] ?? 0.0).toDouble(),
    );
  }
}
