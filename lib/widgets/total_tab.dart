import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalTab extends StatelessWidget {
  final TabController tabController;
  final List<Map<String, dynamic>> spendsData;
  final List<Map<String, dynamic>> categoriesData;

  const TotalTab({
    super.key,
    required this.tabController,
    required this.spendsData,
    required this.categoriesData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 27.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF5F6F7), width: 0.2),
              ),
            ),
            child: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Spends'),
                Tab(text: 'Categories'),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Color(0xFFB0B8BF),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: Colors.teal),
                insets: EdgeInsets.symmetric(horizontal: 119),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildTabContent(spendsData, Colors.teal),
                _buildTabContent(categoriesData, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> transactions, Color color) {
    final numberFormat = NumberFormat("#,##0");
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(8),
      child: transactions.isEmpty
          ? Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          var transaction = transactions[index];

          IconData transactionIcon = transaction['type'] == 'income'
              ? Icons.arrow_downward
              : Icons.arrow_upward;
          Color transactionColor = transaction['type'] == 'income'
              ? Colors.green
              : Colors.red;

          String formattedAmount = numberFormat.format(transaction['amount'] ?? 0);
          String formattedDate = dateFormat.format(transaction['date'] ?? DateTime.now());

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Color(0xFFF6F6F6),
            child: ListTile(
              leading: Icon(transactionIcon, color: transactionColor),
              title: Text(
                transaction['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              trailing: Text(
                "$formattedAmount VND",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: transactionColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }


}
