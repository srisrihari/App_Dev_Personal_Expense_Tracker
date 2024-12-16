import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        if (expenseProvider.expenses.isEmpty) {
          return const Center(
            child: Text('No expenses to analyze'),
          );
        }

        final expenses = expenseProvider.expenses;
        final totalSpent = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );
        final averagePerDay = totalSpent / 30; // Assuming monthly view

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(
                totalSpent: totalSpent,
                expenseCount: expenses.length,
                averagePerDay: averagePerDay,
              ),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(expenses),
              const SizedBox(height: 24),
              _buildMonthlyTrend(expenses),
              const SizedBox(height: 24),
              _buildTopExpenses(expenses),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard({
    required double totalSpent,
    required int expenseCount,
    required double averagePerDay,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem(
                  'Total Spent',
                  '₹${totalSpent.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                ),
                _buildOverviewItem(
                  'Expenses',
                  expenseCount.toString(),
                  Icons.receipt_long,
                ),
                _buildOverviewItem(
                  'Daily Avg',
                  '₹${averagePerDay.toStringAsFixed(2)}',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final totalSpent = categoryTotals.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );

    final sections = categoryTotals.entries.map((entry) {
      final percentage = (entry.value / totalSpent) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: categoryTotals.entries.map((entry) {
                return ListTile(
                  leading: Icon(ExpenseCategory.getIconForCategory(entry.key)),
                  title: Text(entry.key),
                  trailing: Text(
                    '₹${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend(List<Expense> expenses) {
    final dailyTotals = <DateTime, double>{};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (final expense in expenses) {
      if (expense.date.isAfter(thirtyDaysAgo)) {
        final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
        dailyTotals[date] = (dailyTotals[date] ?? 0) + expense.amount;
      }
    }

    final spots = dailyTotals.entries.map((entry) {
      return FlSpot(
        entry.key.difference(thirtyDaysAgo).inDays.toDouble(),
        entry.value,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = thirtyDaysAgo.add(Duration(days: value.toInt()));
                          return Text(DateFormat('d').format(date));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExpenses(List<Expense> expenses) {
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final topExpenses = sortedExpenses.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topExpenses.map((expense) {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(ExpenseCategory.getIconForCategory(expense.category)),
                ),
                title: Text(expense.title),
                subtitle: Text(DateFormat('MMM d, y').format(expense.date)),
                trailing: Text(
                  '₹${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    return ExpenseCategory.getIconForCategory(category);
  }
}
