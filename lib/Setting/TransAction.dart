import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

class TranslationService extends Translations {
  Map<String, Map<String, String>> translations = {};
  TranslationService() {
    translations['ar'] = {};
    translations['en'] = {};
  }
  Future<void> loadLanguage(String langCode) async {
    final String jsonString = await rootBundle.loadString('assets/language/$langCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    translations[langCode] = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    Get.clearTranslations();
    Get.addTranslations(translations);
  }
  @override
  Map<String, Map<String, String>> get keys => translations;
}