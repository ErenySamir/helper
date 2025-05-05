import 'dart:ui';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../TransAction.dart';


class SettingController  extends GetxController{
  var isDarkMode = false.obs;
  var isNotificationsEnabled = false.obs;
  var currentLanguage = 'ar'.obs;
  var toggleValue = 0.obs;
  final GetStorage storage = GetStorage();
  @override
  void onInit() {
    super.onInit();
    String savedLanguage = storage.read('lang') ?? 'ar';
    currentLanguage.value = savedLanguage;
    toggleValue.value = savedLanguage == 'ar' ? 1 : 0; // Initialize toggle position
    TranslationService().loadLanguage(savedLanguage);
  }
  void toggleDarkMode(bool value) => isDarkMode.value = value;

  void toggleNotifications(bool value) => isNotificationsEnabled.value = value;

  Future<void> setLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    toggleValue.value = languageCode == 'ar' ? 1 : 0;

    // Load translations first
    await TranslationService().loadLanguage(languageCode);
    // Save the language to storage
    storage.write('lang', languageCode);

    // Update locale
    Get.updateLocale(Locale(languageCode, languageCode == 'ar' ? 'EG' : 'US'));

    // Force UI update - this is important!
    Get.forceAppUpdate();
  }

}