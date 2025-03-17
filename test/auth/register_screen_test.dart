import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/view/screens/account/register_screen.dart';
import 'package:expense_personal/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_personal/widgets/custom_button.dart'; // Import the CustomButton widget

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
        home: RegisterScreen(),
      ),
    );
  }

  testWidgets('RegisterScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('monkey'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);
    expect(find.text('Đã có tài khoản? Đăng nhập'), findsOneWidget);
  });

  testWidgets('Register button shows error if fields are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Vui lòng nhập đầy đủ thông tin'), findsOneWidget);
  });

  testWidgets('Register button shows error if email is invalid',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'invalid_email');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.enterText(find.byType(TextField).at(3), 'password');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Email không đúng định dạng'), findsOneWidget);
  });

  testWidgets(
      'Register button shows error if password is less than 6 characters',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), '123');
    await tester.enterText(find.byType(TextField).at(3), '123');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
  });

  testWidgets('Register button shows error if passwords do not match',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.enterText(find.byType(TextField).at(3), 'different_password');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Mật khẩu không khớp'), findsOneWidget);
  });

  testWidgets('Register button shows error if name is less than 3 characters',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'Te');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.enterText(find.byType(TextField).at(3), 'password');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Tên phải từ 3 đến 18 ký tự'), findsOneWidget);
  });

  testWidgets('Register button shows error if name is more than 18 characters',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0),
        'ThisIsAVeryLongNameThatExceedsEighteenCharacters');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.enterText(find.byType(TextField).at(3), 'password');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Tên phải từ 3 đến 18 ký tự'), findsOneWidget);
  });

  testWidgets('Register button calls register method on AuthProvider',
      (WidgetTester tester) async {
    when(mockAuthProvider.register(any, any, any))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.enterText(find.byType(TextField).at(3), 'password');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    verify(mockAuthProvider.register(
            'test@example.com', 'password', 'Test User'))
        .called(1);
  });

  testWidgets(
      'Successful registration shows success message and navigates to login',
      (WidgetTester tester) async {
    when(mockAuthProvider.register(any, any, any))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.enterText(find.byType(TextField).at(3), 'password');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Đăng ký thành công!'), findsOneWidget);
    expect(find.byType(RegisterScreen),
        findsNothing); // Assuming it navigates away from RegisterScreen
  });

  testWidgets('Failed registration shows error message',
      (WidgetTester tester) async {
    when(mockAuthProvider.register(any, any, any))
        .thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.enterText(find.byType(TextField).at(3), 'password');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Tài khoản đã được đăng kí!'), findsOneWidget);
  });

  testWidgets('Login button navigates to login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Đã có tài khoản? Đăng nhập'));
    await tester.pump();

    // Assuming it navigates to the login screen
    expect(find.byType(RegisterScreen), findsNothing);
  });
}
