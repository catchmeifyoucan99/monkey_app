import 'package:expense_personal/cores/model/user_model.dart';
import 'package:expense_personal/cores/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'login_test.mocks.dart';


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

  test('login() trả về UserModel khi đăng nhập thành công', () async {
    await fakeFirestore.collection('users').doc('test-uid').set({
      'email': 'test@example.com',
      'name': 'Test User',
    });

    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockUserCredential);

    final result = await authService.login("test@example.com", "123456");

    expect(result, isA<UserModel>());
    expect(result?.uid, 'test-uid');
    expect(result?.email, 'test@example.com');
    expect(result?.name, 'Test User');
  });

  test('login() trả về null khi Firestore không có dữ liệu người dùng', () async {

    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockUserCredential);

    final result = await authService.login("test@example.com", "123456");

    expect(result, isNull);
  });

  test('login() trả về null khi đăng nhập thất bại', () async {
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

    final result = await authService.login("test@example.com", "wrong-password");

    expect(result, isNull);
  });
}