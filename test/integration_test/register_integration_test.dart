import 'package:expense_personal/cores/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:expense_personal/view/screens/account/register_screen.dart';
import 'register_integration_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() async {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, __) => const RegisterScreen()),
            GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login Page'))),
          ],
        ),
      ),
    );
  }

  group('RegisterScreen Integration Test', () {
    testWidgets('Hiển thị đầy đủ các trường nhập', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Tên'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu'), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.text('Đã có tài khoản? Đăng nhập'), findsOneWidget);
    });

    testWidgets('Đăng ký thành công và chuyển hướng đến login', (WidgetTester tester) async {
      when(mockAuthProvider.register(any, any, any)).thenAnswer((_) async => true);
      when(mockAuthProvider.user).thenReturn(UserModel(name: 'John', email: 'john@example.com', uid: '001'));

      await tester.pumpWidget(createTestWidget());

      // Nhập dữ liệu hợp lệ
      await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'John');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'john@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Mật khẩu'), '123456');
      await tester.enterText(find.widgetWithText(TextField, 'Xác nhận mật khẩu'), '123456');

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đăng ký'));
      await tester.pump(); // Chờ SnackBar
      expect(find.text('Đăng ký thành công!'), findsOneWidget);

      // Chờ chuyển hướng sau 1 giây
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
      verify(mockAuthProvider.register('john@example.com', 'John', '123456')).called(1);
    });

    testWidgets('Đăng ký thất bại do tài khoản đã tồn tại', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Chờ UI render
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'John');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextField, 'Mật khẩu'), '123456');
      await tester.enterText(find.widgetWithText(TextField, 'Xác nhận mật khẩu'), '123456');

      // Kiểm tra nút "Đăng ký"
      final registerButton = find.text('Đăng ký');
      expect(registerButton, findsOneWidget, reason: "Không tìm thấy nút Đăng ký");

      // Đảm bảo nút có thể nhìn thấy
      await tester.ensureVisible(registerButton);

      // Nhấn nút
      await tester.tap(registerButton);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Hiển thị lỗi khi email không đúng định dạng', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Nhập email không hợp lệ
      await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'John');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextField, 'Mật khẩu'), '123456');
      await tester.enterText(find.widgetWithText(TextField, 'Xác nhận mật khẩu'), '123456');

      final registerButton = find.text('Đăng ký');
      expect(registerButton, findsOneWidget, reason: "Không tìm thấy nút Đăng ký");

      // Đảm bảo nút có thể nhìn thấy
      await tester.ensureVisible(registerButton);

      // Nhấn nút
      await tester.tap(registerButton);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Email không đúng định dạng'), findsOneWidget);
    });
  });
}

// Tạo file mock
// flutter pub run build_runner build --delete-conflicting-outputs