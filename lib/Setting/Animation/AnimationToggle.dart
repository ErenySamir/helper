import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../Controller/Controller.dart';

class AnimatedToggle extends StatefulWidget {
  final List<String> values;
  final ValueChanged onToggleCallback;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;

  AnimatedToggle({
    required this.values,
    required this.onToggleCallback,
    this.backgroundColor = const Color(0xFFe7e7e8),
    this.buttonColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF000000),
  });
  @override
  _AnimatedToggleState createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  //var initialPosition = true.obs;
  late bool initialPosition;
  final GetStorage storage = GetStorage();
  @override
  void initState() {
    super.initState();
    // Adjust based on the controller’s currentLanguage
    initialPosition = Get.find<SettingController>().currentLanguage.value == 'ar';
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.5,
      height: Get.width * 0.11,
      margin: EdgeInsets.all(20),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                initialPosition = !initialPosition;
                var index = initialPosition ? 1 : 0; // 1 for Arabic, 0 for English
                widget.onToggleCallback(index);
              });
            },
            // onTap: () {
            //   initialPosition.value = !initialPosition.value;
            //   var index = 0;
            //   if (!initialPosition.value) {
            //     index = 1;
            //   }
            //   widget.onToggleCallback(index);
            //   setState(() {});
            // },
            child: Container(
              width: Get.width * 0.5,
              height: Get.width * 0.11,
              decoration: ShapeDecoration(
                color: widget.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  widget.values.length,
                      (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                    child: Text(
                      widget.values[index],
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: Get.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xAA000000),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          storage.read('lang') == 'ar'?
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment: initialPosition? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: Get.width * 0.25,
              height: Get.width * 0.11,
              decoration: ShapeDecoration(
                color: widget.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                // storage.read('lang') == 'ar'?
                initialPosition ? widget.values[1] : widget.values[0],
                //: initialPosition ? widget.values[0] : widget.values[1],
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: Get.width * 0.045,
                  color: widget.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: Alignment.center,
            ),
          ):AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment: initialPosition? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: Get.width * 0.25,
              height: Get.width * 0.11,
              decoration: ShapeDecoration(
                color: widget.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                // storage.read('lang') == 'ar'?
                // initialPosition ? widget.values[1] : widget.values[0]:
                initialPosition ? widget.values[1] : widget.values[0],
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: Get.width * 0.045,
                  color: widget.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}