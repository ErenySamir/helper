import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool isRequired;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.isRequired = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Align everything to the right
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
              // Icon on the right side
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(icon, size: 22, color: const Color(0xFF000047)),
              ),

              // Text field - expands to fill remaining space
              Expanded(
                child: TextFormField(
                  controller: controller,
                  cursorColor: const Color(0xFF000047),
                  textInputAction: TextInputAction.next,
                  keyboardType: keyboardType,
                  textAlign: TextAlign.right, // Align text to the right
                  textDirection: TextDirection.rtl, // RTL text direction
                  inputFormatters: maxLength != null
                      ? [LengthLimitingTextInputFormatter(maxLength)]
                      : null,
                  validator: validator,
                  decoration: InputDecoration(
                    hintText: label.tr,
                    hintStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFF495A71),
                    ),
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    errorStyle: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Cairo',
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}