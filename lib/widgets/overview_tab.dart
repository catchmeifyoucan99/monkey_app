import 'package:expense_personal/cores/utils/getUserId.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OverviewTab extends StatelessWidget {
  final TabController tabController;

  OverviewTab({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Saving'),
              Tab(text: 'Income'),
              Tab(text: 'Expense'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.teal,
            ),
            indicatorColor: Colors.transparent,
            indicatorWeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            isScrollable: false,
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Các mục nhập mới nhất",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFB0B8BF), width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, size: 18),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // Xử lý khi bấm vào icon
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 410,
            child: TabBarView(
              controller: tabController,
              children: [
                _buildTabContent('saving', Colors.blue),
                _buildTabContent('income', Colors.green),
                _buildTabContent('expense', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String type, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTransactionsStream(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Chưa có dữ liệu', style: TextStyle(fontSize: 16, color: color)));
        }

        final transactions = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'description': data['title'] ?? "Không có tiêu đề",
            'amount': data['amount'] ?? 0,
            'type': data['type'] ?? "Không rõ loại",
            'date': DateTime.parse(data['date'] ?? DateTime.now().toString()),
          };
        }).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 1,
                color: const Color(0xFFF6F6F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    transaction['type'] == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: transaction['type'] == 'income' ? Colors.green : Colors.red,
                  ),
                  title: Text(transaction['description'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction['date']), style: const TextStyle(color: Colors.grey)),
                  trailing: Text(
                    "${NumberFormat("#,##0").format(transaction['amount'])} VND",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: transaction['type'] == 'income' ? Colors.green : Colors.red),
                  ),
                ),
              );
            },
          ),
        );

      },
    );
  }

  String? userId = getCurrentUserId();

  Stream<QuerySnapshot> _getTransactionsStream(String type) {
    final startOfDay = DateTime.now().subtract(Duration(days: 30));
    final endOfDay = DateTime.now();

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots();
  }

}
