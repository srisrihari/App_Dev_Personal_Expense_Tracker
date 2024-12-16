import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transportation,
  entertainment,
  shopping,
  utilities,
  health,
  education,
  other
}

class Expense {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final ExpenseCategory category;
  final DateTime date;

  Expense({
    required this.userId,
    this.id = '',
    required this.amount,
    this.description = '',
    required this.category,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['amount'] is int) 
        ? (json['amount'] as int).toDouble() 
        : (json['amount'] as num).toDouble(),
      description: json['description'] ?? '',
      category: _categoryFromString(json['category'] ?? 'other'),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'description': description,
      'category': category.toString().split('.').last,
      'date': date.toIso8601String(),
    };
  }

  static ExpenseCategory _categoryFromString(String category) {
    try {
      return ExpenseCategory.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == category.toLowerCase()
      );
    } catch (e) {
      return ExpenseCategory.other;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_cart;
      case ExpenseCategory.utilities:
        return Icons.build;
      case ExpenseCategory.health:
        return Icons.local_hospital;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.other:
        return Icons.category;
    }
  }

  Color get categoryColor {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.green;
      case ExpenseCategory.utilities:
        return Colors.brown;
      case ExpenseCategory.health:
        return Colors.red;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    ExpenseCategory? category,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}
