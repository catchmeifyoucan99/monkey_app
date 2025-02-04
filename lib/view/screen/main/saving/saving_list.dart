import 'package:expense_personal/model/saving.dart';
import 'package:flutter/material.dart';

class SavingList extends StatelessWidget {
  final List<Saving> savings; // Nhận danh sách tiết kiệm từ SavingScreen

  const SavingList({super.key, required this.savings}); // Constructor nhận danh sách

  void _showSavingDetails(BuildContext context, Saving saving) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(saving.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mục tiêu: ${saving.targetAmount.toStringAsFixed(0)} VND',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Hiện tại: ${saving.currentAmount.toStringAsFixed(0)} VND',
                style: TextStyle(color: Colors.green[700]),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: saving.currentAmount / saving.targetAmount,
                backgroundColor: Colors.grey[300],
                color: Colors.teal,
                minHeight: 6,
              ),
              const SizedBox(height: 16),
              const Text('Lịch sử giao dịch:', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: savings.length,
        itemBuilder: (context, index) {
          final saving = savings[index];
          double progress = saving.currentAmount / saving.targetAmount;
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.teal[300],
                child: const Icon(Icons.savings, color: Colors.white),
              ),
              title: Text(
                saving.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mục tiêu: ${saving.targetAmount.toStringAsFixed(0)} VND'),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.teal,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '${saving.currentAmount.toStringAsFixed(0)} VND',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              onTap: () => _showSavingDetails(context, saving),
            ),
          );
        },
      ),
    );
  }
}
