import 'package:flutter/material.dart';

class RelativeData {
  TextEditingController nameController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  TextEditingController incomeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  RelativeData();

  RelativeData.fromMap(Map<String, dynamic> map) {
    nameController.text = map['name'] ?? '';
    relationController.text = map['relation'] ?? '';
    incomeController.text = map['income']?.toString() ?? '';
    phoneController.text = map['phone'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text.trim(),
      'relation': relationController.text.trim(),
      'income': int.tryParse(incomeController.text.trim()),
      'phone': phoneController.text.trim(),
    };
  }

  void dispose() {
    nameController.dispose();
    relationController.dispose();
    incomeController.dispose();
    phoneController.dispose();
  }
}