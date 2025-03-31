import 'package:expense_personal/cores/model/user_model.dart';
import 'package:expense_personal/cores/providers/auth_provider.dart';
import 'package:expense_personal/cores/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider(authService: mockAuthService);
  });

  group('AuthProvider tests', () {
    test('register() trả về true và cập nhật user khi đăng ký thành công', () async {
      final userModel = UserModel(uid: 'test-uid', email: 'test@example.com', name: 'Test User');
      when(mockAuthService.register(any, any, any)).thenAnswer((_) async => userModel);

      final result = await authProvider.register('test@example.com', 'Test User', '123456');

      expect(result, true);
      expect(authProvider.user, isA<UserModel>());
      expect(authProvider.user?.uid, 'test-uid');
      expect(authProvider.user?.email, 'test@example.com');
      expect(authProvider.user?.name, 'Test User');
    });

    test('register() trả về false và không cập nhật user khi đăng ký thất bại', () async {
      when(mockAuthService.register(any, any, any)).thenAnswer((_) async => null);

      final result = await authProvider.register('test@example.com', 'Test User', '123456');

      expect(result, false);
      expect(authProvider.user, isNull);
    });

    test('login() trả về true và cập nhật user khi đăng nhập thành công', () async {
      final userModel = UserModel(uid: 'test-uid', email: 'test@example.com', name: 'Test User');
      when(mockAuthService.login(any, any)).thenAnswer((_) async => userModel);

      final result = await authProvider.login('test@example.com', '123456');

      expect(result, true);
      expect(authProvider.user, isA<UserModel>());
      expect(authProvider.user?.uid, 'test-uid');
      expect(authProvider.user?.email, 'test@example.com');
      expect(authProvider.user?.name, 'Test User');
    });

    test('login() trả về false và không cập nhật user khi đăng nhập thất bại', () async {
      when(mockAuthService.login(any, any)).thenAnswer((_) async => null);

      final result = await authProvider.login('test@example.com', '123456');

      expect(result, false);
      expect(authProvider.user, isNull);
    });

    test('logout() đặt user về null và gọi logout của AuthService', () async {
      final userModel = UserModel(uid: 'test-uid', email: 'test@example.com', name: 'Test User');
      when(mockAuthService.login(any, any)).thenAnswer((_) async => userModel);
      await authProvider.login('test@example.com', '123456');

      when(mockAuthService.logout()).thenAnswer((_) async => Future.value());

      await authProvider.logout();

      expect(authProvider.user, isNull);
      verify(mockAuthService.logout()).called(1);
    });

    test('notifyListeners được gọi sau khi register thành công', () async {
      final userModel = UserModel(uid: 'test-uid', email: 'test@example.com', name: 'Test User');
      when(mockAuthService.register(any, any, any)).thenAnswer((_) async => userModel);

      int notifyCount = 0;
      authProvider.addListener(() {
        notifyCount++;
      });

      await authProvider.register('test@example.com', 'Test User', '123456');

      expect(notifyCount, 1);
    });

    test('notifyListeners được gọi sau khi login thành công', () async {
      final userModel = UserModel(uid: 'test-uid', email: 'test@example.com', name: 'Test User');
      when(mockAuthService.login(any, any)).thenAnswer((_) async => userModel);

      int notifyCount = 0;
      authProvider.addListener(() {
        notifyCount++;
      });

      await authProvider.login('test@example.com', '123456');

      expect(notifyCount, 1);
    });

    test('notifyListeners được gọi sau khi logout', () async {
      final userModel = UserModel(uid: 'test-uid', email: 'test@example.com', name: 'Test User');
      when(mockAuthService.login(any, any)).thenAnswer((_) async => userModel);
      await authProvider.login('test@example.com', '123456');

      when(mockAuthService.logout()).thenAnswer((_) async => Future.value());

      int notifyCount = 0;
      authProvider.addListener(() {
        notifyCount++;
      });

      await authProvider.logout();

      expect(notifyCount, 1);
    });
  });
}