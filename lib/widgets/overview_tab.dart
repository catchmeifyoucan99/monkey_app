import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverviewTab extends StatelessWidget {
  final TabController tabController;
  const OverviewTab({super.key, required this.tabController});

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
              Tab(text: 'Remind'),
              Tab(text: 'Budget'),
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
                _buildTabContent(_savingData, Colors.teal),
                _buildTabContent(_remindData, Colors.orange),
                _buildTabContent(_budgetData, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> transactions, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: transactions.isEmpty
          ? Center(child: Text('Chưa có dữ liệu', style: TextStyle(fontSize: 16, color: color)))
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          var transaction = transactions[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(transaction['type'] == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: transaction['type'] == 'income' ? Colors.green : Colors.red),
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
  }

  static final List<Map<String, dynamic>> _savingData = [
    {"description": "Tiết kiệm tháng 7", "amount": 2000000, "type": "income", "date": DateTime(2024, 7, 10)},
  ];

  static final List<Map<String, dynamic>> _remindData = [
    {"description": "Hóa đơn điện", "amount": 500000, "type": "expense", "date": DateTime(2024, 7, 5)},
  ];

  static final List<Map<String, dynamic>> _budgetData = [
    {"description": "Ngân sách ăn uống", "amount": 3000000, "type": "expense", "date": DateTime(2024, 7, 1)},
  ];
}
