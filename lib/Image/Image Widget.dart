import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? imageUrl; // Existing image URL from Firebase
  final File? localImageFile; // Local image file (not yet uploaded)
  final String personType;
  final String familyId;
  final Function(File?) onLocalImageSelected; // Callback when local image is selected
  final Function() onImageDeleted; // Callback when image is deleted
  final bool isEditMode; // Whether we're in edit mode

  const ImagePickerWidget({
    Key? key,
    this.imageUrl,
    this.localImageFile,
    required this.personType,
    required this.familyId,
    required this.onLocalImageSelected,
    required this.onImageDeleted,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _selectedImageFile = widget.localImageFile;
    _existingImageUrl = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF000047), width: 2),
              color: Colors.grey.shade100,
              image: _getImageDecoration(),
            ),
            child: _getImageChild(),
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImageFile != null || (_existingImageUrl != null && _existingImageUrl!.isNotEmpty))
          TextButton.icon(
            onPressed: _removeImage,
            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
            label: Text(
              "حذف الصورة".tr,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  DecorationImage? _getImageDecoration() {
    if (_selectedImageFile != null) {
      // Show locally selected image
      return DecorationImage(
        image: FileImage(_selectedImageFile!),
        fit: BoxFit.cover,
      );
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      // Show existing image from URL (only in edit mode)
      return DecorationImage(
        image: NetworkImage(_existingImageUrl!),
        fit: BoxFit.cover,
        onError: (error, stackTrace) {
          print("Error loading image: $error");
        },
      );
    }
    return null;
  }

  Widget? _getImageChild() {
    if (_selectedImageFile == null &&
        (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 40,
            color: const Color(0xFF000047),
          ),
          const SizedBox(height: 8),
          Text(
            "إضافة صورة".tr,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF000047),
              fontFamily: 'Cairo',
            ),
          ),
        ],
      );
    }
    return null;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                "اختر صورة".tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF000047)),
                title: Text("التقاط صورة".tr),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF000047)),
                title: Text("اختر من المعرض".tr),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          // Clear existing URL when new local image is selected
          _existingImageUrl = null;
        });

        // Notify parent about local image selection (NO UPLOAD YET)
        widget.onLocalImageSelected(_selectedImageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم اختيار الصورة".tr),
            backgroundColor: const Color(0xFF000047),
          ),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء اختيار الصورة".tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _existingImageUrl = null;
    });

    // Notify parent
    widget.onLocalImageSelected(null);
    widget.onImageDeleted();
  }
}