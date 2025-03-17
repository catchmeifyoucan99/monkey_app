import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/view/screens/main/add/add_salary.dart';
import 'package:expense_personal/widgets/animated_add_button.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
  });

  testWidgets('AddSalaryScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddSalaryScreen()));

    expect(find.text('Thêm Thu Nhập'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(AnimatedAddButton), findsOneWidget);
  });

  test('addIncome function works correctly', () async {
    final title = 'Salary';
    final amount = 1000.0;
    final category = 'Job';
    final date = DateTime.now();

    await addIncome(title, amount, category, date);

    verify(mockFirestore.collection('transactions').add({
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': 'income',
      'createdAt': FieldValue.serverTimestamp(),
    }));
  });
}
