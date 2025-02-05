import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tổng quan',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildOverviewCards(context),
            const SizedBox(height: 40),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
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
                  SizedBox(height: 40),
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
                  )
                  ,
                  SizedBox(
                    height: 388,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabContent(savingData, Colors.teal),
                        _buildTabContent(remindData, Colors.orange),
                        _buildTabContent(budgetData, Colors.purple),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFeaedf0),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          _buildOverviewCard(context, 'Tổng Thu Nhập', '5000000', Colors.black,
              Icons.account_balance_wallet),
          _buildOverviewCard(context, 'Tổng Chi Tiêu', '5000000', Colors.white,
              Icons.shopping_cart),
          _buildOverviewCard(
              context, 'Số Dư', '5000000', Colors.black, Icons.account_balance),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> savingData = [
    {"description": "Tiết kiệm tháng 7", "amount": 2000000, "type": "income", "date": DateTime(2024, 7, 10)},
    {"description": "Tiết kiệm tháng 6", "amount": 1500000, "type": "income", "date": DateTime(2024, 6, 10)},
    {"description": "Tiết kiệm tháng 6", "amount": 1500000, "type": "income", "date": DateTime(2024, 6, 10)},
    {"description": "Tiết kiệm tháng 6", "amount": 1500000, "type": "income", "date": DateTime(2024, 6, 10)},
    {"description": "Tiết kiệm tháng 6", "amount": 1500000, "type": "income", "date": DateTime(2024, 6, 10)},
  ];

  List<Map<String, dynamic>> remindData = [
    {"description": "Hóa đơn điện", "amount": 500000, "type": "expense", "date": DateTime(2024, 7, 5)},
    {"description": "Hóa đơn nước", "amount": 300000, "type": "expense", "date": DateTime(2024, 7, 6)},
  ];

  List<Map<String, dynamic>> budgetData = [
    {"description": "Ngân sách ăn uống", "amount": 3000000, "type": "expense", "date": DateTime(2024, 7, 1)},
    {"description": "Ngân sách du lịch", "amount": 5000000, "type": "expense", "date": DateTime(2024, 7, 2)},
  ];

  Widget _buildOverviewCard(BuildContext context, String title, String amount,
      Color textColor, IconData icon) {
    Color backgroundColor;
    if (textColor == Colors.black) {
      backgroundColor = Colors.white;
    } else {
      backgroundColor = Colors.teal;
    }

    String formattedAmount = NumberFormat("#,##0").format(int.parse(amount));

    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: formattedAmount,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    double textWidth = textPainter.size.width;

    double containerWidth = MediaQuery.of(context).size.width * 0.35;
    if (textWidth > containerWidth) {
      containerWidth = textWidth + 32.0;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: containerWidth,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$formattedAmount VND",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTabContent(List<Map<String, dynamic>> transactions, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: transactions.isEmpty
        ? Center(
      child: Text(
        'Chưa có dữ liệu',
        style: TextStyle(fontSize: 16, color: color),
      ),
    )
        : ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        var transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              transaction['type'] == 'income'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: transaction['type'] == 'income'
                  ? Colors.green
                  : Colors.red,
            ),
            title: Text(
              transaction['description'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(transaction['date']),
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Text(
              "${NumberFormat("#,##0").format(transaction['amount'])} VND",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: transaction['type'] == 'income'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        );
      },
    ),
  );
}
