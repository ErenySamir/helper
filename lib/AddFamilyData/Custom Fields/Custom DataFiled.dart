import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDateField extends StatelessWidget {
  final TextEditingController controller;

  const CustomDateField({
    Key? key,
    required this.controller,
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
            "التاريخ".tr,
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

        // Date Field Container
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white70,
            border: Border.all(color: const Color(0xFF9AAEC9), width: 1.0),
          ),
          child: InkWell(
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF000047),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF000047),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (selectedDate != null) {
                String formattedDate =
                    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                controller.text = formattedDate;
              }
            },
            borderRadius: BorderRadius.circular(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between icon and text
              textDirection: TextDirection.rtl, // RTL direction for the row
              children: [
                // Icon on the RIGHT side (first in RTL)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.calendar_today, size: 22, color: Color(0xFF000047)),
                ),

                // Text field - expands to fill remaining space
                Expanded(
                  child: TextField(
                    controller: controller,
                    cursorColor: const Color(0xFF000047),
                    textAlign: TextAlign.right, // Right align text
                    textDirection: TextDirection.rtl, // RTL text direction
                    enabled: false, // Read-only
                    decoration: InputDecoration(
                      hintText: "التاريخ".tr,
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
        ),
      ],
    );
  }
}