import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<void> signOut() async {
    await _auth.signOut();

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminid');
    await prefs.remove('docIid');
    await prefs.remove('userPhone');
    await prefs.remove('userName');
    await prefs.remove('phonev');
  }
}