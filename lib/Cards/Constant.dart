import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000047);
  static const Color secondary = Color(0xFF495A71);
  static const Color border = Color(0xFF9AAEC9);
  static const Color gradientStart = Colors.blue;
  static const Color gradientEnd = Colors.blueAccent;
}

class AppTextStyles {
  static const String fontFamily = 'Cairo';

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}