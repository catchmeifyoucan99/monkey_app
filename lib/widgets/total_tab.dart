import 'package:expense_personal/widgets/transaction_gauge_chart.dart';
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

  Widget _buildTabContent(List<Map<String, dynamic>> data, Color color) {
    // Nếu là tab Categories (màu cam) thì hiển thị khác
    if (color == Colors.orange) {
      return _buildCategoryView(data);
    }

    // Còn lại là tab Spends (màu xanh)
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.all(8),
      child: data.isEmpty
          ? Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var transaction = data[index];
          print('[TAB DEBUG] Displaying: ${transaction['title']} | ${transaction['displayAmount']}');

          IconData transactionIcon = transaction['type'] == 'income'
              ? Icons.arrow_downward
              : Icons.arrow_upward;
          Color transactionColor = transaction['type'] == 'income'
              ? Colors.green
              : Colors.red;

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
                transaction['displayAmount'] ?? '',
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

  Widget _buildCategoryView(List<Map<String, dynamic>> categories) {
    if (categories.isEmpty) {
      return _buildEmptyState('Không có dữ liệu danh mục');
    }

    return Column(
      children: [
        // Biểu đồ
        ExpenseBarChart(
          categoryData: {
            for (final cat in categories) cat['category']: cat['amount'],
          },
          positiveColor: Colors.teal,
          negativeColor: Colors.redAccent,
        ),

        // Danh sách categories
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade100,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isPositive = (category['amount'] as num) >= 0;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.teal.withOpacity(0.2)
                        : Colors.redAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.teal : Colors.redAccent,
                    size: 18,
                  ),
                ),
                title: Text(
                  category['category'] ?? 'Không xác định',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: Text(
                  category['displayAmount'] ?? '0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.teal : Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildCategoryItem(String category, String amount, int index) {
    final colors = [
      Colors.teal,
      Colors.teal.shade300,
      Colors.teal.shade200,
      Colors.teal.shade100,
    ];

    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        category,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        amount,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_chart_outlined,
              size: 48,
              color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }



}
