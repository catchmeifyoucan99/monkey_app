import 'package:intl/intl.dart';

String formatCurrency(int amount, {bool includeCurrency = true}) {
  String formatted = NumberFormat("#,##0").format(amount);
  return includeCurrency ? "$formatted VND" : formatted;
}

String formatDate(DateTime date){
  return DateFormat('dd/MM/yyyy').format(date);
}