import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/FamilyModel.dart';
import '../Model/SonModel.dart';

class FamilyDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> getPeopleData(String docId) async {
    if (docId.isEmpty) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('PeopleData')
          .doc(docId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error loading data: $e");
    }
    return null;
  }

  Future<void> saveFamilyData({
    String? docId,
    required String cardId,
    required String adminId,
    required String give,
    required String giverName,
    required String comment,
    required String needs,
    required String date,
    required Map<String, dynamic> fatherData,
    required Map<String, dynamic> motherData,
    required List<Map<String, dynamic>> sonsData,
    required BuildContext context,
  }) async {
    // Validate required fields
    if (adminId.isEmpty) {
      throw Exception("Admin ID is required");
    }

    if (cardId.isEmpty) {
      throw Exception("Card ID is required");
    }

    Map<String, dynamic> familyData = {
      'CardId': cardId,
      'give': give,
      'giverName': giverName,
      'date': date,
      'comment':comment,
      'AdminID': adminId,
      'father': fatherData,
      'mother': motherData,
      'sons': sonsData,
      'needs':needs,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    try {
      if (docId != null && docId.isNotEmpty) {
        // Update existing document
        await _firestore
            .collection('PeopleData')
            .doc(docId)
            .set(familyData, SetOptions(merge: true));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تم تعديل البيانات بنجاح".tr),
              backgroundColor: const Color(0xFF000047),
            ),
          );
        }
      } else {
        // Create new document
        await _firestore
            .collection('PeopleData')
            .add(familyData);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تم تسجيل البيانات بنجاح".tr),
              backgroundColor: const Color(0xFF000047),
            ),
          );
        }
      }
    } catch (e) {
      print("Error saving family data: $e");
      rethrow;
    }
  }

  void loadDataToControllers({
    required Map<String, dynamic>? data,
    required TextEditingController giveController,
    required TextEditingController giverNameController,
    required TextEditingController dateController,
    required TextEditingController fatherNameController,
    required TextEditingController fatherPhoneController,
    required TextEditingController fatherJobController,
    required TextEditingController fatherNationalIDController,
    required TextEditingController fatherEducationController,
    required TextEditingController fatherImageController,
    required TextEditingController motherNameController,
    required TextEditingController motherPhoneController,
    required TextEditingController motherJobController,
    required TextEditingController motherNationalIDController,
    required TextEditingController motherEducationController,
    required TextEditingController motherImageController,
    required TextEditingController commentController,
    required TextEditingController needsController,

    required List<SonData> sons,
  })
  {
    if (data == null) return;

    // Load basic info
    giveController.text = data['give']?.toString() ?? '';
    giverNameController.text = data['giverName']?.toString() ?? '';
    dateController.text = data['date']?.toString() ?? '';
    commentController.text = data['comment'] ?? '';
    needsController.text = data['needs'] ?? '';

    // Load father data
    if (data['father'] != null) {
      Map<String, dynamic> father = data['father'];
      fatherNameController.text = father['name']?.toString() ?? '';
      fatherPhoneController.text = father['phone']?.toString() ?? '';
      fatherJobController.text = father['job']?.toString() ?? '';
      fatherNationalIDController.text = father['nationalId']?.toString() ?? '';
      fatherEducationController.text = father['education']?.toString() ?? '';
      fatherImageController.text = father['image']?.toString() ?? '';
    }

    // Load mother data
    if (data['mother'] != null) {
      Map<String, dynamic> mother = data['mother'];
      motherNameController.text = mother['name']?.toString() ?? '';
      motherPhoneController.text = mother['phone']?.toString() ?? '';
      motherJobController.text = mother['job']?.toString() ?? '';
      motherNationalIDController.text = mother['nationalId']?.toString() ?? '';
      motherEducationController.text = mother['education']?.toString() ?? '';
      motherImageController.text = mother['image']?.toString() ?? '';
    }

    // Load sons data
    if (data['sons'] != null) {
      List sonsList = data['sons'];
      sons.clear(); // Clear existing sons before adding
      for (var sonData in sonsList) {
        sons.add(SonData.fromMap(sonData));
      }
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage({
    required File image,
    required String path,
    required String fileName,
  })
  async {
    try {
      // Create a reference to the location in Firebase Storage
      final storageRef = _storage.ref().child('$path/$fileName.jpg');

      // Upload the file
      final uploadTask = storageRef.putFile(image);

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() => {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print("Image uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final storageRef = _storage.refFromURL(imageUrl);
        await storageRef.delete();
        print("Image deleted successfully: $imageUrl");
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  // Delete family data document
  Future<void> deleteFamilyData(String docId) async {
    try {
      await _firestore.collection('PeopleData').doc(docId).delete();
      print("Family data deleted successfully: $docId");
    } catch (e) {
      print("Error deleting family data: $e");
      throw e;
    }
  }

  // Get family data by admin and card ID
  Future<List<FamilyDataModel>> getFamilyData({
    required String adminId,
    required String cardId,
  }) async {
    List<FamilyDataModel> familyList = [];

    try {
      print("Getting family data for admin: $adminId, cardId: $cardId");

      QuerySnapshot snapshot = await _firestore
          .collection("PeopleData")
          .where('AdminID', isEqualTo: adminId)
          .where('CardId', isEqualTo: cardId)
          .get();

      print("Found ${snapshot.docs.length} documents");

      for (var document in snapshot.docs) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        FamilyDataModel familyData = FamilyDataModel.fromMap(
          userData,
          docId: document.id,
        );
        familyList.add(familyData);
      }
    } catch (e) {
      print("Error getting family data: $e");
      throw e;
    }

    return familyList;
  }
}