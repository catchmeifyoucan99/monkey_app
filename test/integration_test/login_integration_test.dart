import 'package:expense_personal/cores/model/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:expense_personal/view/screens/account/login_screen.dart';
import '../integration_test/login_integration_test.mocks.dart';

@GenerateMocks([AuthProvider, FirebaseApp])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: MaterialApp.router(
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
          GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home Page'))),
        ]),
      ),
    );
  }

  group('LoginScreen Integration Test', () {
    testWidgets('Hiển thị đầy đủ các trường nhập', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Quên mật khẩu'), findsOneWidget);
      expect(find.text('Chưa có tài khoản? Đăng ký'), findsOneWidget);
    });

    testWidgets('Đăng nhập thành công', (WidgetTester tester) async {
      when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);
      when(mockAuthProvider.user).thenReturn(UserModel(name: 'Test User', email: 'test@example.com', uid: '001'));

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      verify(mockAuthProvider.login('test@example.com', '123456')).called(1);
    });

    testWidgets('Đăng nhập thất bại', (WidgetTester tester) async {
      when(mockAuthProvider.login(any, any)).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, 'wrong@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sai tài khoản hoặc mật khẩu!'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}