import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../expenses/add_expense_screen.dart';
import '../expenses/expense_list_screen.dart';
import '../insights/insights_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Widget> _screens = [
    const ExpenseListScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: _screens[_selectedIndex],
      ),
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
        color: const Color(0xFF6A5AE0),
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
        index: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          Icon(
            Icons.list_alt_rounded, 
            color: _selectedIndex == 0 ? Colors.white : Colors.white70,
            size: 30,
          ),
          Icon(
            Icons.insights_rounded, 
            color: _selectedIndex == 1 ? Colors.white : Colors.white70,
            size: 30,
          ),
          Icon(
            Icons.person_rounded, 
            color: _selectedIndex == 2 ? Colors.white : Colors.white70,
            size: 30,
          ),
        ],
      ),
    );
  }
}
