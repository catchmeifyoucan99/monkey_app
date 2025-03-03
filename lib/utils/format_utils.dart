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