import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/model/user_model.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserModel?> register(String email, String name, String password) async {
    try {
      FirebaseAuth.instance.setLanguageCode("vi");

      var userExists = await auth.fetchSignInMethodsForEmail(email);
      if (userExists.isNotEmpty) {
        dev.log("Email đã tồn tại.");
        return null;
      }

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
      dev.log("Lỗi Firebase: ${e.code} - ${e.message}");
    } catch (e) {
      dev.log("Lỗi không xác định: $e");
    }
    return null;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      FirebaseAuth.instance.setLanguageCode("vi");

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null && user.email != null) {
        return UserModel(uid: user.uid, email: user.email!);
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
