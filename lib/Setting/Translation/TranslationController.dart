
import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translation extends GetxController {
  SharedPreferences? _sharedPref;
  Locale? _initialLang;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _sharedPref = await SharedPreferences.getInstance();
    String? savedLang = _sharedPref!.getString('lang');
    _initialLang = savedLang != null ? Locale(savedLang) : Get.deviceLocale!;
    update();
  }

  Locale get initialLang => _initialLang ?? Get.deviceLocale!;

  Future<void> changeLang(String codeLang) async {
    Locale locale = Locale(codeLang);
    await _sharedPref!.setString('lang', codeLang);
    Get.updateLocale(locale);
    update();
  }
}