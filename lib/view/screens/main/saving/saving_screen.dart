import 'package:expense_personal/cores/model/saving.dart';
import 'package:expense_personal/cores/services/saving_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavingScreen extends StatefulWidget {
  const SavingScreen({super.key});

  @override
  _SavingScreenState createState() => _SavingScreenState();
}

class _SavingScreenState extends State<SavingScreen> {
  final SavingService savingService = SavingService();
  final NumberFormat currencyFormat = NumberFormat("#,###");

  String _savingCategory = 'Income';

  void _showAddSavingDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm khoản tiết kiệm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên khoản tiết kiệm'),
              ),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(labelText: 'Mục tiêu (VND)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _savingCategory,
                decoration: const InputDecoration(labelText: 'Loại'),
                items: ['Income', 'Expense'].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _savingCategory = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                String savingName = nameController.text.trim();
                double? targetAmount = double.tryParse(targetController.text.replaceAll(',', ''));

                if (savingName.isEmpty || targetAmount == null || targetAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên và mục tiêu hợp lệ')),
                  );
                  return;
                }

                savingService.addSaving(
                  Saving(
                    id: '',
                    name: savingName,
                    targetAmount: targetAmount,
                    currentAmount: 0.0,
                    category: _savingCategory,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(Saving saving) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa khoản tiết kiệm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              savingService.deleteSaving(saving.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tiết kiệm',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: () => _showAddSavingDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Saving>>(
        stream: savingService.getSavings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          List<Saving> savings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: savings.length,
            itemBuilder: (context, index) {
              final saving = savings[index];
              double progress = (saving.currentAmount / saving.targetAmount).clamp(0.0, 1.0);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    saving.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mục tiêu: ${currencyFormat.format(saving.targetAmount)} VND',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Đã tiết kiệm: ${currencyFormat.format(saving.currentAmount)} VND',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(saving),
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFeaedf0),
    );
  }
}
