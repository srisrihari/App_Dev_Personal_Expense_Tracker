import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_list_screen.dart';
import '../insights/insights_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ExpenseListScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = const [
    'Expenses',
    'Insights',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF6A5AE0),
            child: const Icon(Icons.add),
          )
        : null,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).primaryColor,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        height: 60,
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          Icon(Icons.list_alt_rounded, color: Colors.white),
          Icon(Icons.insights_rounded, color: Colors.white),
          Icon(Icons.person_rounded, color: Colors.white),
        ],
      ),
    );
  }
}
