import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ButtomNavigation/CustomButtomNavigation/ButtomNavigation.dart';
import '../Register/SignIn.dart';
import 'Animation/AnimationToggle.dart';
import 'Controller/Controller.dart';
import 'Translation/Translation.dart';

class SettingPage extends StatelessWidget{
  final SettingController controller = Get.put(SettingController());

  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.white,
   appBar: PreferredSize(
   preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
   child: Padding(
   padding: EdgeInsets.only(top: 25.0, bottom: 12, right: 8, left: 8),
   // Add padding to the top of the title
   child: AppBar(
   backgroundColor: Colors.white,
   surfaceTintColor: Colors.transparent,
   title: Text(
   "الإعدادات".tr,
   style: TextStyle(
   fontSize: 16,
   fontFamily: 'Cairo',
   fontWeight: FontWeight.w700,
   ),
   ),
   centerTitle: true,
   // Center the title horizontally
   leading: IconButton(
    onPressed: () {
    Map<dynamic, dynamic>? arguments = ModalRoute.of(context)
        ?.settings
        .arguments as Map<dynamic, dynamic>?; // Explicit casting

    FocusScope.of(context).requestFocus(FocusNode());
    // if (controller.formKey.currentState!.validate()) {
    Navigator.push(context,
    MaterialPageRoute(
    builder: (context) =>
    CustomNavigationBar(current: 0,),
    ),);

    },
    icon: Icon(
   // Get.locale?.languageCode == 'ar'
   //  ? Icons.arrow_forward_ios
   //      :
   Icons.arrow_back_ios_new_rounded,
    size: 24,
    color: Color(0xFF62748E),
    ),
    ),
    ),
    ),
    ),
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child:   Directionality(
         textDirection: Get.locale?.languageCode == 'ar'
             ? TextDirection.ltr
             : TextDirection.rtl,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.end,
           children: [
             const SizedBox(height: 16),
             _buildLanguageTile(),
             SizedBox(height: 30,),
             GestureDetector(
               onTap: (){
                 showDialog(
                   context: context,
                   builder: (context) => AlertDialog(
                     backgroundColor: Colors.white,
                     title: Text(
                       "تسجيل خروج".tr,
                       // textAlign: TextAlign.right,
                     ),
                     content: Text(
                       "هل أنت متأكد أنك تريد تسجيل الخروج؟".tr,
                       // textAlign: TextAlign.right,
                     ),
                     // actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                     actions: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Container(
                             height: 40,
                             width: 86,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(10.0),
                               color: Colors.white,
                             ),
                             child: TextButton(
                               onPressed: () => Navigator.of(context).pop(false),
                               child: Text(
                                 "إلغاء".tr,
                                 // textAlign: TextAlign.center,
                                 style: TextStyle(color: Color(0xFF000047)),
                               ),
                             ),
                           ),
                           Container(
                             height: 40,
                             width: 100,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(10.0),
                               color: Color(0xFF000047),
                             ),
                             child: TextButton(
                               onPressed: () async {
                                 print("Button pressed");
                                 // Clear specific value
                                 SharedPreferences prefs = await SharedPreferences.getInstance();
                                 await prefs.remove('phonev'); // or await prefs.setString('phonev', '');
                                 Navigator.push(
                                   context,
                                   MaterialPageRoute(builder: (context) => SigninPage()),
                                 );
                               },
                               child: Text(
                                 "تسجيل خروج".tr,
                                 // textAlign: TextAlign.center,
                                 style: TextStyle(color: Colors.white, fontSize: 12),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 );

               },
               child: Container(

                 // alignment: Alignment.centerRight, // Ensure container aligns children to the left
                 child: Text(
                   "تسجيل خروج".tr,
                   // textAlign: TextAlign.right, // Aligns text within its own bounds
                   style: TextStyle(
                     fontFamily: 'Cairo',
                     fontSize: 20.0,
                     fontWeight: FontWeight.bold,
                     color:  Color(0xFF000047),
                     decoration: TextDecoration.underline, // Adds the underline
                     decorationColor:  Color(0xFF000047), // Underline color to match text color
                     decorationThickness: 1.0, // Optional: Thickness of the underline
                   ),
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
  }
  Widget _buildLanguageTile() {
    return _buildTile(
      title: "اللغة".tr,
      trailing: Obx(() {
        final currentLang = TranslationController.to.currentLocale.languageCode;
        return Row(
          children: [
            // English option
            GestureDetector(
              onTap: ()
        {
          currentLang  == 'en';
          TranslationController.to.changeLanguage('en');
          changeLanguage(currentLang);
        } ,
              child: Text(
                'English'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: currentLang == 'en' ? const Color(0xFF000047) : Colors.grey,
                  fontWeight: currentLang == 'en' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Arabic option
            GestureDetector(
              onTap: () {
                currentLang == 'ar';
                TranslationController.to.changeLanguage('ar');
              changeLanguage(currentLang);},
              child: Text(
                "العربية".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: currentLang == 'ar' ? const Color(0xFF000047) : Colors.grey,
                  fontWeight: currentLang == 'ar' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
  Future<void> changeLanguage(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('langCode', langCode);
    Get.updateLocale(Locale(langCode));
  }

  Widget _buildTile({required String title, required Widget trailing}) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF1F2F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          trailing
          ,Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}