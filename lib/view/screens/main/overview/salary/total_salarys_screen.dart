import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TotalSalarysScreen extends StatelessWidget {
  const TotalSalarysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Salary'),
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
