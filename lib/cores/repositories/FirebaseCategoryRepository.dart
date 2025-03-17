import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/CategoryRepository.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  @override
  Future<List<String>> loadCategories(String userId, String type) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('${type}_categories')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('Lỗi khi tải danh mục: $e');
      return [];
    }
  }

  @override
  Future<void> addCategory(String name, String userId, String type) async {
    try {
      await FirebaseFirestore.instance.collection('${type}_categories').add({
        'name': name,
        'type': type,
        'userId': userId,
      });
    } catch (e) {
      print('Lỗi khi thêm danh mục: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryName, String userId, String type) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('${type}_categories')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      print('Danh mục đã được xóa: $categoryName');
    } catch (e) {
      print('Lỗi khi xóa danh mục: $e');
    }
  }
}
