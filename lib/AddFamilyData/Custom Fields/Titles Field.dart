import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000047),
        ),
      ),
    );
  }
}