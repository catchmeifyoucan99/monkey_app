import 'package:expense_personal/cores/model/user_model.dart';
import 'package:expense_personal/cores/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'register_test.mocks.dart';

@GenerateMocks([UserCredential, User, FirebaseAuth])
void main() {
  late AuthService authService;
  late MockUserCredential mockUserCredential;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    authService = AuthService(
      auth: mockFirebaseAuth,
      firestore: fakeFirestore,
    );

    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUserCredential.user).thenReturn(mockUser);

    when(mockFirebaseAuth.setLanguageCode(any)).thenAnswer((_) async => null);
  });

  group('register tests', () {
    test('register() trả về UserModel khi đăng ký thành công', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authService.register("test@example.com", "Test User", "123456");

      expect(result, isA<UserModel>());
      expect(result?.uid, 'test-uid');
      expect(result?.email, 'test@example.com');
      expect(result?.name, 'Test User');

      final doc = await fakeFirestore.collection('users').doc('test-uid').get();
      expect(doc.exists, true);
      expect(doc.data()?['email'], 'test@example.com');
      expect(doc.data()?['name'], 'Test User');
    });

    test('register() trả về null khi email đã tồn tại', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await authService.register("test@example.com", "Test User", "123456");

      expect(result, isNull);

      final doc = await fakeFirestore.collection('users').doc('test-uid').get();
      expect(doc.exists, false);
    });

    test('register() trả về null khi mật khẩu yếu', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'weak-password'));

      final result = await authService.register("test@example.com", "Test User", "123");

      expect(result, isNull);

      final doc = await fakeFirestore.collection('users').doc('test-uid').get();
      expect(doc.exists, false);
    });

    test('register() trả về null khi có lỗi không xác định', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Lỗi không xác định'));

      final result = await authService.register("test@example.com", "Test User", "123456");

      expect(result, isNull);

      final doc = await fakeFirestore.collection('users').doc('test-uid').get();
      expect(doc.exists, false);
    });

    test('register() ghi đúng dữ liệu vào Firestore khi thành công', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      await authService.register("test@example.com", "Test User", "123456");

      final doc = await fakeFirestore.collection('users').doc('test-uid').get();
      expect(doc.exists, true);
      final data = doc.data();
      expect(data?['uid'], 'test-uid');
      expect(data?['email'], 'test@example.com');
      expect(data?['name'], 'Test User');
    });
  });
}