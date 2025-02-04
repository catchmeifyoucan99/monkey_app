import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

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
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildOverviewCards(context),
            const SizedBox(height: 40),

            const Text(
              'Chi tiêu theo danh mục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildExpenseChart(),
            const SizedBox(height: 40),

            const Text(
              'Giao dịch gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildRecentTransactions(),
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
          _buildOverviewCard(context, 'Tổng Thu Nhập', '5000000', Colors.black, Icons.account_balance_wallet),
          _buildOverviewCard(context, 'Tổng Chi Tiêu', '5000000', Colors.white, Icons.shopping_cart),
          _buildOverviewCard(context, 'Số Dư', '5000000', Colors.black, Icons.account_balance),
        ],
      ),
    );
  }
  Widget _buildOverviewCard(BuildContext context, String title, String amount, Color textColor, IconData icon) {
    Color backgroundColor;
    if (textColor == Colors.black) {
      backgroundColor = Colors.white;
    } else {
      backgroundColor = Colors.teal;
    }

    // Dùng NumberFormat để định dạng số tiền với dấu phẩy
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
            // Column cho icon và title
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
            // Sử dụng Expanded để Text có thể tự điều chỉnh
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
                    overflow: TextOverflow.ellipsis, // Nếu số tiền quá dài, sẽ ẩn bớt
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildExpenseChart() {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.green,
              title: 'Thực Phẩm\n40%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.teal,
              title: 'Giải Trí\n30%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 20,
              color: Colors.red,
              title: 'Di Chuyển\n20%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 10,
              color: Colors.orange,
              title: 'Khác\n10%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          centerSpaceRadius: 50,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      children: [
        _buildTransactionCard('Mua sắm', '2,000,000 VND', '20/01/2025', Icons.shopping_cart),
        _buildTransactionCard('Ăn uống', '500,000 VND', '19/01/2025', Icons.restaurant),
        _buildTransactionCard('Taxi', '100,000 VND', '18/01/2025', Icons.directions_car),
      ],
    );
  }

  Widget _buildTransactionCard(String title, String amount, String date, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
