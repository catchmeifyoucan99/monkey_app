import 'package:expense_personal/cores/repositories/FirebaseCategoryRepository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_category_test.mocks.dart';
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentReference,
])

void main() {
  late FirebaseCategoryRepository categoryRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDocument;
  late MockDocumentReference mockDocRef;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocument = MockQueryDocumentSnapshot();
    mockDocRef = MockDocumentReference();

    categoryRepository = FirebaseCategoryRepository();
  });

  test('loadCategories returns a list of category names', () async {
    when(mockFirestore.collection(any)).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
    when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument['name']).thenReturn('Food');

    final categories = await categoryRepository.loadCategories('user123', 'expense');

    expect(categories, ['Food']);
  });

  test('addCategory adds a category to Firestore', () async {
    when(mockFirestore.collection(any)).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);

    await categoryRepository.addCategory('Transport', 'user123', 'expense');

    verify(mockCollection.add({
      'name': 'Transport',
      'type': 'expense',
      'userId': 'user123',
    })).called(1);
  });

  test('deleteCategory removes the category from Firestore', () async {
    when(mockFirestore.collection(any)).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
    when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.reference).thenReturn(mockDocRef);
    when(mockDocRef.delete()).thenAnswer((_) async {});

    await categoryRepository.deleteCategory('Food', 'user123', 'expense');

    verify(mockDocRef.delete()).called(1);
  });
}
