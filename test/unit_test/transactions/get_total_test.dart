import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/repositories/FirebaseTransactionRepository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'get_total_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User])
void main() {
  late FirebaseTransactionRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    repository = FirebaseTransactionRepository(
      fireStore: fakeFirestore,
      auth: mockFirebaseAuth,
    );

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
  });

  group('FirebaseTransactionRepository - getTotal tests', () {
    // Hàm hỗ trợ để thêm dữ liệu mẫu
    Future<void> addSampleTransaction({
      required String userId,
      required String type,
      required double amount,
      required DateTime date,
    }) async {
      await fakeFirestore.collection('transactions').add({
        'userId': userId,
        'type': type,
        'amount': amount,
        'createdAt': Timestamp.fromDate(date),
        'title': 'Test',
        'category': 'Test',
        'date': date.toIso8601String(),
      });
    }

    test('getTotalIncome() trả về tổng thu nhập đúng trong tháng hiện tại', () async {
      final now = DateTime(2023, 10, 15);
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'income',
        amount: 1000.0,
        date: DateTime(2023, 10, 5),
      );
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'income',
        amount: 500.0,
        date: DateTime(2023, 10, 20),
      );

      // Truyền thời gian giả lập vào getTotalIncome
      final total = await repository.getTotalIncome('test-uid', now: now);
      expect(total, 1500); // 1000 + 500 = 1500
    });

    test('getTotalExpense() trả về tổng chi tiêu đúng trong tháng hiện tại', () async {
      final now = DateTime(2023, 10, 15);
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'expense',
        amount: 200.0,
        date: DateTime(2023, 10, 10),
      );
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'expense',
        amount: 300.0,
        date: DateTime(2023, 10, 25),
      );

      final total = await repository.getTotalExpense('test-uid', now: now);
      expect(total, 500);
    });

    test('getTotalIncome() trả về 0 khi không có thu nhập trong tháng', () async {
      final now = DateTime(2023, 10, 15);
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'income',
        amount: 1000.0,
        date: DateTime(2023, 9, 15)
      );

      final total = await repository.getTotalIncome('test-uid', now: now);
      expect(total, 0);
    });

    test('getTotalExpense() trả về 0 khi không có chi tiêu trong tháng', () async {
      final now = DateTime(2023, 10, 15);
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'expense',
        amount: 200.0,
        date: DateTime(2023, 11, 1),
      );

      final total = await repository.getTotalExpense('test-uid', now: now);
      expect(total, 0);
    });

    test('_getTotalAmount() xử lý đúng với giá trị âm và dương', () async {
      final now = DateTime(2023, 10, 15);
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'income',
        amount: -200.0,
        date: DateTime(2023, 10, 5),
      );
      await addSampleTransaction(
        userId: 'test-uid',
        type: 'income',
        amount: 500.0,
        date: DateTime(2023, 10, 20),
      );

      final total = await repository.getTotalIncome('test-uid', now: now);
      expect(total, 300); // -200 + 500 = 300
    });

    test('_getTotalAmount() trả về 0 khi không có giao dịch nào', () async {
      final now = DateTime(2023, 10, 15);
      final totalIncome = await repository.getTotalIncome('test-uid', now: now);
      final totalExpense = await repository.getTotalExpense('test-uid', now: now);
      expect(totalIncome, 0);
      expect(totalExpense, 0);
    });
  });
}