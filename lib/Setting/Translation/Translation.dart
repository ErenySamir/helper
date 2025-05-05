// lib/controllers/translation_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationController extends GetxController implements Translations {
  static TranslationController get to => Get.find();

  late SharedPreferences _prefs;
  final Rx<Locale> _locale = Rx<Locale>(const Locale('en', 'US'));

  Locale get currentLocale => _locale.value;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    String? languageCode = _prefs.getString('language');
    String? countryCode = _prefs.getString('country');

    if (languageCode != null) {
      _locale.value = Locale(languageCode, countryCode ?? '');
    } else {
      // Default to device locale if available, otherwise English
      _locale.value = Get.deviceLocale ?? const Locale('en', 'US');
    }
  }

  Future<void> changeLanguage(String languageCode, [String? countryCode]) async {
    final newLocale = Locale(languageCode, countryCode ?? '');
    await _prefs.setString('language', languageCode);
    if (countryCode != null) {
      await _prefs.setString('country', countryCode);
    }
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
  }
  @override
  Map<String, Map<String, String>> get keys => {
    "ar_SA": {
      // Validation & Auth
      " يجب ادخال رقم التليفون *": " يجب ادخال رقم التليفون *",
      " يجب أن يكون رقم الهاتف 11 رقمًا *": " يجب أن يكون رقم الهاتف 11 رقمًا *",
      "برجاء ادخال كلمه مرور صحيحة": "برجاء ادخال كلمه مرور صحيحة",
      "برجاء ادخال كلمه المرور قوية *": "برجاء ادخال كلمه المرور قوية *",
      "برجاء ادخال نفس كلمه المرور*": "برجاء ادخال نفس كلمه المرور*",
      "برجاء ادخال نفس كلمة المرور  ": "برجاء ادخال نفس كلمة المرور  ",
      "يجب ادخال نفس كلمه المرور":"يجب ادخال نفس كلمه المرور",
      "رقم الهاتف غير موجود برجاء انشاء حساب": "رقم الهاتف غير موجود برجاء انشاء حساب",
      "رقم الهاتف غير صحيح": "رقم الهاتف غير صحيح",
      "يجب ادخال بيانات": "يجب ادخال بيانات",

      // Login/Register
      "رقم التليفون ": "رقم التليفون ",
      "كلمة المرور ": "كلمة المرور ",
      "تأكيد كلمة المرور": "تأكيد كلمة المرور",
      "تأكيد كلمة المرور  ": "تأكيد كلمة المرور  ",
      "نسيت كلمة المرور": "نسيت كلمة المرور",
      "تسجيل دخول": "تسجيل دخول",
      "إنشــــاء حســــــاب": "إنشــــاء حســــــاب",
      "تم تسجيل الدخول بنجاح": "تم تسجيل الدخول بنجاح",
      "هذا الحساب حدث به خطا": "هذا الحساب حدث به خطا",
      "هذا الحساب موجود بالفعل برجاء تسجيل الدخول": "هذا الحساب موجود بالفعل برجاء تسجيل الدخول",

      // Internet
      "انت غير متصل بالانترنت": "انت غير متصل بالانترنت",
      "لا يوجد اتصال بالإنترنت": "لا يوجد اتصال بالإنترنت",

      // Forget Password
      "إعادة تعيين":"إعادة تعيين",
      "تم تغيير كلمة المرور بنجاح":"تم تغيير كلمة المرور بنجاح",
      "تغيير كلمة المرور":"تغيير كلمة المرور",
      "تأكيد":"تأكيد",

      // Home
      "  مرحبا بك  ":"  مرحبا بك  ",
      "تأكيد الحذف":"تأكيد الحذف",
      "هل أنت متأكد أنك تريد حذف هذه العائلة؟":"هل أنت متأكد أنك تريد حذف هذه العائلة؟",
      "إلغاء":"إلغاء",
      "حذف":"حذف",
      "تم حذف العائلة بنجاح":"تم حذف العائلة بنجاح",
      "   أسم العائلة :  ":"   أسم العائلة :  ",
      " تاريخ العطية : ":" تاريخ العطية : ",
      " العطية : ": " العطية : ",
      "  اسم المعطي :  ":"  اسم المعطي :  ",
      ": بتاريخ ":": بتاريخ ",
      "لم تتم اضافه اي بيانات حتي الان ":"لم تتم اضافه اي بيانات حتي الان ",

      // Profile
      "الملف الشخصى":"الملف الشخصى",
      "الأسم ":"الأسم ",
      "برجاء ادخال الاسم":"برجاء ادخال الاسم",
      "تعديل":"تعديل",
      "تسجيل خروج":"تسجيل خروج",

      // Edit Profile
      "تعديل الملف الشخصى":"تعديل الملف الشخصى",
      "تم حفظ التعديل بنجاح":"تم حفظ التعديل بنجاح",
      "حفــــــظ":"حفــــــظ",

      // Add Data Page
      "تم تعديل البيانات بنجاح":"تم تعديل البيانات بنجاح",
      "تم تسجيل البيانات بنجاح":"تم تسجيل البيانات بنجاح",
      "إضافة بيانات":"إضافة بيانات",
      "الأسم":"الأسم",
      "برجاء ادخال الأسم":"برجاء ادخال الأسم",
      "التاريخ":"التاريخ",
      "العطية":"العطية",
      "أسم المعطي العطية":"أسم المعطي العطية",
      "تليفون العائلة":"تليفون العائلة",
      "عدد افراد العائلة":"عدد افراد العائلة",
      "برجاء ادخال جميع البيانات":"برجاء ادخال جميع البيانات",
      "حدث خطأ أثناء إرسال البيانات. حاول مرة أخرى.":"حدث خطأ أثناء إرسال البيانات. حاول مرة أخرى.",
      "اللغة":"اللغة",
      "العربية":"العربية",
      "الإعدادات":"الإعدادات",
      // Misc
      "الملف":"الملف",
      "Home":"Home",
      "تسجيل الخروج ":"تسجيل الخروج ",
      "هل أنت متأكد أنك تريد تسجيل الخروج؟":"هل أنت متأكد أنك تريد تسجيل الخروج؟",

    },

    "en_US": {
      // Validation & Auth
      " يجب ادخال رقم التليفون *": "Phone number is required *",
      " يجب أن يكون رقم الهاتف 11 رقمًا *": "Phone number must be 11 digits *",
      "برجاء ادخال كلمه مرور صحيحة": "Please enter a valid password",
      "برجاء ادخال كلمه المرور قوية *": "Please enter a strong password *",
      "برجاء ادخال نفس كلمه المرور*": "Please enter the same password *",
      "برجاء ادخال نفس كلمة المرور  ": "Please enter the same password",
      "يجب ادخال نفس كلمه المرور":"Please enter the same password",
      "رقم الهاتف غير موجود برجاء انشاء حساب": "Phone number not found, please create an account",
      "رقم الهاتف غير صحيح": "Invalid phone number",
      "يجب ادخال بيانات": "Please enter the data",
      "تسجيل الخروج ":"Sign out ",
      "هل أنت متأكد أنك تريد تسجيل الخروج؟":"Are you sure you want to Sign out?",
      // Login/Register
      "رقم التليفون ": "Phone Number",
      "كلمة المرور ": "Password",
      "تأكيد كلمة المرور": "Confirm Password",
      "تأكيد كلمة المرور  ": "Confirm Password",
      "نسيت كلمة المرور": "Forgot Password",
      "تسجيل دخول": "Login",
      "إنشــــاء حســــــاب": "Create Account",
      "تم تسجيل الدخول بنجاح": "Login successful",
      "هذا الحساب حدث به خطا": "An error occurred with this account",
      "هذا الحساب موجود بالفعل برجاء تسجيل الدخول": "This account already exists, please login",
      "الإعدادات":" Setting",
      // Internet
      "انت غير متصل بالانترنت": "You are not connected to the internet",
      "لا يوجد اتصال بالإنترنت": "No internet connection",

      // Forget Password
      "إعادة تعيين":"Reset",
      "تم تغيير كلمة المرور بنجاح":"Password changed successfully",
      "تغيير كلمة المرور":"Change Password",
      "تأكيد":"Confirm",

      // Home
      "  مرحبا بك  ":"Welcome",
      "تأكيد الحذف":"Delete Confirmation",
      "هل أنت متأكد أنك تريد حذف هذه العائلة؟":"Are you sure you want to delete this family?",
      "إلغاء":"Cancel",
      "حذف":"Delete",
      "تم حذف العائلة بنجاح":"Family deleted successfully",
      "   أسم العائلة :  ":"   Family Name:  ",
      " تاريخ العطية : ":" Donation Date: ",
      " العطية : ": " Donation: ",
      "  اسم المعطي :  ":"  Donor Name:  ",
      ": بتاريخ ":":  Date ",
      "لم تتم اضافه اي بيانات حتي الان ":"No data has been added yet",

      // Profile
      "الملف الشخصى":"Profile",
      "الأسم ":"Name ",
      "برجاء ادخال الاسم":"Please enter the name",
      "تعديل":"Edit",
      "تسجيل خروج":"Logout",

      // Edit Profile
      "تعديل الملف الشخصى":"Edit Profile",
      "تم حفظ التعديل بنجاح":"Changes saved successfully",
      "حفــــــظ":"Save",

      // Add Data Page
      "تم تعديل البيانات بنجاح":"Data updated successfully",
      "تم تسجيل البيانات بنجاح":"Data saved successfully",
      "إضافة بيانات":"Add Data",
      "الأسم":"Name",
      "برجاء ادخال الأسم":"Please enter the name",
      "التاريخ":"Date",
      "العطية":"Donation",
      "أسم المعطي العطية":"Donor Name",
      "تليفون العائلة":"Family Phone",
      "عدد افراد العائلة":"Number of Family Members",
      "برجاء ادخال جميع البيانات":"Please enter all data",
      "حدث خطأ أثناء إرسال البيانات. حاول مرة أخرى.":"An error occurred while sending data. Please try again.",

      // Misc
      "الملف":"File",
      "Home":"Home",
      "اللغة":"Language",
      "العربية":"Arabic",
    }
  };
}
