import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({Key? key, this.expenseToEdit}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late ExpenseCategory _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing expense data if editing
    if (widget.expenseToEdit != null) {
      _amountController = TextEditingController(
        text: widget.expenseToEdit!.amount.toString()
      );
      _descriptionController = TextEditingController(
        text: widget.expenseToEdit!.description
      );
      _selectedCategory = widget.expenseToEdit!.category;
      _selectedDate = widget.expenseToEdit!.date;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedCategory = ExpenseCategory.other;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);
      
      // Get userId
      final userId = await expenseProvider.getUserId();
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not authenticated. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final expense = Expense(
        id: widget.expenseToEdit?.id ?? '',
        userId: userId,
        amount: amount,
        description: _descriptionController.text,
        category: _selectedCategory,
        date: _selectedDate,
      );

      bool success;
      if (widget.expenseToEdit != null) {
        success = await expenseProvider.updateExpense(expense);
      } else {
        success = await expenseProvider.addExpense(expense);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expenseToEdit != null 
                ? 'Expense updated successfully!' 
                : 'Expense added successfully!'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expenseToEdit != null 
                ? 'Failed to update expense.' 
                : 'Failed to add expense.'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expenseToEdit != null ? 'Edit Expense' : 'Add Expense'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ExpenseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.expenseToEdit != null ? 'Update Expense' : 'Add Expense'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
