import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/model/saving.dart';


class SavingService {
  final CollectionReference savingsCollection =
  FirebaseFirestore.instance.collection('savings');

  Future<void> addSaving(Saving saving) async {
    await savingsCollection.add(saving.toMap());
  }

  Stream<List<Saving>> getSavings() {
    return savingsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Saving.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateSaving(String id, double newAmount) async {
    await savingsCollection.doc(id).update({'currentAmount': newAmount});
  }

  // Xóa khoản tiết kiệm
  Future<void> deleteSaving(String id) async {
    await savingsCollection.doc(id).delete();
  }
}
