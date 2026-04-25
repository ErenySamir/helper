import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to show image source dialog
  Future<File?> showImageSourceDialog(BuildContext context) async {
    // Check if context is still mounted
    if (!context.mounted) return null;

    return showDialog<File>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("اختر صورة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text("الكاميرا"),
                onTap: () async {
                  // Close the dialog first
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  // Then pick image
                  final image = await _pickImage(ImageSource.camera);
                  if (image != null && context.mounted) {
                    // Return the image to the original context
                    Navigator.pop(context, image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("المعرض"),
                onTap: () async {
                  // Close the dialog first
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  // Then pick image
                  final image = await _pickImage(ImageSource.gallery);
                  if (image != null && context.mounted) {
                    // Return the image to the original context
                    Navigator.pop(context, image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from source
  Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage({
    required File image,
    required String path,
    required String fileName,
  }) async {
    try {
      final storageRef = _storage.ref().child('$path/$fileName.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
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
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}