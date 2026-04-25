import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Function(String) onChanged;

  const CustomNumberField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Label - aligned to the right
        Container(
          width: double.infinity,
          child: Text(
            label.tr,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF495A71),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Text Field Container
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white70,
            border: Border.all(color: const Color(0xFF9AAEC9), width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between icon and text
            textDirection: TextDirection.rtl, // RTL direction for the row
            children: [
              // Icon on the RIGHT side (first in RTL)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(icon, size: 22, color: const Color(0xFF000047)),
              ),

              // Text field - expands to fill remaining space
              Expanded(
                child: TextField(
                  controller: controller,
                  cursorColor: const Color(0xFF000047),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right, // Right align text
                  textDirection: TextDirection.rtl, // RTL text direction
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: label.tr,
                    hintStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFF495A71),
                    ),
                    hintTextDirection: TextDirection.rtl, // RTL hint text
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}