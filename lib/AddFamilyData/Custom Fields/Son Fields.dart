import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../FamilyData.dart';
import '../Model/SonModel.dart';
import 'Custom txtField.dart';


class SonCard extends StatelessWidget {
  final int index;
  final SonData son;

  const SonCard({
    Key? key,
    required this.index,
    required this.son,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "الابن رقم ${index + 1}".tr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000047),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: son.nameController,
              label: "الإسم",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: son.educationController,
              label: "المؤهل",
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: son.jobController,
              label: "الوظيفة",
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: son.phoneController,
              label: "رقم الهاتف",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              maxLength: 11,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: son.nationalIdController,
              label: "الرقم القومي",
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: son.incomeController,
              label: "الدخل",
              icon: Icons.monetization_on,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: son.maritalStatusController,
              label: "الحالة الاجتماعية",
              icon: Icons.favorite_border,
            ),
          ],
        ),
      ),
    );
  }
}