import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/interfaces/TransactionRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../cores/utils/getUserId.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth _auth;

  FirebaseTransactionRepository({
    required this.fireStore,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> addExpense(String title, double amount, String category, DateTime date) async {
    try {
      String? userId = getCurrentUserId(auth: _auth);

      if (userId == null) {
        print('Không tìm thấy người dùng');
        return;
      }

      await fireStore.collection('transactions').add({
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
      String? userId = getCurrentUserId(auth: _auth);
      if (userId == null) {
        print('Không tìm thấy người dùng');
        return;
      }

      await fireStore.collection('transactions').add({
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

  @override
  Future<int> getTotalIncome(String userId) async {
    return _getTotalAmount(userId, 'income');
  }

  @override
  Future<int> getTotalExpense(String userId) async {
    return _getTotalAmount(userId, 'expense');
  }

  Future<int> _getTotalAmount(String userId, String type) async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    QuerySnapshot query = await fireStore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    int total = 0;

    for (var doc in query.docs) {
      total += (doc['amount'] as num).toInt();
    }

    return total;
  }
}
