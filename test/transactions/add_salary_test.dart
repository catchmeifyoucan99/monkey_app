import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/repositories/FirebaseTransactionRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';

import 'add_salary_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late FirebaseTransactionRepository transactionRepository;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    transactionRepository = FirebaseTransactionRepository(firestore: mockFirestore);

    when(mockFirestore.collection('transactions')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);
  });

  Widget createWidgetUnderTest() {
    return Provider<FirebaseTransactionRepository>.value(
      value: transactionRepository,
      child: const MaterialApp(
        home: Scaffold(body: Text('Test FirebaseSalaryRepository')),
      ),
    );
  }

  testWidgets('Add Salary success', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await transactionRepository.addIncome('Lương tháng', 5000000.0, 'Lương', DateTime(2024, 3, 18));

    verifyNever(mockCollection.add(argThat(isA<Map<String, dynamic>>()))).called(0);
  });

  testWidgets('Amount negative', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await transactionRepository.addIncome('Lương tháng', -5000000.0, 'Lương', DateTime(2024, 3, 18));

    verifyNever(mockCollection.add(any));
  });

  testWidgets('No title', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await transactionRepository.addIncome('', 5000000.0, 'Lương phụ', DateTime(2024, 3, 18));

    verifyNever(mockCollection.add(any));
  });
}