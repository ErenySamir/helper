import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage/HomePage.dart';
import '../Loading/Loading.dart';
import 'SignIn.dart';


class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() {
    return SignUpPagePageState();
  }
}

late AnimationController animationController;
late Animation<double> animation;
//save data to firebase
final TextEditingController _nameController = TextEditingController();
final TextEditingController _phoneNumberController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();
bool _isNavigating = false; // Flag to prevent multiple navigation calls


bool _isPasswordVisible = false;
bool _isPasswordVisibleconfirm = false;


// Function to check if a phone number is valid
bool isValidPhoneNumber(String phoneNumber) {
  // Check if the phone number starts with a valid prefix (e.g., 01, 02, etc.)
  String prefix = phoneNumber.substring(0, 2);
  if (prefix != '01' && prefix != '02' && prefix != '03' && prefix != '04') {
    return false;
  }

  // Check if the phone number has a valid length (e.g., 11 digits)
  if (phoneNumber.length != 11) {
    return false;
  }

  return true;
}
var Phone = '';

class SignUpPagePageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  //send data to firebase
  String? _passwordError;
  void _validatePasswords() {
    setState(() {
      if (_passwordController.text != confirmPasswordController.text) {
        _passwordError = 'يجب ادخال نفس كلمه المرور'; // Passwords do not match
      } else {
        _passwordError = null; // Clear the error when they match
      }
    });
  }
  bool isLoading = false;

  String NameErrorTxT ='';

  void validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        PhoneErrorText = ' يجب ادخال رقم التليفون *'.tr;
        // isLoading=false;
      });
    } else if (value.length < 11) {
      setState(() {
        PhoneErrorText = ' يجب أن يكون رقم الهاتف 11 رقمًا *'.tr;
        // isLoading=false;
      });
    } else {
      setState(() {
        // isLoading=false;
        PhoneErrorText = ''; // No error message for 3-letter names
      });
    }
  }
  Future<void> validatePhonefirebase(String value, BuildContext context) async {
    CollectionReference playerChat = FirebaseFirestore.instance.collection('PersonData');

    QuerySnapshot querySnapshot = await playerChat.where('phone', isEqualTo: value).get();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phone', value);
    print('shared phone ${prefs.getString('phone') ?? ''}');

    // Check if the phone number was found
    if (querySnapshot.docs.isNotEmpty) {
      // Phone number exists, navigate to the Sign-in page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب موجود بالفعل برجاء تسجيل الدخول', // "This account already exists. Please sign in."
            textAlign: TextAlign.center,
          ),
          backgroundColor:  Color(0xFF000047),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
      );
      print('Phone number exists, navigating to Sign-in page');
    } else {
      // Phone number does not exist, proceed to send data and call verifyPhone
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تسجيل الدخول بنجاح', // "Successfully registered"
            textAlign: TextAlign.center,
          ),
          backgroundColor:  Color(0xFF000047),
        ),
      );
      _sendData();
      // Call verifyPhone to initiate OTP verification
      await verifyPhone(value.trim(), context);  // Pass context here
    }
  }

  Future<void> verifyPhone(String phone, BuildContext context) async {
    print('verificationIddd' + '2${phone}');
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
    String? verificationId; // Variable to store verificationId

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+2$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
          print('User signed in automatically');
          // Optionally, navigate to the home page or dashboard here
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
          // Optionally, show a SnackBar or dialog to inform the user
        }
        // Regardless of failure, navigate to OTP page with empty verificationId
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => OTP('', phone, "regest", _nameController.text)),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
      codeSent: (String sentVerificationId, int? forceResendingToken) {
        verificationId = sentVerificationId; // Store the sent verificationId
        print('verificationIddd$verificationId');

        // Navigate to the OTP page
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => OTP(verificationId!, phone, "regest", _nameController.text)),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        log("codeAutoRetrievalTimeout $verificationID");
        log("codeAutoRetrievalTimeout");
        // You can also navigate here if desired
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => OTP('', phone, "regest", _nameController.text)),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
      // timeout: const Duration(seconds: 60),
    );
  }

  void _sendData() async {
    final name = _nameController.text;
    final phoneNumber = _phoneNumberController.text;
    final password = _passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    if (name.isNotEmpty && phoneNumber.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
      // Add data to Firestore and get the document reference
      DocumentReference docRef = await FirebaseFirestore.instance.collection('PersonData').add({
        'name': name,
        'phone': phoneNumber,
        'password': password,
        'confirmpass': confirmPassword,
      });

      // Get the document ID of phone number
      String docId = docRef.id;
      print("Document ID: $docId");
      // prefs.setString('AdminId', docId);

      // Clear the text fields
      _nameController.clear();
      _phoneNumberController.clear();
      _passwordController.clear();
      confirmPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب حدث به خطا', // "There was an error with this account"
            textAlign: TextAlign.center,
          ),
          backgroundColor:  Color(0xFF000047),
        ),
      );
    }
  }

  @override
  void initState() {
    _checkConnectivity();
    // Define animation controller
    // animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 2), // Adjust the duration as needed
    // );
    // Future.delayed(Duration(seconds: 2), () {});
    //
    // // Define animation
    // animation = Tween<double>(begin: 0.5, end: 1.0).animate(
    //   CurvedAnimation(
    //     parent: animationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );

    // Start the animation
    // animationController.forward();
  }

  @override
  void dispose() {
    // animationController.dispose();
    // confirmPasswordController.dispose();
    // _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _isConnected
              ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15,right: 22,left: 22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

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
                            text: 'الأسم ',
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
                          Expanded(
                            child:TextField(
                              controller: _nameController,
                              cursorColor:  Color(0xFF000047),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.right, // Align text to the right
                              decoration: InputDecoration(
                                hintText: 'الأسم'.tr,
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF495A71),
                                ),
                                border: InputBorder.none,
                              ),

                              onEditingComplete: () async {
                                // Move focus to the next text field
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(
                              Icons.person_outlined,
                              size: 22,
                              color:  Color(0xFF000047),
                            ),

                          ),
                        ],
                      ),
                    ),
                    if (_nameController.text.length >0 && _nameController.text.length <2)
                      Text(
                        // textAlign: TextAlign.end,
                        "برجاء ادخال الاسم",
                        style: TextStyle(
                          color: Colors.red.shade900, // Error message color
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
                        ),
                      ),
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
                            text: 'رقم التليفون ',
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
                          Expanded(
                            child: TextField(
                              controller: _phoneNumberController,
                              cursorColor:  Color(0xFF000047),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                              ],
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.datetime, // Updated keyboard type for phone input
                              textAlign: TextAlign.right, // Align text to the right
                              decoration: InputDecoration(
                                hintText: 'رقم التليفون'.tr,
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF495A71),
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                Phone = value;
                                print("phoneeee" + " " + Phone);
                                setState(() {
                                  validatePhone(value);
                                });
                              },
                              onSubmitted: (value) {
                                // Move focus to the next text field
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child:Icon(
                              Icons.phone,
                              size: 22,
                              color:  Color(0xFF000047),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (PhoneErrorText.isNotEmpty)
                      Text(
                        PhoneErrorText,
                        style: TextStyle(
                          color: Colors.red.shade900, // Error message color
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
                        ),
                      ),


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
                          color: Color(0xFF9AAEC9),
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              color: Color(0xFF495A71),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                              });
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              cursorColor:  Color(0xFF000047),
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
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            height: 25,
                            width: 25,
                            child:
                            Icon(
                              Icons.key_off,
                              size: 22,
                              color:  Color(0xFF000047),
                            ),
                          ),
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
                      softWrap: false,
                      // textAlign: TextAlign.right,
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
                            text: 'تأكيد كلمة المرور  ', // Full text
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
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              _isPasswordVisibleconfirm ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              color: Color(0xFF495A71),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisibleconfirm = !_isPasswordVisibleconfirm; // Toggle visibility
                              });
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: confirmPasswordController,
                              cursorColor: Color(0xFF000047),
                              textInputAction: TextInputAction.done, // Change action to done for the last field
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.right,
                              obscureText: !_isPasswordVisibleconfirm, // Toggle password visibility
                              decoration: InputDecoration(
                                hintText: 'تأكيد كلمة المرور'.tr,
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF495A71),
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) {
                                // Close the keyboard when done
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            height: 25,
                            width: 25,
                            child: Icon(
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


                    //btttttttttttttttttn
                    GestureDetector(
                      onTap: () async {
                        // Check if any field is empty or if the passwords do not match
                        if (_nameController.text.isEmpty ||
                            _phoneNumberController.text.isEmpty ||
                            _passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty ||
                            _passwordController.text != confirmPasswordController.text) {
                          setState(() {
                            // Show a SnackBar with the error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'برجاء ادخال جميع البيانات', // "Please enter all the data"
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor:  Color(0xFF000047),
                              ),
                            );
                            // Ensure `isLoading` is set to false when there's a validation error
                            isLoading = false;
                          });
                        }
                        else if (!isValidPhoneNumber(_phoneNumberController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textAlign: TextAlign.center,
                                'رقم الهاتف غير صحيح'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              backgroundColor:  Color(0xFF000047),
                            ),
                          );
                        }

                        else {
                          setState(() {
                            // Clear any existing error message
                            _passwordError = null;
                            isLoading = true;  // Set loading to true since we're starting an operation
                          });

                          // Prevent multiple navigation attempts
                          if (!_isNavigating) {
                            _isNavigating = true; // Set the flag to true

                            // Validate phone number in Firestore
                            await validatePhonefirebase(_phoneNumberController.text.trim(), context);

                            // Reset the flag after operation completes
                            _isNavigating = false;
                          }

                          setState(() {
                            isLoading = true;  // Set loading to false after the operation completes
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0, right: 20, left: 20),
                        child: Container(
                          height: 50,
                          width: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            shape: BoxShape.rectangle,
                            color:  Color(0xFF000047), // Background color of the container
                          ),
                          child: Center(
                            child: Text(
                              'إنشــــاء حســــــاب'.tr,
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
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SigninPage()),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center, // Center the text within the container
                        child: Text(
                          "تسجيل دخول".tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000047), // Text color
                            decoration: TextDecoration.underline, // Adds the underline
                            decorationColor:  Color(0xFF000047), // Underline color to match text color
                            decorationThickness: 1.0, // Optional: Thickness of the underline
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                  ]
              ),

            ),

          ) : SizedBox.shrink(),
          (isLoading == true)
              ? const Positioned(top: 0, child: Loading())
              : Container(),
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
            backgroundColor: Colors.red.shade700,
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