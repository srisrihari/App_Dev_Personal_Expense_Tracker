class ExpenseSummary {
  final double totalExpenses;
  final Map<String, double> categoryTotals;
  final List<DailyExpense> dailyExpenses;
  final double monthlyBudget;
  final double budgetRemaining;

  ExpenseSummary({
    required this.totalExpenses,
    required this.categoryTotals,
    required this.dailyExpenses,
    this.monthlyBudget = 0,
    this.budgetRemaining = 0,
  });

  factory ExpenseSummary.fromExpenses(List<dynamic> expenses, {double monthlyBudget = 0}) {
    double total = 0;
    Map<String, double> categories = {};
    Map<String, double> daily = {};

    for (var expense in expenses) {
      final amount = expense['amount'] as double;
      final category = expense['category'] as String;
      final date = expense['date'] as String;

      // Calculate total
      total += amount;

      // Calculate category totals
      categories[category] = (categories[category] ?? 0) + amount;

      // Calculate daily totals
      daily[date] = (daily[date] ?? 0) + amount;
    }

    // Convert daily map to list of DailyExpense objects
    List<DailyExpense> dailyExpenses = daily.entries
        .map((e) => DailyExpense(date: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return ExpenseSummary(
      totalExpenses: total,
      categoryTotals: categories,
      dailyExpenses: dailyExpenses,
      monthlyBudget: monthlyBudget,
      budgetRemaining: monthlyBudget - total,
    );
  }
}

class DailyExpense {
  final String date;
  final double amount;

  DailyExpense({required this.date, required this.amount});
}
