import 'package:intl/intl.dart';

String formatCurrency(dynamic amount, {bool includeCurrency = true}) {
  String cleanedAmount = amount is String ? amount.replaceAll(RegExp(r'[^0-9]'), '') : amount.toString();
  int parsedAmount = int.parse(cleanedAmount);
  String formatted = NumberFormat("#,##0").format(parsedAmount);
  return includeCurrency ? "$formatted VND" : formatted;
}

String formatDate(DateTime date){
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDate1(DateTime date) {
  return DateFormat('d MMM y', 'vi').format(date);
}