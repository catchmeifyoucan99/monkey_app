import 'dart:developer' as dev;

import 'package:expense_personal/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserModel?> register (String email, String name, String password) async{
    try{
      FirebaseAuth.instance.setLanguageCode("vi");
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        UserModel newUser = UserModel(uid: user.uid, email: email, name: name);
        return newUser;
      }
    } catch (e){
      print("Đăng kí thất bại: $e");
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


  Future<void> logout () async{
    await auth.signOut();
  }
}