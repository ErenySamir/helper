import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage/HomePage.dart';
import '../Loading/Loading.dart';
import 'SignUp.dart';
class ChangePassword extends StatefulWidget {

  State<ChangePassword> createState() {
    return ChangePasswordState();
  }


}
class ChangePasswordState extends State<ChangePassword>
    with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isPasswordVisibleconfirm = false;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? _passwordError;
  bool isLoading = false;

  void _updateData() async {
    // setState(() {
    //   isLoading = true; // Start loading
    // });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String v_phone=   prefs.getString('phonevalid').toString();
    final phoneNumber=v_phone;
    final password = _passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (phoneNumber.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
      await FirebaseFirestore.instance.collection('PersonData').where('phone', isEqualTo: phoneNumber).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'password': password,
            'confirmpass': confirmPassword,
          });
          // isLoading = false;
        } else {
          // setState(() {
          //   isLoading = true; // Start loading
          // });
          // Handle the case where the phone number is not found in the database
        }
      });
    } else {
      // Handle the case where the input fields are empty
    }
  }
  void _validatePasswords() {
    setState(() {
      if (_passwordController.text != confirmPasswordController.text) {
        _passwordError = 'يجب ادخال نفس كلمه المرور'; // Passwords do not match
      } else {
        _passwordError = null; // Clear the error when they match
      }
    });
  }
  @override
  void initState() {
    _checkConnectivity();
    // validatePhonefirebase(widget.phonenum);
  }

  Future<void> verifyPhone(String phone) async {
    print('verificationIddd  ' + '+2$phone');
    if(phone.startsWith("011")||phone.startsWith("015")){
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('phonev','+2$phone');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
    else{
      _updateData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تغيير كلمة المرور بنجاح', // "Please enter all the data"
            textAlign: TextAlign.center,
          ),
          backgroundColor:  Color(0xFF000047),
        ),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()


          ));
    }

  }


  bool startsWith015or011(String input) {
    return input.startsWith('015') || input.startsWith('011');
  }

  void validatePhonefirebase(String value) async {
    CollectionReference playerchat = FirebaseFirestore.instance.collection('PersonData');
    QuerySnapshot querySnapshot = await playerchat.get();

    bool phoneFound = false;

    for (var doc in querySnapshot.docs) {
      print("dddddd${doc['phone']}");
      if (doc['phone'] == value) {
        phoneFound = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('phone', value);

        // Start the phone verification process
        await verifyPhone(value);

        break;
      }
      //  else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       textAlign: TextAlign.start,
      //       'رقم الهاتف غير موجود برجاء عمل حساب'.tr,
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontFamily: 'Cairo',
      //         fontWeight: FontWeight.w700,
      //       ),
      //     ),
      //     backgroundColor: Color(0xFF1F8C4B),
      //   ),
      // );
      //   break;
      // }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _isConnected
              ?SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15,right: 22,left: 22),
              child: Column(
                crossAxisAlignment:CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 65.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 135,
                        height: 160.72,
                        child: Image.asset('assets/images/splach.png'),
                      ),
                    ),
                  ),
                  SizedBox(height: 16,),

                  Center(
                    child: Text(
                      'تغيير كلمة المرور'.tr,
                      style: TextStyle(
                        color: Color(0xFF000047),
                        fontFamily: 'Cairo',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF495A71)
                      ),
                      children: [
                        WidgetSpan(
                          child: Text(
                            '  *  ',
                            style: TextStyle(
                              color: Colors.red.shade800, // Red color for the asterisk
                            ),
                          ),
                        ),
                        TextSpan(
                          text: 'كلمة المرور ',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      shape: BoxShape.rectangle,
                      color: Colors.white70,
                      border: Border.all(
                        color: Color(0xFF9AAEC9), // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 8,),
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off_outlined,
                            color: Color(0xFF495A71),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                            });
                          },
                        ),
                        // Spacer(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: TextField(
                              controller: _passwordController,
                              cursorColor: Color(0xFF064821),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.right,
                              obscureText: !_isPasswordVisible, // Toggle password visibility
                              decoration: InputDecoration(
                                hintText: 'كلمة المرور'.tr,
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF495A71),
                                ),
                                border: InputBorder.none,
                              ),

                              onSubmitted: (value) {
                                // Move focus to the next text field
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            height: 25,
                            width: 25,
                            child:
                            Icon(
                              Icons.key_off,
                              size: 22,
                              color:  Color(0xFF000047),
                            ),                          ),
                      ],
                    ),
                  ),
                  if (_passwordController.text.length > 0 && _passwordController.text.length < 6)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // Adjust padding as needed
                      child: Text(
                        'برجاء ادخال كلمه المرور قوية *', // Provide a default error message if _passwordError is null
                        style: TextStyle(
                          color: Colors.red.shade900, // Error message color
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  //confirm paswooooooooooooooooooooooooord
                  //passssssssssssssssssssword
                  SizedBox(
                    height: 12,
                  ),
                  RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF495A71)
                      ),
                      children: [
                        WidgetSpan(
                          child: Text(
                            '  *  ',
                            style: TextStyle(
                              color: Colors.red.shade800, // Red color for the asterisk
                            ),
                          ),
                        ),
                        TextSpan(
                          text: 'تأكيد كلمة المرور  ',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      shape: BoxShape.rectangle,
                      color: Colors.white70,
                      border: Border.all(
                        color: Color(0xFF9AAEC9),
                        width: 1.0,
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 8,),
                        IconButton(
                          icon: Icon(
                            _isPasswordVisibleconfirm
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off_outlined,
                            color: Color(0xFF495A71),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisibleconfirm = !_isPasswordVisibleconfirm; // Toggle visibility
                            });
                          },
                        ),
                        // Spacer(),

                        Expanded(
                          child: TextField(
                            controller: confirmPasswordController,
                            cursorColor: Color(0xFF064821),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.right, // Align text to the right
                            obscureText: !_isPasswordVisibleconfirm, // Toggle password visibility

                            // obscureText: false, // Hide password input
                            decoration: InputDecoration(
                              hintText: 'تأكيد كلمة المرور'.tr,
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              _validatePasswords(); // Call validation on input change
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          height: 25,
                          width: 25,
                          child:   Icon(
                            Icons.key_off,
                            size: 22,
                            color:  Color(0xFF000047),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_passwordController.text != confirmPasswordController.text && confirmPasswordController.text.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // Adjust padding as needed
                      child: Text(
                        'برجاء ادخال نفس كلمه المرور*', // Provide a default error message if _passwordError is null
                        style: TextStyle(
                          color: Colors.red.shade900, // Error message color
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),

                  GestureDetector(
                    onTap: () async {
                      if (
                          _passwordController.text != confirmPasswordController.text) {
                        setState(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'برجاء ادخال نفس كلمة المرور  ', // "Please enter all the data"
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.red.shade900,
                            ),
                          );
                          isLoading = false;
                        });
                        return; // Exit early if validation fails
                      }

                      setState(() {
                        isLoading = true; // Set loading state only if validation passes
                      });

                      await verifyPhone(Phone);

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String v_phone = prefs.getString('phonevalid') ?? "";

                      validatePhonefirebase(v_phone);
                    },

                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0,right: 20,left: 20),
                      child: Container(
                        height: 50,
                        width: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          shape: BoxShape.rectangle,
                          color: Color(0xFF000047), // Background color of the container
                          // border: Border.all(
                          //   width: 1.0, // Border width
                          //   color: Colors.black
                          // ),
                        ),
                        child: Center(
                          child: Text(
                            "تأكيد".tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()),
                        );
                      });
                    },

                    child: Container(
                      alignment: Alignment.center, // Center the text within the container
                      child: Text(
                        'إنشــــاء حســــــاب'.tr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000047), // Text color
                          decoration: TextDecoration.underline, // Adds the underline
                          decorationColor: Color(0xFF000047), // Underline color to match text color
                          decorationThickness: 1.0, // Optional: Thickness of the underline
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ): SizedBox.shrink(),
          (isLoading == true)
              ? const Positioned(top: 0, child: Loading())
              : Container(height: 5,),
          if (!_isConnected) _buildNoConnectionOverlay(),
        ],
      ),
    );
  }
  Widget _buildNoConnectionOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.8), // Semi-transparent overlay
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/internet.png',
                height: 140,
                width: 140,
              ),
            ),
            SizedBox(height: 16,),
            Text(
              'انت غير متصل بالانترنت',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF181A20),
                fontSize: 14.62,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w500,
                height: 0.10,
                letterSpacing: 0.17,
              ),
            ),
          ],
        ),
      ),
    );
  }
  bool _isConnected = true; // Flag to check connectivity
  Future<void> _checkConnectivity() async {
    // Initial check
    await _updateConnectionStatus();

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) async {
      await _updateConnectionStatus();
    });
  }

  Future<void> _updateConnectionStatus() async {
    bool isConnected = await _hasNetworkAccess();
    if (_isConnected != isConnected) {
      setState(() {
        _isConnected = isConnected;
      });

      if (!_isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يوجد اتصال بالإنترنت',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            backgroundColor:  Colors.red.shade900,
          ),
        );
      }
    }
  }

  Future<bool> _hasNetworkAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}