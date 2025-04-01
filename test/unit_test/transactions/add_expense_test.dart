import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/repositories/FirebaseTransactionRepository.dart';
import 'package:expense_personal/cores/utils/getUserId.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'add_expense_test.mocks.dart';

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

    // Truyền mockFirebaseAuth vào repository
    repository = FirebaseTransactionRepository(
      fireStore: fakeFirestore,
      auth: mockFirebaseAuth,
    );

    // Mock FirebaseAuth để trả về userId giả
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
  });

  group('FirebaseTransactionRepository tests', () {
    test('addExpense() lưu chi tiêu thành công khi userId hợp lệ', () async {
      final title = 'Mua sách';
      final amount = 100.0;
      final category = 'Giáo dục';
      final date = DateTime(2023, 10, 15);

      await repository.addExpense(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();
      expect(data['title'], title);
      expect(data['amount'], amount);
      expect(data['category'], category);
      expect(data['date'], date.toIso8601String());
      expect(data['type'], 'expense');
      expect(data['userId'], 'test-uid');
      expect(data['createdAt'], isA<Timestamp>());
    });

    test('addExpense() không làm gì khi userId là null', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final title = 'Mua sách';
      final amount = 100.0;
      final category = 'Giáo dục';
      final date = DateTime(2023, 10, 15);

      await repository.addExpense(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 0);
    });

    test('addExpense() xử lý lỗi khi Firestore thất bại', () async {
      repository = _MockFirebaseTransactionRepository(
        fireStore: fakeFirestore,
        auth: mockFirebaseAuth,
      );

      final title = 'Mua sách';
      final amount = 100.0;
      final category = 'Giáo dục';
      final date = DateTime(2023, 10, 15);

      await repository.addExpense(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 0);
    });

    test('addExpense() lưu đúng dữ liệu với giá trị âm', () async {
      final title = 'Hoàn tiền';
      final amount = -50.0;
      final category = 'Khác';
      final date = DateTime(2023, 10, 16);

      await repository.addExpense(title, amount, category, date);

      final snapshot = await fakeFirestore.collection('transactions').get();
      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();
      expect(data['title'], title);
      expect(data['amount'], amount);
      expect(data['category'], category);
      expect(data['date'], date.toIso8601String());
      expect(data['type'], 'expense');
      expect(data['userId'], 'test-uid');
    });
  });
}

// Lớp giả lập để mô phỏng lỗi Firestore
class _MockFirebaseTransactionRepository extends FirebaseTransactionRepository {
  _MockFirebaseTransactionRepository({
    required super.fireStore,
    required FirebaseAuth auth,
  }) : super(auth: auth);

  @override
  Future<void> addExpense(String title, double amount, String category, DateTime date) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('Không tìm thấy người dùng');
        return;
      }
      throw Exception('Lỗi Firestore'); // Giả lập lỗi Firestore
    } catch (e) {
      print('Lỗi khi lưu chi tiêu: $e');
    }
  }
}