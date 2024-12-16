import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch expenses when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
              // Refresh expenses list when returning from add screen
              if (result == true) {
                if (mounted) {
                  context.read<ExpenseProvider>().fetchExpenses();
                }
              }
            },
          ),
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ExpenseProvider>().fetchExpenses();
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseProvider.expenses.isEmpty) {
            return const Center(
              child: Text(
                'No expenses yet. Add your first expense!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => expenseProvider.fetchExpenses(),
            child: ListView.builder(
              itemCount: expenseProvider.expenses.length,
              itemBuilder: (context, index) {
                final expense = expenseProvider.expenses[index];
                return ExpenseListItem(expense: expense);
              },
            ),
          );
        },
      ),
    );
  }
}

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          '\$${expense.amount.toStringAsFixed(2)}', 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.category.toString().split('.').last.toUpperCase()),
            Text(expense.description),
            Text(expense.date.toString().split(' ')[0]),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(expenseToEdit: expense),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmationDialog(context, expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final expenseProvider = Provider.of<ExpenseProvider>(
                context, 
                listen: false
              );
              expenseProvider.deleteExpense(expense.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
