
import 'package:firebase_auth/firebase_auth.dart';

String? getCurrentUserId() {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}
