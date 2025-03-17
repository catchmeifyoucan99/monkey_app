import 'package:expense_personal/cores/model/user_model.dart';
import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:expense_personal/view/screens/account/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

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

  testWidgets('Hiển thị đúng UI RegisterScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('monkey'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
  });

  testWidgets('Không nhập thông tin, hiển thị lỗi', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Vui lòng nhập đầy đủ thông tin'), findsOneWidget);
  });

  testWidgets('Nhập email sai định dạng, hiển thị lỗi', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(1), 'email_sai_dinh_dang');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Email không đúng định dạng'), findsOneWidget);
  });

  testWidgets('Mật khẩu dưới 6 ký tự, hiển thị lỗi', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(2), '123');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
  });

  testWidgets('Mật khẩu không khớp, hiển thị lỗi', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(2), '123456');
    await tester.enterText(find.byType(TextField).at(3), '654321');
    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Mật khẩu không khớp'), findsOneWidget);
  });

  testWidgets('Đăng ký thành công, chuyển hướng sang /login', (WidgetTester tester) async {
    // Giả lập đăng ký thành công
    when(mockAuthProvider.register(any, any, any)).thenAnswer((_) async => true);
    when(mockAuthProvider.user).thenReturn(UserModel(uid: '123123', email: 'test@gmail.com'));

    await tester.pumpWidget(createWidgetUnderTest());

    // Nhập thông tin đăng ký
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@gmail.com');
    await tester.enterText(find.byType(TextField).at(2), '123456');
    await tester.enterText(find.byType(TextField).at(3), '123456');
    await tester.tap(find.text('Đăng ký'));

    // Đợi các animation và chuyển hướng hoàn tất
    await tester.pumpAndSettle();

    // Kiểm tra thông báo thành công
    expect(find.text('Đăng ký thành công!'), findsOneWidget);

    // Kiểm tra chuyển hướng đến /login
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}