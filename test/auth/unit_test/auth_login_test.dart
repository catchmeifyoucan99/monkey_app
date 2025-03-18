import 'package:expense_personal/cores/model/user_model.dart';
import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:expense_personal/cores/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_login_test.mocks.dart';


@GenerateMocks([AuthService])
void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider();
  });

  group('Register', () {
    test('Register success', () async {
      UserModel fakeUser = UserModel(uid: '123', email: 'test@example.com', name: 'John Doe');
      when(mockAuthService.register(any, any, any)).thenAnswer((_) async => fakeUser);

      bool result = await authProvider.register('test@example.com', 'John Doe', 'password123');

      expect(result, isTrue);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.email, equals('test@example.com'));
    });

    test('Đăng ký thất bại', () async {
      when(mockAuthService.register(any, any, any)).thenAnswer((_) async => null);

      bool result = await authProvider.register('test@example.com', 'John Doe', 'password123');

      expect(result, isFalse);
      expect(authProvider.user, isNull);
    });
  });

  group('Đăng nhập', () {
    test('Đăng nhập thành công', () async {
      UserModel fakeUser = UserModel(uid: '123', email: 'test@example.com', name: 'John Doe');
      when(mockAuthService.login(any, any)).thenAnswer((_) async => fakeUser);

      bool result = await authProvider.login('test@example.com', 'password123');

      expect(result, isTrue);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.email, equals('test@example.com'));
    });

    test('Đăng nhập thất bại', () async {
      when(mockAuthService.login(any, any)).thenAnswer((_) async => null);

      bool result = await authProvider.login('test@example.com', 'password123');

      expect(result, isFalse);
      expect(authProvider.user, isNull);
    });
  });

  test('Đăng xuất', () async {
    UserModel fakeUser = UserModel(uid: '123', email: 'test@example.com', name: 'John Doe');
    authProvider = AuthProvider();
    authProvider.register('test@example.com', 'John Doe', 'password123');

    await authProvider.logout();

    expect(authProvider.user, isNull);
  });
}
