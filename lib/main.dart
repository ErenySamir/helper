import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'SplachPage.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding.ensureInitialized(); // Ensures that Flutter bindings are initialized

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyDNdmYiVhY8qApFaywn2BIpuRLC0papBUU",
        authDomain: "helper-e19f5.firebaseapp.com",
        projectId: "helper-e19f5",
        storageBucket: "helper-e19f5.firebasestorage.app",
        messagingSenderId: "510676510600",
        appId: "1:510676510600:web:350297bf35f523177c3c3d",
        measurementId: "G-GH1H60DJHE"
    ),
  );

  runApp(
    GetMaterialApp(
      // theme: ThemeData(
      //   textSelectionTheme: TextSelectionThemeData(
      //       selectionColor: Color(0xFF32AE64), // Color of selected text
      //       selectionHandleColor: Color(0xFF32AE64),
      //       cursorColor: Colors.green.shade600// Color of the selection handles (cursors)
      //   ),
      // ),
      debugShowCheckedModeBanner: false,
      home: SplachPage(),
    ),
  );
}