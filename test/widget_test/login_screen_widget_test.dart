import 'package:expense_personal/view/screens/account/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../widget_test/login_screen_widget_test.mocks.dart';


@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen Tests', () {

    testWidgets('Hiển thị các trường và nút đăng nhập', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Quên mật khẩu'), findsOneWidget);
      expect(find.text('Chưa có tài khoản? Đăng ký'), findsOneWidget);
    });

    testWidgets('Đăng nhập thành công', (WidgetTester tester) async {
      when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(mockAuthProvider.login('test@example.com', '123456')).called(1);
    });

    testWidgets('Hiển thị logo và tiêu đề', (WidgetTester tester) async {
      when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('monkey'), findsOneWidget);
    });

    testWidgets('Nhập email và mật khẩu', (WidgetTester tester) async {
      when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Hiển thị thông báo lỗi', (WidgetTester tester) async {
      when(mockAuthProvider.login(any, any)).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, 'wrong@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Sai tài khoản hoặc mật khẩu!'), findsOneWidget);
    });
  });
}
