import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tổng Quan Chi Tiêu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildOverviewCards(context),
            const SizedBox(height: 40),

            // Biểu đồ chi tiêu theo danh mục
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

            // Các giao dịch mới nhất
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
    );
  }

  // Xây dựng card hiển thị tổng quan thu nhập, chi tiêu và số dư
  Widget _buildOverviewCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOverviewCard(context, 'Tổng Thu Nhập', '10,000,000 VND', Colors.green),
        _buildOverviewCard(context, 'Tổng Chi Tiêu', '5,000,000 VND', Colors.red),
        _buildOverviewCard(context, 'Số Dư', '5,000,000 VND', Colors.blue),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width * 0.28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 6),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng biểu đồ chi tiêu theo danh mục
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

  // Xây dựng danh sách các giao dịch gần đây
  Widget _buildRecentTransactions() {
    return Column(
      children: [
        _buildTransactionCard('Mua sắm', '2,000,000 VND', '20/01/2025', Icons.shopping_cart),
        _buildTransactionCard('Ăn uống', '500,000 VND', '19/01/2025', Icons.restaurant),
        _buildTransactionCard('Taxi', '100,000 VND', '18/01/2025', Icons.directions_car),
      ],
    );
  }

  // Xây dựng card cho mỗi giao dịch
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
