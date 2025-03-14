class Saving {
  String id;
  String name;
  double targetAmount;
  double currentAmount;
  String category;

  Saving({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.category,
  });

  factory Saving.fromMap(Map<String, dynamic> data, String id) {
    return Saving(
      id: id,
      name: data['name'],
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      category: data['category'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'category': category,
    };
  }
}
