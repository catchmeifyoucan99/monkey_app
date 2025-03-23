import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _apiKey = 'YOUR_API_KEY'; // Thay thế bằng API Key của bạn
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6/$_apiKey';

  // Hàm lấy tỷ giá hối đoái
  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    final url = '$_baseUrl/latest/$baseCurrency';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  // Hàm chuyển đổi tiền tệ
  double convertCurrency(double amount, double exchangeRate) {
    return amount * exchangeRate;
  }
}