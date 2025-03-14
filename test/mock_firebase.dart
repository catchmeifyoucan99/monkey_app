import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

// Tạo Mock Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Tạo Mock CollectionReference
class MockCollectionReference extends Mock implements CollectionReference {}
