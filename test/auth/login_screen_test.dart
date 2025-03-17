import 'package:expense_tracking/application/dto/email_password_login.dart';
import 'package:expense_tracking/application/service/email_password_login_service.dart';
import 'package:expense_tracking/exceptions/user_disabled_exception.dart';
import 'package:expense_tracking/exceptions/user_notfound_exception.dart';
import 'package:expense_tracking/exceptions/wrong_password_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as mock;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'email_password_login_service_test.mocks.dart';

// Tạo mock cho FirebaseAuth và UserCredential
@GenerateMocks([FirebaseAuth, UserCredential])
void main() {
  // Khai báo các biến
  late MockFirebaseAuth mockFirebaseAuth;
  late EmailPasswordLoginService loginService;
  late EmailPasswordLogin loginData;

  // Thiết lập trước mỗi test
  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    loginService = EmailPasswordLoginService(auth: mockFirebaseAuth);
    loginData =
        EmailPasswordLogin(email: 'test@example.com', password: 'password123');
  });

  // Test case 1: Đăng nhập thành công
  test('Đăng nhập thành công', () async {
    // Arrange: Giả lập phương thức signInWithEmailAndPassword trả về UserCredential
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: loginData.email,
      password: loginData.password,
    )).thenAnswer((_) async => MockUserCredential());

    when(mockFirebaseAuth.currentUser).thenAnswer(
          (realInvocation) => mock.MockUser(),
    );

    // Act: Gọi phương thức login
    await loginService.login(loginData);

    // Assert: Kiểm tra rằng phương thức signInWithEmailAndPassword được gọi đúng một lần
    verify(mockFirebaseAuth.signInWithEmailAndPassword(
      email: loginData.email,
      password: loginData.password,
    )).called(1);
  });

  // Test case 2: Đăng nhập thất bại do người dùng không tồn tại
  test('Đăng nhập thất bại do người dùng không tồn tại', () async {
    // Arrange: Giả lập ném ra FirebaseAuthException với mã lỗi 'user-not-found'
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

    // Act & Assert: Kiểm tra rằng phương thức login ném ra UserNotFoundException
    expect(() => loginService.login(loginData),
        throwsA(isA<UserNotFoundException>()));
  });

  // Test case 3: Đăng nhập thất bại do mật khẩu sai
  test('Đăng nhập thất bại do mật khẩu sai', () async {
    // Arrange: Giả lập ném ra FirebaseAuthException với mã lỗi 'wrong-password'
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

    // Act & Assert: Kiểm tra rằng phương thức login ném ra WrongPasswordException
    expect(() => loginService.login(loginData),
        throwsA(isA<WrongPasswordException>()));
  });

  // Test case 4: Đăng nhập thất bại do tài khoản bị vô hiệu hóa
  test('Đăng nhập thất bại do tài khoản bị vô hiệu hóa', () async {
    // Arrange: Giả lập ném ra FirebaseAuthException với mã lỗi 'user-disabled'
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: loginData.email,
      password: loginData.password,
    )).thenThrow(FirebaseAuthException(code: 'user-disabled'));

    // Act & Assert: Kiểm tra rằng phương thức login ném ra UserDisabledException
    expect(() => loginService.login(loginData),
        throwsA(isA<UserDisabledException>()));
  });

  // Test case 5: Đăng nhập thất bại do lỗi khác
  test('Đăng nhập thất bại do lỗi khác', () async {
    // Arrange: Giả lập ném ra FirebaseAuthException với mã lỗi bất kỳ khác
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: loginData.email,
      password: loginData.password,
    )).thenThrow(FirebaseAuthException(code: 'other-error'));

    // Act & Assert: Kiểm tra rằng phương thức login ném ra Exception
    expect(() => loginService.login(loginData), throwsA(isA<Exception>()));
  });
  //testcase 6 : Đăng nhập thất bại do email trống
  test('Đăng nhập thất bại do email trống', () async {
    final emptyEmailData = EmailPasswordLogin(email: '', password: 'password123@');

    expect(() => loginService.login(emptyEmailData), throwsA(isA<ArgumentError>()));
  });
//test case 7: Đăng nhập thất bại do password trống
  test('Đăng nhập thất bại do password trống', () async {
    final emptyPasswordData = EmailPasswordLogin(email: 'test@example.com', password: '');

    expect(() => loginService.login(emptyPasswordData), throwsA(isA<ArgumentError>()));
  });
}