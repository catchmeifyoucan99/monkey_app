import 'package:expense_personal/cores/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../cores/utils/format_utils.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isNotificationEnabled = true;
  bool _isDarkModeEnabled = false;
  String _selectedLanguage = 'Tiếng Việt';

  final List<String> _languages = ['Tiếng Việt', 'English', '中文', 'Español'];
  final List<String> _currencies = ['VND', 'USD', 'EUR', 'GBP', 'JPY'];

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cài đặt thông báo
            _buildSettingItem(
              title: 'Thông báo',
              subtitle: 'Bật/tắt thông báo',
              trailing: Switch(
                value: _isNotificationEnabled,
                onChanged: (value) {
                  setState(() {
                    _isNotificationEnabled = value;
                  });
                },
              ),
            ),
            const Divider(),

            // Cài đặt chủ đề (sáng/tối)
            _buildSettingItem(
              title: 'Chế độ tối',
              subtitle: 'Bật chế độ tối để bảo vệ mắt',
              trailing: Switch(
                value: _isDarkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _isDarkModeEnabled = value;
                  });
                },
              ),
            ),
            const Divider(),

            // Cài đặt ngôn ngữ
            _buildSettingItem(
              title: 'Ngôn ngữ',
              subtitle: 'Chọn ngôn ngữ hiển thị',
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
                items: _languages.map((language) {
                  return DropdownMenuItem(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
              ),
            ),
            const Divider(),

            // Cài đặt tiền tệ
            _buildSettingItem(
              title: 'Tiền tệ',
              subtitle: 'Chọn loại tiền tệ hiển thị',
              trailing: DropdownButton<String>(
                value: currencyProvider.currency,
                onChanged: (value) {
                  setState(() {
                    currencyProvider.setCurrency(value!);
                  });
                },
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
              ),
            ),
            const Divider(),

            // Hiển thị ví dụ định dạng tiền tệ
            Center(
              child: Text(
                'Ví dụ: ${formatCurrency(1234567.89, currencyProvider.currency)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),

            // Thông tin ứng dụng
            _buildSettingItem(
              title: 'Thông tin ứng dụng',
              subtitle: 'Phiên bản 1.0.0',
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                _showAppInfoDialog(context);
              },
            ),
            const Divider(),

            // Nút đăng xuất (ví dụ)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý đăng xuất
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget để tạo một mục cài đặt
  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // Hiển thị hộp thoại thông tin ứng dụng
  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thông tin ứng dụng'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tên ứng dụng: Expense Personal'),
              Text('Phiên bản: 1.0.0'),
              Text('Nhà phát triển: Your Company'),
              Text('Email hỗ trợ: support@yourcompany.com'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}