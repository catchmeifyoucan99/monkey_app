
import 'package:expense_personal/view/screens/main/add/add_expense.dart';
import 'package:expense_personal/widgets/animated_add_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_expense_test.mocks.dart';



@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, User])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
  });

  testWidgets('Hiển thị tiêu đề màn hình', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));
    expect(find.text('Thêm Chi Tiêu'), findsOneWidget);
  });

  testWidgets('Kiểm tra thông báo lỗi khi nhập thiếu thông tin', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));

    await tester.tap(find.text('Lưu Giao Dịch'));
    await tester.pump();

    expect(find.text('Vui lòng điền đầy đủ thông tin'), findsOneWidget);
  });

  testWidgets('Nhập dữ liệu hợp lệ và lưu giao dịch', (WidgetTester tester) async {
    when(mockFirestore.collection('transactions')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

    await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'Mua sắm');
    await tester.enterText(find.byType(TextField).at(1), '50000');

    await tester.tap(find.byType(AnimatedAddButton));
    await tester.pump();

    await tester.tap(find.text('Lưu Giao Dịch'));
    await tester.pump();

    expect(find.text('Lưu thu nhập thành công'), findsOneWidget);
  });

  // test('Kiểm tra gọi hàm addExpense thành công', () async {
  //   when(mockFirestore.collection('transactions')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
  //   when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);
  //
  //   await addExpense('Ăn uống', 100000, 'Ăn uống', DateTime.now());
  //   verify(mockCollection.add(any)).called(1);
  // });

  testWidgets('Cập nhật danh mục khi chọn', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));

    await tester.tap(find.byType(AnimatedAddButton));
    await tester.pump();
    expect(find.text('Danh mục đã chọn'), findsOneWidget);
  });

  testWidgets('handleSaveTransaction với dữ liệu không hợp lệ', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));

    await tester.tap(find.text('Lưu Giao Dịch'));
    await tester.pump();

    expect(find.text('Vui lòng điền đầy đủ thông tin'), findsOneWidget);
  });

  testWidgets('handleSaveTransaction với dữ liệu hợp lệ', (WidgetTester tester) async {
    when(mockFirestore.collection('transactions')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

    await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'Hóa đơn điện');
    await tester.enterText(find.byType(TextField).at(1), '200000');
    await tester.tap(find.byType(AnimatedAddButton));
    await tester.pump();

    await tester.tap(find.text('Lưu Giao Dịch'));
    await tester.pump();

    expect(find.text('Lưu thu nhập thành công'), findsOneWidget);
  });
}
