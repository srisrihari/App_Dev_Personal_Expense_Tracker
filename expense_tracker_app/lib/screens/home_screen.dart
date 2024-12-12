import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ExpenseProvider>().fetchExpenses(),
    );
  }

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = provider.expenses;
          double totalAmount = expenses.fold(
            0,
            (sum, expense) => sum + expense.amount,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Total: \$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (expenses.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No expenses yet. Add some!',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = expenses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Card(
                          child: Dismissible(
                            key: Key(expense.id ?? ''),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              if (expense.id != null) {
                                provider.deleteExpense(expense.id!);
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  expense.category[0].toUpperCase(),
                                ),
                              ),
                              title: Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                '${expense.category}\n${expense.date}',
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editExpense(context, expense),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: expenses.length,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
