class Saving {
  String name;
  double targetAmount;
  double currentAmount;
  String category; // Thêm thuộc tính category để phân biệt Income và Expense

  Saving({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.category, // Thêm category vào constructor
  });
}
