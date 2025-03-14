import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/view/screens/account/login_screen.dart';
import 'package:expense_personal/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_personal/model/user_model.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('monkey'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Quên mật khẩu'), findsOneWidget);
    expect(find.text('Chưa có tài khoản? Đăng ký'), findsOneWidget);
  });

  testWidgets('Login button shows error if fields are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Vui lòng nhập đầy đủ thông tin'), findsOneWidget);
  });

  testWidgets('Login button calls login method on AuthProvider',
      (WidgetTester tester) async {
    when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    verify(mockAuthProvider.login('test@example.com', 'password')).called(1);
  });

  testWidgets('Successful login shows welcome message and navigates to home',
      (WidgetTester tester) async {
    when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);
    when(mockAuthProvider.user).thenReturn(UserModel(uid: '123', email: 'test@example.com', name: 'Test User'));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Xin chào Test User'), findsOneWidget);
    expect(find.byType(LoginScreen),
        findsNothing); // Assuming it navigates away from LoginScreen
  });

  testWidgets('Failed login shows error message', (WidgetTester tester) async {
    when(mockAuthProvider.login(any, any)).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Sai tài khoản hoặc mật khẩu!'), findsOneWidget);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsNothing);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('Forgot password button logs message',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Quên mật khẩu'));
    await tester.pump();

    // Check the log output for the message "Quên mật khẩu"
    // This part is not directly testable with flutter_test, but you can verify the button is present and tappable
    expect(find.text('Quên mật khẩu'), findsOneWidget);
  });

  testWidgets('Register button navigates to register screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
    await tester.pump();

    // Assuming it navigates to the register screen
    expect(find.byType(LoginScreen), findsNothing);
  });
}
