import 'package:flutter/material.dart';

class TotalExpensesScreen extends StatelessWidget {
  const TotalExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Expenses'),
      ),
      body: const Center(
        child: Text(
          'Total Expenses Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}