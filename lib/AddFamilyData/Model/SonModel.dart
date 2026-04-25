import 'package:flutter/material.dart';

class SonData {
  TextEditingController nameController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController jobController = TextEditingController();
  TextEditingController nationalIdController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  TextEditingController maritalStatusController = TextEditingController();
  TextEditingController incomeController = TextEditingController();
  TextEditingController studyYearController = TextEditingController();

  SonData();

  SonData.fromMap(Map<String, dynamic> map) {
    nameController.text = map['name'] ?? '';
    educationController.text = map['education'] ?? '';
    jobController.text = map['job'] ?? '';
    nationalIdController.text = map['nationalId'] ?? '';
    phoneController.text = map['phone'] ?? '';
    imageController.text = map['image'] ?? '';
    maritalStatusController.text = map['maritalStatus'] ?? '';
    incomeController.text = map['income']?.toString() ?? '';
    studyYearController.text = map['studyYear'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text.trim(),
      'education': educationController.text.trim(),
      'job': jobController.text.trim(),
      'nationalId': nationalIdController.text.trim(),
      'phone': phoneController.text.trim(),
      'image': imageController.text.trim(),
      'maritalStatus': maritalStatusController.text.trim(),
      'income': int.tryParse(incomeController.text.trim()),
      'studyYear': studyYearController.text.trim(),
    };
  }

  void dispose() {
    nameController.dispose();
    educationController.dispose();
    jobController.dispose();
    nationalIdController.dispose();
    phoneController.dispose();
    imageController.dispose();
    maritalStatusController.dispose();
    incomeController.dispose();
    studyYearController.dispose();
  }
}