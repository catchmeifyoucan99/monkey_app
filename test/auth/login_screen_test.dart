import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:expense_personal/view/screens/account/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('Hiển thị logo và tiêu đề', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('monkey'), findsOneWidget);
  });

  testWidgets('Nhập email và mật khẩu', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });

  testWidgets('Đăng nhập thành công', (WidgetTester tester) async {
    when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    verify(mockAuthProvider.login('test@example.com', 'password123')).called(1);
  });

  testWidgets('Hiển thị lỗi khi đăng nhập thất bại', (WidgetTester tester) async {
    when(mockAuthProvider.login(any, any)).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Sai tài khoản hoặc mật khẩu!'), findsOneWidget);
  });
}
