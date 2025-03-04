import 'package:expense_personal/view/screens/main/add/add_expense.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  test('getImageFromCamera should pick an image and update _image', () async {
    final expenseScreen = AddExpenseScreen();

    final state = expenseScreen.createState();

    state.addExpense(
        "Tiền ăn",
        50000,
        "Ăn uống",
        DateTime.now());

    expect(state.addExpense, "");
  });

  test('This function should return the content of the image', () async {
    final expenseScreen = AddExpenseScreen();

    final state = expenseScreen.createState();

    state.handleSaveTransaction();

    expect(state.addExpense, "");
  });
}
