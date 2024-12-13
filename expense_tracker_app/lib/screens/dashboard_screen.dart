import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense_summary.dart';
import '../providers/expense_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ExpenseProvider>().fetchExpenses(),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = ExpenseSummary.fromExpenses(
            provider.expenses.map((e) => e.toJson()).toList(),
            monthlyBudget: 10000, // TODO: Make this configurable
          );

          return RefreshIndicator(
            onRefresh: () => provider.fetchExpenses(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(summary),
                  const SizedBox(height: 24),
                  _buildCategoryChart(summary),
                  const SizedBox(height: 24),
                  _buildSpendingTrend(summary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(ExpenseSummary summary) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildCard(
          'Total Expenses',
          currencyFormat.format(summary.totalExpenses),
          Colors.blue,
          Icons.account_balance_wallet,
        ),
        _buildCard(
          'Budget Remaining',
          currencyFormat.format(summary.budgetRemaining),
          summary.budgetRemaining > 0 ? Colors.green : Colors.red,
          Icons.savings,
        ),
        _buildCard(
          'Categories',
          summary.categoryTotals.length.toString(),
          Colors.orange,
          Icons.category,
        ),
        _buildCard(
          'Monthly Budget',
          currencyFormat.format(summary.monthlyBudget),
          Colors.purple,
          Icons.track_changes,
        ),
      ],
    );
  }

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(ExpenseSummary summary) {
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    int colorIndex = 0;
    summary.categoryTotals.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${category}\n${(amount / summary.totalExpenses * 100).toStringAsFixed(1)}%',
          color: colors[colorIndex % colors.length],
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expenses by Category',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingTrend(ExpenseSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Spending Trend',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < summary.dailyExpenses.length) {
                        final date = DateTime.parse(summary.dailyExpenses[value.toInt()].date);
                        return Text(
                          DateFormat('dd/MM').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: summary.dailyExpenses.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.amount);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
