import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Register/Model/UserModel.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserData?> getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');

      print("Searching for phone: $normalizedPhoneNumber");

      QuerySnapshot querySnapshot = await _firestore
          .collection('PersonData')
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        // Create user from map
        UserData user = UserData.fromMap(userData);
        user.id = doc.id; // Set the document ID

        print("User found: ${user.name}, ID: ${user.id}");

        // Save to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('adminid', user.id!);
        await prefs.setString('docIid', user.id!);
        await prefs.setString('userPhone', normalizedPhoneNumber);
        await prefs.setString('userName', user.name ?? '');

        print("Admin ID saved to SharedPreferences: ${user.id}");

        return user;
      } else {
        print("No user found with phone: $normalizedPhoneNumber");
      }
    } catch (e) {
      print("Error getting user: $e");
    }
    return null;
  }

  // Optional: Method to get current user ID from SharedPreferences
  Future<String?> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('adminid') ?? prefs.getString('docIid');
  }

  // Optional: Method to clear user data on logout
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminid');
    await prefs.remove('docIid');
    await prefs.remove('userPhone');
    await prefs.remove('userName');
    print("User data cleared from SharedPreferences");
  }
}