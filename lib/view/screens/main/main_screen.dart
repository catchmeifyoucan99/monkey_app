import 'package:expense_personal/view/screens/main/add/add_screen.dart';
import 'package:expense_personal/view/screens/main/notification/notification_screen.dart';
import 'package:expense_personal/view/screens/main/saving/saving_screen.dart';
import 'package:expense_personal/view/screens/main/setting/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_personal/view/screens/main/overview/overview_screen.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OverviewScreen(),
    const SavingScreen(),
    const NotificationScreen(),
    const SettingScreen(),
    const AddScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 4;
          });
        },
        backgroundColor: Colors.teal,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              color: _currentIndex == 0 ? Colors.teal : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.savings),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              color: _currentIndex == 1 ? Colors.teal : Colors.grey,
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              color: _currentIndex == 2 ? Colors.teal : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
              color: _currentIndex == 3 ? Colors.teal : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
