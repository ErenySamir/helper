import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';


import 'Setting/Translation/Translation.dart';
import 'SplachPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    name: "Helper",
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

  // Initialize controllers
  Get.put(TranslationController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: TranslationController.to.currentLocale,
      fallbackLocale: const Locale('ar', 'AR'),
      translations: TranslationController.to,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'AR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final locale = TranslationController.to.currentLocale;
        final isArabic = locale.languageCode == 'ar';

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },


      home: SplachPage(),
    );
  }
}