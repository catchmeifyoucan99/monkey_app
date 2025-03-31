import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/model/user_model.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel?> register(String email, String name, String password) async {
    try {
      auth.setLanguageCode("vi");

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        UserModel newUser = UserModel(uid: user.uid, email: email, name: name);

        await firestore.collection('users').doc(user.uid).set(newUser.toMap());

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        dev.log("Email đã tồn tại.");
      } else {
        dev.log("Lỗi Firebase: ${e.code} - ${e.message}");
      }
    } catch (e) {
      dev.log("Lỗi không xác định: $e");
    }
    return null;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      auth.setLanguageCode("vi");

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null && user.email != null) {
        DocumentSnapshot userDoc =
        await firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          return UserModel(
            uid: user.uid,
            email: user.email!,
            name: data['name'] ?? 'Người dùng',
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      dev.log("Lỗi Firebase: ${e.code} - ${e.message}");
    } catch (e) {
      dev.log("Lỗi không xác định: $e");
    }
    return null;
  }

  Future<void> logout() async {
    await auth.signOut();
  }
}