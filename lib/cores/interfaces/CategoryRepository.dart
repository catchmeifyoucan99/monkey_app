abstract class CategoryRepository {
  Future<List<String>> loadCategories(String userId, String type);
  Future<void> addCategory(String name, String userId, String type);
  Future<void> deleteCategory(String categoryName, String userId, String type);
}
