import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:expense_personal/view/screens/account/register_screen.dart';
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
        home: RegisterScreen(),
      ),
    );
  }

  testWidgets('Hiển thị các trường nhập và nút đăng ký', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byKey(const Key('nameField')), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passField')), findsOneWidget);
    expect(find.byKey(const Key('cfPassField')), findsOneWidget);
    expect(find.byKey(const Key('registerButton')), findsOneWidget);
  });

  testWidgets('Nhập thông tin đăng ký', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byKey(const Key('nameField')), 'John Doe');
    await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('passField')), 'password123');
    await tester.enterText(find.byKey(const Key('cfPassField')), 'password123');

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsNWidgets(2));
  });

  testWidgets('Register success', (WidgetTester tester) async {
    when(mockAuthProvider.register(any, any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');

    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.tap(find.text('Đăng ký'), warnIfMissed: false);
    await tester.ensureVisible(find.byKey(const Key('registerButton')));
    await tester.tap(find.byKey(const Key('registerButton')), warnIfMissed: false);
    await tester.pumpAndSettle();

    verifyNever(mockAuthProvider.register('John Doe', 'test@example.com', 'password123',)).called(0);
  });

  testWidgets('Register fail', (WidgetTester tester) async {
    when(mockAuthProvider.register(any, any, any)).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'pas');

    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.tap(find.text('Đăng ký'), warnIfMissed: false);
    await tester.ensureVisible(find.byKey(const Key('registerButton')));
    await tester.tap(find.byKey(const Key('registerButton')), warnIfMissed: false);
    await tester.pumpAndSettle();

    verifyNever(mockAuthProvider.register('', 'test@example.com', 'password123',)).called(0);
  });

  testWidgets('', (WidgetTester tester) async {
    when(mockAuthProvider.register(any, any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), '12');

    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.tap(find.text('Đăng ký'), warnIfMissed: false);
    await tester.ensureVisible(find.byKey(const Key('registerButton')));
    await tester.tap(find.byKey(const Key('registerButton')), warnIfMissed: false);
    await tester.pumpAndSettle();

    verifyNever(mockAuthProvider.register('John Doe', 'test@example.com', '12',)).called(0);

  });
}
