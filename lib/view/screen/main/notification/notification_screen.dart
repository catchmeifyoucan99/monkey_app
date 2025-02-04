import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả lập danh sách các thông báo
    final List<Map<String, String>> notifications = [
      {'title': 'Thông báo 1', 'message': 'Đây là thông báo đầu tiên của bạn!'},
      {'title': 'Thông báo 2', 'message': 'Bạn có một tin nhắn mới.'},
      {'title': 'Thông báo 3', 'message': 'Cập nhật phần mềm mới sẵn sàng.'},
      {'title': 'Thông báo 4', 'message': 'Nhớ kiểm tra tài khoản của bạn.'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return InkWell(
              onTap: () {
                // Hiển thị chi tiết thông báo khi người dùng nhấn vào
                _showNotificationDetails(context, notification);
              },
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.teal, size: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['message']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showNotificationDetails(BuildContext context, Map<String, String> notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(notification['message']!, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }
}
