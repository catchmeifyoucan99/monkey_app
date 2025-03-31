import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/cores/providers/currency_provider.dart';
import 'package:expense_personal/cores/utils/format_utils.dart';

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
  bool _isLoadingRates = false;

  // Danh sách các mệnh giá để test quy đổi (VND)
  final List<double> _testAmounts = [
    10000, 25000, 50000, 100000, 200000, 500000, 1000000, 2000000
  ];

  @override
  void initState() {
    super.initState();
    _initializeCurrencyData();
  }

  Future<void> _initializeCurrencyData() async {
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    if (currencyProvider.rates == null) {
      setState(() => _isLoadingRates = true);
      await currencyProvider.initialize();
      setState(() => _isLoadingRates = false);
    }
  }

  Future<void> _refreshExchangeRates() async {
    setState(() => _isLoadingRates = true);
    await Provider.of<CurrencyProvider>(context, listen: false).initialize();
    setState(() => _isLoadingRates = false);
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingRates ? null : _refreshExchangeRates,
            tooltip: 'Làm mới tỷ giá',
          ),
        ],
      ),
      body: _isLoadingRates
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(currencyProvider),
    );
  }

  Widget _buildContent(CurrencyProvider currencyProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingItem(
            title: 'Thông báo',
            subtitle: 'Bật/tắt thông báo',
            trailing: Switch(
              value: _isNotificationEnabled,
              onChanged: (value) => setState(() => _isNotificationEnabled = value),
            ),
          ),
          const Divider(),

          _buildSettingItem(
            title: 'Chế độ tối',
            subtitle: 'Bật chế độ tối để bảo vệ mắt',
            trailing: Switch(
              value: _isDarkModeEnabled,
              onChanged: (value) => setState(() => _isDarkModeEnabled = value),
            ),
          ),
          const Divider(),

          _buildSettingItem(
            title: 'Ngôn ngữ',
            subtitle: 'Chọn ngôn ngữ hiển thị',
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (value) => setState(() => _selectedLanguage = value!),
              items: _languages.map((language) => DropdownMenuItem(
                value: language,
                child: Text(language),
              )).toList(),
            ),
          ),
          const Divider(),

          _buildSettingItem(
            title: 'Tiền tệ',
            subtitle: 'Chọn loại tiền tệ hiển thị',
            trailing: DropdownButton<String>(
              value: currencyProvider.currency,
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _isLoadingRates = true);
                  await currencyProvider.setCurrency(value);
                  setState(() => _isLoadingRates = false);
                }
              },
              items: _currencies.map((currency) => DropdownMenuItem(
                value: currency,
                child: Text(currency),
              )).toList(),
            ),
          ),
          const Divider(),

          _buildConversionTestSection(currencyProvider),
          const Divider(),

          _buildSettingItem(
            title: 'Thông tin ứng dụng',
            subtitle: 'Phiên bản 1.0.0',
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showAppInfoDialog(context),
          ),
          const Divider(),

          Center(
            child: ElevatedButton(
              onPressed: () {/* Handle logout */},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionTestSection(CurrencyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KIỂM TRA CHUYỂN ĐỔI TIỀN TỆ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        Text(
          'Tỷ giá hiện tại: 1 VND = ${provider.exchangeRate.toStringAsFixed(6)} ${provider.currency}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 15),

        ..._testAmounts.map((amount) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatCurrency(amount, 'VND')),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              Text(
                formatCurrency(provider.convert(amount), provider.currency),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tên ứng dụng: Expense Personal'),
            Text('Phiên bản: 1.0.0'),
            Text('Nhà phát triển: Your Company'),
            Text('Email hỗ trợ: support@yourcompany.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
