import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/interfaces/TransactionRepository.dart';
import '../../../../cores/utils/getUserId.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore firestore;

  FirebaseTransactionRepository({required this.firestore});

  @override
  Future<void> addExpense(String title, double amount, String category, DateTime date) async {
    try {
      String? userId = getCurrentUserId();

      if (userId == null) {
        print('Không tìm thấy người dùng');
        return;
      }

      await firestore.collection('transactions').add({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'type': 'expense',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });
      print('Chi tiêu đã được lưu!');
    } catch (e) {
      print('Lỗi khi lưu chi tiêu: $e');
    }
  }

  @override
  Future<void> addIncome(String title, double amount, String category, DateTime date) async {
    try {
      String? userId = getCurrentUserId();

      if (userId == null) {
        print('Không tìm thấy người dùng');
        return;
      }

      await firestore.collection('transactions').add({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'type': 'income',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });
      print('Thu nhập đã được lưu!');
    } catch (e) {
      print('Lỗi khi lưu thu nhập: $e');
    }
  }
}
