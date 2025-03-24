import 'package:intl/intl.dart';

String formatCurrencyV1(String value) {
  try {
    double number = double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;

    final formatter = NumberFormat('#,##0', 'en_US');

    return "${formatter.format(number)} VNĐ";
  } catch (e) {
    return "0đ";
  }
}

String formatCurrencyV2(String value) {
  try {
    double number = double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;

    final formatter = NumberFormat('#,##0', 'en_US');

    String formattedNumber = formatter.format(number);

    return "${number > 0 ? '+' : ''}$formattedNumber VNĐ";
  } catch (e) {
    return "0đ";
  }
}

String formatDateV1(DateTime date){
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDateV2(DateTime date) {
  List<String> months = [
    "Thg1", "Thg2", "Thg3", "Thg4", "Thg5", "Thg6",
    "Thg7", "Thg8", "Thg9", "Thg10", "Thg11", "Thg12"
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatCurrency(double amount, String currencyCode) {
  final format = NumberFormat.currency(
    locale: _getLocale(currencyCode),
    symbol: _getSymbol(currencyCode),
    decimalDigits: currencyCode == 'VND' ? 0 : 2,
  );
  return format.format(amount);
}

String _getLocale(String currencyCode) {
  switch (currencyCode) {
    case 'VND':
      return 'vi_VN';
    case 'USD':
      return 'en_US';
    case 'EUR':
      return 'de_DE';
    case 'GBP':
      return 'en_GB';
    case 'JPY':
      return 'ja_JP';
    default:
      return 'en_US';
  }
}

String _getSymbol(String currencyCode) {
  switch (currencyCode) {
    case 'VND':
      return '₫';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
      return '¥';
    default:
      return '\$';
  }
}