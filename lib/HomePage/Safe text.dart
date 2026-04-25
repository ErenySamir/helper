import 'dart:ui';

import 'package:flutter/cupertino.dart';

class SafeText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SafeText(
      this.text, {
        Key? key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      text!,
      style: style,
      textAlign: textAlign ?? TextAlign.right,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

