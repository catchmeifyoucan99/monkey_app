import 'package:expense_personal/model/saving.dart';
import 'package:flutter/material.dart';
import 'saving_list.dart';

class SavingScreen extends StatefulWidget {
  const SavingScreen({super.key});

  @override
  _SavingScreenState createState() => _SavingScreenState();
}

class _SavingScreenState extends State<SavingScreen> {
  List<Saving> savings = [
    Saving(name: 'Mua xe', targetAmount: 100000000, currentAmount: 20000000, category: 'Income'),
    Saving(name: 'Du lịch', targetAmount: 50000000, currentAmount: 10000000, category: 'Expense'),
    Saving(name: 'Mua nhà', targetAmount: 500000000, currentAmount: 100000000, category: 'Income'),
  ];

  void _showAddSavingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String savingName = '';
        double targetAmount = 0.0;
        String savingCategory = 'Income';
        return AlertDialog(
          title: const Text('Thêm khoản tiết kiệm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Tên khoản tiết kiệm'),
                onChanged: (value) {
                  savingName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Mục tiêu (VND)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  targetAmount = double.tryParse(value) ?? 0.0;
                },
              ),
              DropdownButton<String>(
                value: savingCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    savingCategory = newValue!;
                  });
                },
                items: <String>['Income', 'Expense']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (savingName.isNotEmpty && targetAmount > 0) {
                  setState(() {
                    savings.add(Saving(
                      name: savingName,
                      targetAmount: targetAmount,
                      currentAmount: 0.0,
                      category: savingCategory,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiết kiệm'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSavingDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách tiết kiệm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SavingList(savings: savings), // Truyền savings vào SavingList
          ],
        ),
      ),
    );
  }
}
