import 'package:firebase_auth/firebase_auth.dart';

String? getCurrentUserId({FirebaseAuth? auth}) {
  final firebaseAuth = auth ?? FirebaseAuth.instance;
  User? user = firebaseAuth.currentUser;
  return user?.uid;
}