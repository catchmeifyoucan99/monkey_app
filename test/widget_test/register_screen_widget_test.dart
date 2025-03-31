import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/view/screens/account/register_screen.dart';
import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'register_screen_widget_test.mocks.dart';

// Tạo mock class
@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const RegisterScreen(),
      ),
    );
  }

  testWidgets('Kiểm tra UI của RegisterScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('monkey'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Đăng ký'), findsOneWidget);
    expect(find.text('Đã có tài khoản? Đăng nhập'), findsOneWidget);
  });

  testWidgets('Kiểm tra nhập liệu và đăng ký', (WidgetTester tester) async {
    when(mockAuthProvider.register(any, any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextField).at(0), 'Người Dùng');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');

    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    verify(mockAuthProvider.register('test@example.com', 'Người Dùng', 'password123')).called(1);
  });
}
