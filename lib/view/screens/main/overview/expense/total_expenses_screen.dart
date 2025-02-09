import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TotalExpensesScreen extends StatelessWidget {
  const TotalExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Expenses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/overView');
          },
        ),
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
