import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? langCode = prefs.getString('langCode') ?? 'ar'; // default to Arabic
  runApp(MyApp(initialLangCode: langCode));
}

class MyApp extends StatelessWidget {
  final String initialLangCode;

  const MyApp({Key? key, required this.initialLangCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(const Color(0xFF000047)),
          trackColor: MaterialStateProperty.all(const Color(0xffE3E5E8)),
          trackBorderColor: MaterialStateProperty.all(const Color(0xffE3E5E8)),
          thickness: MaterialStateProperty.all(8),
          radius: const Radius.circular(10),
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.blue.shade800,
          selectionHandleColor: Color(0xFF000047),
          cursorColor: Color(0xFF000047),
        ),
      ),

      debugShowCheckedModeBanner: false,
      locale: Locale(initialLangCode),
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
        return Directionality(
          textDirection: initialLangCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      home: SplachPage(),
    );
  }
}
