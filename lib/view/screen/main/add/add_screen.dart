import 'package:flutter/material.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Giao Dịch'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn loại giao dịch:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Các nút bấm thêm thu nhập và chi tiêu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTransactionButton(
                  context,
                  'Thu Nhập',
                  Icons.add_circle_outline,
                  Colors.green,
                      () {
                    // Chuyển tới màn hình Thu Nhập
                  },
                ),
                _buildTransactionButton(
                  context,
                  'Chi Tiêu',
                  Icons.remove_circle_outline,
                  Colors.red,
                      () {
                    // Chuyển tới màn hình Chi Tiêu
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Giao Dịch Đã Thêm:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            // Danh sách giao dịch đã thêm
            _buildTransactionCard('Mua sắm', '2,000,000 VND', '20/01/2025', Icons.shopping_cart),
            _buildTransactionCard('Ăn uống', '500,000 VND', '19/01/2025', Icons.restaurant),
            _buildTransactionCard('Taxi', '100,000 VND', '18/01/2025', Icons.directions_car),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng button cho thu nhập và chi tiêu
  Widget _buildTransactionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // Hàm xây dựng card cho mỗi giao dịch
  Widget _buildTransactionCard(String title, String amount, String date, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
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
