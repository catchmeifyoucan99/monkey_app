abstract class TransactionRepository {
  Future<void> addExpense(String title, double amount, String category, DateTime date);
  Future<void> addIncome(String title, double amount, String category, DateTime date);
  Future<int> getTotalIncome(String userId);
  Future<int> getTotalExpense(String userId);
}
