import 'package:flutter/material.dart';

class ExpenseCategory {
  static const String food = 'food';
  static const String transportation = 'transportation';
  static const String entertainment = 'entertainment';
  static const String shopping = 'shopping';
  static const String utilities = 'utilities';
  static const String health = 'health';
  static const String education = 'education';
  static const String other = 'other';

  static List<String> values = [
    food,
    transportation,
    entertainment,
    shopping,
    utilities,
    health,
    education,
    other,
  ];

  static Color getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case food:
        return Colors.orange;
      case transportation:
        return Colors.blue;
      case entertainment:
        return Colors.purple;
      case shopping:
        return Colors.pink;
      case utilities:
        return Colors.teal;
      case health:
        return Colors.red;
      case education:
        return Colors.indigo;
      case other:
      default:
        return Colors.grey;
    }
  }

  static IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case food:
        return Icons.restaurant;
      case transportation:
        return Icons.directions_car;
      case entertainment:
        return Icons.movie;
      case shopping:
        return Icons.shopping_bag;
      case utilities:
        return Icons.build;
      case health:
        return Icons.health_and_safety;
      case education:
        return Icons.school;
      case other:
      default:
        return Icons.category;
    }
  }

  static String getDisplayName(String category) {
    switch (category.toLowerCase()) {
      case food:
        return 'Food';
      case transportation:
        return 'Transportation';
      case entertainment:
        return 'Entertainment';
      case shopping:
        return 'Shopping';
      case utilities:
        return 'Utilities';
      case health:
        return 'Health';
      case education:
        return 'Education';
      case other:
      default:
        return 'Other';
    }
  }
}

class Expense {
  final String? id;
  final String title;  // Maps to description in backend
  final double amount;
  final String category;
  final DateTime date;
  final String? userId;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.userId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          debugPrint('Error parsing date: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    String parseCategory(dynamic value) {
      if (value == null) return ExpenseCategory.other;
      final category = value.toString();
      if (ExpenseCategory.values.contains(category)) {
        return category;
      }
      debugPrint('Invalid category: $category, defaulting to other');
      return ExpenseCategory.other;
    }

    return Expense(
      id: json['id']?.toString(),
      title: json['description'] ?? json['title'] ?? 'Untitled Expense',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : ((json['amount'] as num?)?.toDouble() ?? 0.0),
      category: parseCategory(json['category']),
      date: parseDate(json['date']),
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'description': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      if (userId != null) 'user_id': userId,
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? userId,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $category, date: $date, userId: $userId)';
  }

  Color get categoryColor => ExpenseCategory.getColorForCategory(category);
  IconData get categoryIcon => ExpenseCategory.getIconForCategory(category);
  String get categoryDisplayName => ExpenseCategory.getDisplayName(category);
}
