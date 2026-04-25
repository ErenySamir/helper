import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage/Safe text.dart';
import '../Image/Image Widget.dart';
import 'Custom Fields/Check Connection.dart';
import 'Custom Fields/Custom DataFiled.dart';
import 'Custom Fields/Custom NumField.dart';
import 'Custom Fields/Custom txtField.dart';
import 'Custom Fields/Family Fields.dart';
import 'Custom Fields/Son Fields.dart';
import 'Custom Fields/Titles Field.dart';
import 'Model/SonModel.dart';

class AddFamilyDataScreen extends StatefulWidget {
  final String docId;
  final String adminId;
  final String cardId;

  const AddFamilyDataScreen({
    Key? key,
    required this.docId,
    required this.adminId,
    required this.cardId,
  }) : super(key: key);

  @override
  State<AddFamilyDataScreen> createState() => _AddFamilyDataScreenState();
}

class _AddFamilyDataScreenState extends State<AddFamilyDataScreen>
    with SingleTickerProviderStateMixin {
  // Father data controllers
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController fatherPhoneController = TextEditingController();
  final TextEditingController fatherJobController = TextEditingController();
  final TextEditingController fatherNationalIDController = TextEditingController();
  final TextEditingController fatherEducationController = TextEditingController();
  final TextEditingController fatherImageController = TextEditingController();

  // Mother data controllers
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController motherPhoneController = TextEditingController();
  final TextEditingController motherJobController = TextEditingController();
  final TextEditingController motherNationalIDController = TextEditingController();
  final TextEditingController motherEducationController = TextEditingController();
  final TextEditingController motherImageController = TextEditingController();

  // Family basic info
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController familyPhoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController giveController = TextEditingController();
  final TextEditingController giverNameController = TextEditingController();
  final TextEditingController commentController = TextEditingController(); // Fixed: Added comment controller
  final TextEditingController needsController = TextEditingController(); // Fixed: Added comment controller

  // Store local image files (not uploaded yet)
  File? fatherLocalImageFile;
  File? motherLocalImageFile;

  // Store existing image URLs (for edit mode)
  String? fatherExistingImageUrl;
  String? motherExistingImageUrl;

  // Dynamic lists
  final List<SonData> sons = [];

  // Controllers for number inputs
  final TextEditingController sonsCountController = TextEditingController();

  bool isLoading = false;
  bool _isConnected = true;
  late AnimationController animationController;
  late Animation<double> animation;

  final FamilyDataService _familyDataService = FamilyDataService();
  String? currentAdminId;

  @override
  void initState() {
    super.initState();
    _initializeAdminId();
    _loadData();
    // loadDataToControllers();
    _checkConnectivity();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    animationController.forward();
  }

  Future<void> _initializeAdminId() async {
    if (widget.adminId.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentAdminId = prefs.getString('adminid') ?? prefs.getString('docIid');
      print("Admin ID from SharedPreferences: $currentAdminId");
    } else {
      currentAdminId = widget.adminId;
      print("Admin ID from widget: $currentAdminId");
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    fatherNameController.dispose();
    fatherPhoneController.dispose();
    fatherJobController.dispose();
    fatherNationalIDController.dispose();
    fatherEducationController.dispose();
    fatherImageController.dispose();
    motherNameController.dispose();
    motherPhoneController.dispose();
    motherJobController.dispose();
    motherNationalIDController.dispose();
    motherEducationController.dispose();
    motherImageController.dispose();
    familyNameController.dispose();
    familyPhoneController.dispose();
    dateController.dispose();
    giveController.dispose();
    giverNameController.dispose();
    commentController.dispose(); // Added
    sonsCountController.dispose();

    for (var son in sons) {
      son.dispose();
    }

    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.docId.isEmpty) return;
    final data = await _familyDataService.getPeopleData(widget.docId);
    _familyDataService.loadDataToControllers(
      data: data,
      giveController: giveController,
      giverNameController: giverNameController,
      dateController: dateController,
      commentController:commentController,
      needsController: needsController,
      fatherNameController: fatherNameController,
      fatherPhoneController: fatherPhoneController,
      fatherJobController: fatherJobController,
      fatherNationalIDController: fatherNationalIDController,
      fatherEducationController: fatherEducationController,
      fatherImageController: fatherImageController,
      motherNameController: motherNameController,
      motherPhoneController: motherPhoneController,
      motherJobController: motherJobController,
      motherNationalIDController: motherNationalIDController,
      motherEducationController: motherEducationController,
      motherImageController: motherImageController,
      sons: sons,
    );

    setState(() {
      fatherExistingImageUrl = fatherImageController.text;
      motherExistingImageUrl = motherImageController.text;
      print("Commmmmmmmmmmment${commentController.text} ");

    });
  }
  void generateSonsFields() {
    int count = int.tryParse(sonsCountController.text) ?? 0;
    while (sons.length < count) {
      sons.add(SonData());
    }
    while (sons.length > count) {
      sons.removeLast();
    }
    setState(() {});
  }

  Future<void> _sendData(BuildContext context) async {
    if (currentAdminId == null || currentAdminId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SafeText("خطأ: لم يتم العثور على معرف المستخدم"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.cardId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SafeText("خطأ: لم يتم العثور على معرف البطاقة"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    isLoading = true;
    setState(() {});

    try {
      String? finalFatherImageUrl;
      String? finalMotherImageUrl;

      // Upload father image if a new local image was selected
      if (fatherLocalImageFile != null) {
        final imageUrl = await _familyDataService.uploadImage(
          image: fatherLocalImageFile!,
          path: 'family_images/${widget.docId.isNotEmpty ? widget.docId : DateTime.now().millisecondsSinceEpoch.toString()}',
          fileName: 'husband_${DateTime.now().millisecondsSinceEpoch}',
        );
        finalFatherImageUrl = imageUrl;
      } else {
        // Keep existing image URL or null if deleted
        finalFatherImageUrl = fatherExistingImageUrl;
      }

      // Upload mother image if a new local image was selected
      if (motherLocalImageFile != null) {
        final imageUrl = await _familyDataService.uploadImage(
          image: motherLocalImageFile!,
          path: 'family_images/${widget.docId.isNotEmpty ? widget.docId : DateTime.now().millisecondsSinceEpoch.toString()}',
          fileName: 'wife_${DateTime.now().millisecondsSinceEpoch}',
        );
        finalMotherImageUrl = imageUrl;
      } else {
        // Keep existing image URL or null if deleted
        finalMotherImageUrl = motherExistingImageUrl;
      }

      // FIX: Remove duplicate 'image' fields
      await _familyDataService.saveFamilyData(
        docId: widget.docId,
        cardId: widget.cardId,
        adminId: currentAdminId!,
        comment: commentController.text.trim(),
        give: giveController.text.trim(),
        giverName: giverNameController.text.trim(),
        date: dateController.text.trim(),
needs: needsController.text.trim(),
        fatherData: {
          'name': fatherNameController.text.trim(),
          'phone': fatherPhoneController.text.trim(),
          'job': fatherJobController.text.trim(),
          'nationalId': fatherNationalIDController.text.trim(),
          'education': fatherEducationController.text.trim(),
          'image': finalFatherImageUrl ?? '', // Only one image field
        },
        motherData: {
          'name': motherNameController.text.trim(),
          'phone': motherPhoneController.text.trim(),
          'job': motherJobController.text.trim(),
          'nationalId': motherNationalIDController.text.trim(),
          'education': motherEducationController.text.trim(),
          'image': finalMotherImageUrl ?? '', // Only one image field
        },
        sonsData: sons.map((son) => son.toMap()).toList(),
        context: context,
      );

      _clearAllFields();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SafeText(
            widget.docId.isEmpty ? "تم إضافة البيانات بنجاح".tr : "تم تعديل البيانات بنجاح".tr,
          ),
          backgroundColor: const Color(0xFF000047),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print("Error in _sendData: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SafeText("حدث خطأ: ${e.toString()}".tr),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      setState(() {});
    }
  }
  void _clearAllFields() {
    fatherNameController.clear();
    fatherPhoneController.clear();
    fatherJobController.clear();
    fatherNationalIDController.clear();
    fatherEducationController.clear();
    fatherImageController.clear();
    motherNameController.clear();
    motherPhoneController.clear();
    motherJobController.clear();
    motherNationalIDController.clear();
    motherEducationController.clear();
    motherImageController.clear();
    familyNameController.clear();
    familyPhoneController.clear();
    giveController.clear();
    giverNameController.clear();
    dateController.clear();
    commentController.clear();
    sonsCountController.clear();
    sons.clear();
  }

  Future<void> _checkConnectivity() async {
    await ConnectivityService.checkConnectivity(context, (isConnected) {
      if (_isConnected != isConnected) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0, bottom: 12, right: 8, left: 8),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: SafeText(
              widget.docId.isEmpty ? "إضافة بيانات".tr : "تعديل بيانات".tr,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 24,
                color: Color(0xFF62748E),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl, // Changed to RTL for Arabic
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Father Section with Image
                const SectionTitle(title: "بيانات الزوج"),
                const SizedBox(height: 16),

                // Image Picker for Father
                // Image Picker for Father
                Center(
                  child: ImagePickerWidget(
                    imageUrl: fatherExistingImageUrl,
                    localImageFile: fatherLocalImageFile,
                    personType: "husband",
                    familyId: widget.docId.isNotEmpty
                        ? widget.docId
                        : DateTime.now().millisecondsSinceEpoch.toString(),
                    onLocalImageSelected: (file) {
                      setState(() {
                        fatherLocalImageFile = file;
                        if (file == null) {
                          fatherExistingImageUrl = null;
                        }
                      });
                    },
                    onImageDeleted: () {
                      setState(() {
                        fatherLocalImageFile = null;
                        fatherExistingImageUrl = null;
                      });
                    },
                    isEditMode: widget.docId.isNotEmpty,
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: fatherNameController,
                  label: "إسم الزوج",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: fatherEducationController,
                  label: "مؤهل الزوج",
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: fatherJobController,
                  label: "وظيفة الزوج",
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: fatherPhoneController,
                  label: "تليفون الزوج",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: fatherNationalIDController,
                  label: "الرقم القومي للزوج",
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Mother Section with Image
                const SectionTitle(title: "بيانات الزوجة"),
                const SizedBox(height: 16),

                // Image Picker for Mother
                // Image Picker for Mother
                Center(
                  child: ImagePickerWidget(
                    imageUrl: motherExistingImageUrl,
                    localImageFile: motherLocalImageFile,
                    personType: "wife",
                    familyId: widget.docId.isNotEmpty
                        ? widget.docId
                        : DateTime.now().millisecondsSinceEpoch.toString(),
                    onLocalImageSelected: (file) {
                      setState(() {
                        motherLocalImageFile = file;
                        if (file == null) {
                          motherExistingImageUrl = null;
                        }
                      });
                    },
                    onImageDeleted: () {
                      setState(() {
                        motherLocalImageFile = null;
                        motherExistingImageUrl = null;
                      });
                    },
                    isEditMode: widget.docId.isNotEmpty,
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: motherNameController,
                  label: "إسم الزوجة",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: motherEducationController,
                  label: "مؤهل الزوجة",
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: motherJobController,
                  label: "وظيفة الزوجة",
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: motherPhoneController,
                  label: "تليفون الزوجة",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: motherNationalIDController,
                  label: "الرقم القومي للزوجة",
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Sons Section
                const SectionTitle(title: "بيانات الأبناء"),
                const SizedBox(height: 16),
                CustomNumberField(
                  controller: sonsCountController,
                  label: "عدد الأبناء",
                  icon: Icons.people_outline,
                  onChanged: (_) => generateSonsFields(),
                ),
                const SizedBox(height: 16),
                ...List.generate(sons.length, (index) => SonCard(index: index, son: sons[index])),

                // Date and Give Info
                const SectionTitle(title: "معلومات العطية"),
                const SizedBox(height: 16),
                CustomDateField(controller: dateController),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: giveController,
                  label: "العطية",
                  icon: Icons.monetization_on,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: giverNameController,
                  label: "أسم المعطي",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Notes Field
                Directionality(

                  textDirection: TextDirection.rtl,
                  child: TextField(

                    controller: commentController,
                    minLines: 3,
                    maxLines: 5,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: "ملاحظات".tr,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Field
                Directionality(

                  textDirection: TextDirection.rtl,
                  child: TextField(

                    controller: needsController,
                    minLines: 3,
                    maxLines: 5,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: "طلبات".tr,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                GestureDetector(
                  onTap: isLoading ? null : () => _sendData(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      color: const Color(0xFF000047),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SafeText(
                        widget.docId.isEmpty ? "حفــــــظ".tr : "تعديــــل".tr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}