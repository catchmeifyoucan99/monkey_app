import 'package:intl/intl.dart';

String formatCurrency(int amount){
  return "${NumberFormat("#,##0").format(amount)} VND";
}

String formatDate(DateTime date){
  return DateFormat('dd/MM/yyyy').format(date);
}