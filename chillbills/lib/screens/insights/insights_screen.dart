import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  _InsightsScreenState createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Motivational messages for different spending scenarios
  final List<String> _positiveMessages = [
    'Great job tracking your expenses!',
    'You\'re making smart financial choices!',
    'Keep up the excellent budgeting!',
    'Your financial awareness is impressive!',
  ];

  final List<String> _warningMessages = [
    'Time to review your spending habits.',
    'Consider cutting back on non-essential expenses.',
    'Small savings can make a big difference!',
    'Let\'s optimize your budget together.',
  ];

  // Helper method to generate motivational message
  String _generateMotivationalMessage(double totalSpending, double averageSpending) {
    final random = Random();
    if (totalSpending < averageSpending * 0.8) {
      return _positiveMessages[random.nextInt(_positiveMessages.length)];
    } else if (totalSpending > averageSpending * 1.2) {
      return _warningMessages[random.nextInt(_warningMessages.length)];
    } else {
      return 'You\'re right on track with your expenses!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Insights'),
        backgroundColor: const Color(0xFF6A5AE0),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.expenses.isEmpty) {
            return const Center(
              child: Text(
                'No expenses to track yet. Start adding expenses!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Calculate insights
          final currentMonth = DateTime.now().month;
          final currentYear = DateTime.now().year;
          final monthlyExpenses = expenseProvider.expenses
              .where((expense) => 
                expense.date.month == currentMonth && 
                expense.date.year == currentYear)
              .toList();

          final totalMonthlyExpense = monthlyExpenses.fold(
            0.0, (sum, expense) => sum + expense.amount
          );
          final averageMonthlyExpense = monthlyExpenses.isNotEmpty 
            ? totalMonthlyExpense / monthlyExpenses.length 
            : 0.0;

          final motivationalMessage = _generateMotivationalMessage(
            totalMonthlyExpense, 
            averageMonthlyExpense
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Monthly Overview Card
                  _buildMonthlyOverviewCard(
                    totalMonthlyExpense, 
                    averageMonthlyExpense,
                    motivationalMessage
                  ),

                  const SizedBox(height: 16),

                  // Category Breakdown
                  _buildCategoryBreakdownCard(expenseProvider.expenses),

                  const SizedBox(height: 16),

                  // Daily Performance Insights
                  _buildDailyPerformanceCard(monthlyExpenses),

                  const SizedBox(height: 16),

                  // Expense Trend Visualization
                  _buildExpenseTrendCard(expenseProvider.expenses),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlyOverviewCard(
    double totalMonthlyExpense, 
    double averageMonthlyExpense,
    String motivationalMessage
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Expense Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Total Spent', 
                  '\$${totalMonthlyExpense.toStringAsFixed(2)}',
                  Icons.monetization_on
                ),
                _buildStatItem(
                  'Monthly Avg', 
                  '\$${averageMonthlyExpense.toStringAsFixed(2)}',
                  Icons.trending_up
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              motivationalMessage,
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6A5AE0), size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdownCard(List<Expense> expenses) {
    // Group expenses by category
    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      final categoryName = expense.category.toString().split('.').last;
      categoryTotals[categoryName] = 
        (categoryTotals[categoryName] ?? 0) + expense.amount;
    }

    // Sort categories by total amount in descending order
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 12),
            ...sortedCategories.map((entry) {
              final percentage = (entry.value / sortedCategories
                .map((e) => e.value)
                .reduce((a, b) => a + b)) * 100;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: _getCategoryColor(entry.key),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${entry.key.capitalize()}: \$${entry.value.toStringAsFixed(2)}',
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPerformanceCard(List<Expense> monthlyExpenses) {
    // Group expenses by day
    final dailyExpenses = <DateTime, List<Expense>>{};
    for (var expense in monthlyExpenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyExpenses.putIfAbsent(date, () => []).add(expense);
    }

    // Calculate daily totals and sort
    final dailyTotals = dailyExpenses.map((date, expenses) {
      final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      return MapEntry(date, total);
    });

    final sortedDailyTotals = dailyTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 12),
            ...sortedDailyTotals.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd').format(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: entry.value > 100 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrendCard(List<Expense> expenses) {
    // Group expenses by month
    final monthlyTotals = <String, double>{};
    final dateFormat = DateFormat('yyyy-MM');

    for (var expense in expenses) {
      final monthKey = dateFormat.format(expense.date);
      monthlyTotals[monthKey] = 
        (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    // Sort months chronologically
    final sortedMonths = monthlyTotals.keys.toList()..sort();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortedMonths.map((monthKey) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          monthKey,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '\$${monthlyTotals[monthKey]!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A5AE0),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colorMap = {
      'food': Colors.red,
      'transport': Colors.blue,
      'entertainment': Colors.green,
      'shopping': Colors.purple,
      'utilities': Colors.orange,
      'other': Colors.grey,
    };
    return colorMap[category] ?? Colors.grey;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
