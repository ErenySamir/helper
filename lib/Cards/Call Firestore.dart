import 'package:cloud_firestore/cloud_firestore.dart';

import '../AddFamilyData/Model/FamilyModel.dart';

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FamilyDataModel>> getFamilyData({
    required String adminId,
    required String cardId,
  }) async {
    List<FamilyDataModel> familyList = [];

      QuerySnapshot snapshot = await _firestore
          .collection("PeopleData")
          .where('AdminID', isEqualTo: adminId)
          .where("CardId", isEqualTo: cardId)
          .get();

      for (var document in snapshot.docs) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        FamilyDataModel familyData = FamilyDataModel.fromMap(
          userData,
          docId: document.id,
        );
        familyList.add(familyData);
      }


    return familyList;
  }

  Future<void> deleteFamilyData(String docId) async {
    try {
      await _firestore.collection('PeopleData').doc(docId).delete();
      print("Document with ID $docId deleted successfully.");
    } catch (e) {
      print('Error deleting document: $e');
      throw e;
    }
  }

  Future<void> addFamilyToCard(String familyId, String cardId) async {
    await _firestore
        .collection('PeopleData')
        .doc(familyId)
        .update({
      "CardId": cardId,
    });
  }
}