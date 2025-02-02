import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng Quan Chi Tiêu'),
        backgroundColor: const Color(0xFF0E33F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng thu nhập, chi tiêu và số dư
            const Text(
              'Tổng quan tài chính',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOverviewCard(context, 'Tổng Thu Nhập', '10,000,000 VND', Colors.green),
                _buildOverviewCard(context, 'Tổng Chi Tiêu', '5,000,000 VND', Colors.red),
                _buildOverviewCard(context, 'Số Dư', '5,000,000 VND', Colors.blue),
              ],
            ),
            const SizedBox(height: 40),

            // Biểu đồ chi tiêu theo danh mục
            const Text(
              'Chi tiêu theo danh mục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildExpenseChart(),
            const SizedBox(height: 40),

            // Các giao dịch mới nhất
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  // Xây dựng card hiển thị tổng quan thu nhập, chi tiêu và số dư
  Widget _buildOverviewCard(BuildContext context, String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width * 0.28,  // Access context here
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng biểu đồ chi tiêu theo danh mục
  Widget _buildExpenseChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.green,
              title: 'Thực Phẩm\n40%',
              radius: 50,
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.blue,
              title: 'Giải Trí\n30%',
              radius: 50,
            ),
            PieChartSectionData(
              value: 20,
              color: Colors.red,
              title: 'Di Chuyển\n20%',
              radius: 50,
            ),
            PieChartSectionData(
              value: 10,
              color: Colors.orange,
              title: 'Khác\n10%',
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }

  // Xây dựng danh sách các giao dịch gần đây
  Widget _buildRecentTransactions() {
    return Column(
      children: [
        _buildTransactionCard('Mua sắm', '2,000,000 VND', '20/01/2025'),
        _buildTransactionCard('Ăn uống', '500,000 VND', '19/01/2025'),
        _buildTransactionCard('Taxi', '100,000 VND', '18/01/2025'),
      ],
    );
  }

  // Xây dựng card cho mỗi giao dịch
  Widget _buildTransactionCard(String title, String amount, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(Icons.money_off_outlined, color: Colors.blue),
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
