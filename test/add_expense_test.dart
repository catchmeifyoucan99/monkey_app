import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/view/screens/main/add/add_expense.dart';
import 'package:expense_personal/widgets/animated_add_button.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Thiết lập Firebase mock trước khi khởi tạo Firebase
    await Firebase.initializeApp();

    // Khởi tạo Firestore giả lập
    fakeFirestore = FakeFirebaseFirestore();
  });

  testWidgets('Kiểm tra lưu giao dịch thành công', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddExpenseScreen(),
      ),
    );

    // Nhập tiêu đề giao dịch
    await tester.enterText(find.byType(TextField).at(0), 'Mua sách');

    // Nhập số tiền
    await tester.enterText(find.byType(TextField).at(1), '50000');

    // Chờ giao diện cập nhật
    await tester.pumpAndSettle();

    // Đảm bảo nút AnimatedAddButton có thể nhấn
    await tester.ensureVisible(find.byType(AnimatedAddButton));
    await tester.tap(find.byType(AnimatedAddButton));
    await tester.pump();

    // Nhấn nút "Lưu Giao Dịch"
    await tester.tap(find.text('Lưu Giao Dịch'));
    await tester.pump();

    // Kiểm tra dữ liệu có được lưu vào Firestore giả lập không
    final snapshot = await fakeFirestore.collection('transactions').get();
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.data()['title'], 'Mua sách');
    expect(snapshot.docs.first.data()['amount'], -50000);
    expect(snapshot.docs.first.data()['category'], 'Giáo dục');
  });

  testWidgets('Kiểm tra lỗi khi nhập số tiền không hợp lệ', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddExpenseScreen(),
      ),
    );

    // Nhập tiêu đề giao dịch
    await tester.enterText(find.byType(TextField).at(0), 'Mua sách');

    // Nhập số tiền không hợp lệ
    await tester.enterText(find.byType(TextField).at(1), 'abc');

    // Nhấn nút "Lưu Giao Dịch"
    await tester.tap(find.text('Lưu Giao Dịch'));
    await tester.pump();

    // Kiểm tra nếu có hiển thị thông báo lỗi
    expect(find.text('Số tiền không hợp lệ'), findsOneWidget);
  });
}
