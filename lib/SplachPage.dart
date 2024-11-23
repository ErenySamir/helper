import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'HomePage/HomePage.dart';
import 'Register/SignIn.dart';
import 'Register/SignUp.dart';

class SplachPage extends StatefulWidget{
  @override
  State<SplachPage> createState() {
  return SplachPageState();
  }

}
class SplachPageState extends State<SplachPage> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  StreamSubscription<QuerySnapshot>? playerChatSubscription;

  @override
  void initState() {
    super.initState();

    // Define animation controller
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Adjust the duration as needed
    );

    // Define animation
    animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    animationController.forward();

    // Navigate to the next page after the animation or a delay
    Future.delayed(Duration(seconds: 3), () {
      navigateToPage();
    });

    // Check for Firebase listener, but only if necessary
    addFirestoreListener();
  }

  // Handle Firestore listener only when phone is present in SharedPreferences
  void addFirestoreListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? '';

    if (phone.isNotEmpty) {
      // Set up Firestore listener only when phone number is available
      CollectionReference playerChat = FirebaseFirestore.instance.collection('PersonData');
      playerChatSubscription = playerChat.snapshots().listen((snapshot) {
        bool phoneExists = snapshot.docs.any((doc) => doc['phone'] == phone);
        if (!phoneExists) {
          // Navigate to the sign-up page if phone number no longer exists
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
          );
        }
      });
    }
  }

  // Navigate to the appropriate page based on the phone number availability
  Future<void> navigateToPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phoneotp') ?? '';
    String phoneAlt = prefs.getString('phonev') ?? '';

    if (!mounted) return;

    if (phoneAlt.isEmpty) {
      // Navigate to the sign-up page if no phone number is found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
      );
    } else {
      // Query Firestore once to get the document ID and navigate to home page
      await getDocumentIdAndNavigate(phone, phoneAlt);
    }
  }

  // Query Firestore for the document ID and navigate accordingly
  Future<void> getDocumentIdAndNavigate(String phone, String phoneAlt) async {
    String docId = '';

    try {
      CollectionReference playerchat = FirebaseFirestore.instance.collection('PersonData');
      QuerySnapshot playerQuerySnapshot;

      if (phone.isNotEmpty) {
        playerQuerySnapshot = await playerchat.where('phone', isEqualTo: phone).get();
      } else {
        playerQuerySnapshot = await playerchat.where('phone', isEqualTo: phoneAlt).get();
      }

      if (playerQuerySnapshot.docs.isNotEmpty) {
        docId = playerQuerySnapshot.docs.first.id;
        print("Document ID in splash: $docId");
        // Optionally store docId in SharedPreferences
      }

      // Navigate to home page after successfully fetching document ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error retrieving document ID: $e');
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    playerChatSubscription?.cancel(); // Safely cancel Firestore subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:   Color(0xFF000047),
      body: Center(
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: child,
            );
          },
          child: Image.asset('assets/images/splach.png'),
        ),
      ),
    );
  }
}