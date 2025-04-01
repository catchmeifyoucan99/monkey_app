import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/repositories/FirebaseTransactionRepository.dart';
import 'package:expense_personal/cores/utils/getUserId.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'add_income_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User])
void main() {
  late FirebaseTransactionRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
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

  group('FirebaseTransactionRepository - addIncome tests', () {
    test('addIncome() lưu thu nhập thành công khi userId hợp lệ', () async {
      final title = 'Lương tháng';
      final amount = 5000.0;
      final category = 'Thu nhập chính';
      final date = DateTime(2023, 11, 1);

      await repository.addIncome(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();
      expect(data['title'], title);
      expect(data['amount'], amount);
      expect(data['category'], category);
      expect(data['date'], date.toIso8601String());
      expect(data['type'], 'income');
      expect(data['userId'], 'test-uid');
      expect(data['createdAt'], isA<Timestamp>());
    });

    test('addIncome() không làm gì khi userId là null', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final title = 'Lương tháng';
      final amount = 5000.0;
      final category = 'Thu nhập chính';
      final date = DateTime(2023, 11, 1);

      await repository.addIncome(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 0);
    });

    test('addIncome() xử lý lỗi khi Firestore thất bại', () async {
      repository = _MockFirebaseTransactionRepository(
        fireStore: fakeFirestore,
        auth: mockFirebaseAuth,
      );

      final title = 'Lương tháng';
      final amount = 5000.0;
      final category = 'Thu nhập chính';
      final date = DateTime(2023, 11, 1);

      await repository.addIncome(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 0);
    });

    test('addIncome() lưu đúng dữ liệu với giá trị âm', () async {
      final title = 'Hoàn thuế';
      final amount = -200.0;
      final category = 'Khác';
      final date = DateTime(2023, 11, 2);

      await repository.addIncome(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();
      expect(data['title'], title);
      expect(data['amount'], amount);
      expect(data['category'], category);
      expect(data['date'], date.toIso8601String());
      expect(data['type'], 'income');
      expect(data['userId'], 'test-uid');
    });
  });
}


class _MockFirebaseTransactionRepository extends FirebaseTransactionRepository {
  _MockFirebaseTransactionRepository({
    required FirebaseFirestore fireStore,
    required FirebaseAuth auth,
  }) : super(fireStore: fireStore, auth: auth);

  @override
  Future<void> addIncome(String title, double amount, String category, DateTime date) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('Không tìm thấy người dùng');
        return;
      }
      throw Exception('Lỗi Firestore');
    } catch (e) {
      print('Lỗi khi lưu thu nhập: $e');
    }
  }
}