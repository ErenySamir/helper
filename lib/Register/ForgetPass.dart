import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:shared_preferences/shared_preferences.dart';

import 'ChangePass.dart';

class ForgetPassword extends StatefulWidget {

  State<ForgetPassword> createState() {
    return ForgetPasswordState();
  }


}
class ForgetPasswordState extends State<ForgetPassword>
    with SingleTickerProviderStateMixin {
  var Phone = '';

  String PhoneErrorText = '';

  final PhoneController = TextEditingController();
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
  @override
  void initState() {
    // validatePhonefirebase(widget.phonenum);
  }

  Future<void> verifyPhone(String phone) async {
    print('verificationIddd  ' + '+2$phone');
    if(phone.startsWith("011")||phone.startsWith("015")){
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => HomePage(),
      //   ),
      // );
    }
    else{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+2$phone',

        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
            print("Successfully signed in with auto-retrieval.");
            // You might want to navigate directly to the home page or similar
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.code}");
          if (e.code == 'invalid-phone-number') {
            print("The phone number entered is invalid!");
          }
          // Handle error
        },
        codeSent: (String verificationId, int? forceResendingToken) async {
          print('Verification code sent to $phone');
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => OTP(verificationId, phone, '', ''),
          //   ),
          // );
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          print("Auto retrieval timeout for verification ID: $verificationID");
        },
        timeout: const Duration(seconds: 60),
      );

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
      //    else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(
      //         textAlign: TextAlign.start,
      //         'رقم الهاتف غير موجود برجاء عمل حساب'.tr,
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontFamily: 'Cairo',
      //           fontWeight: FontWeight.w700,
      //         ),
      //       ),
      //       backgroundColor:  Color(0xFF000047),
      //     ),
      //   );
      //     break;
      //   }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                  'نسيت كلمة المرور'.tr,
                  style: TextStyle(
                    color:  Color(0xFF000047),
                    fontFamily: 'Cairo',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'رقم التليفون'.tr,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)
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
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: TextField(
                          controller: PhoneController,
                          cursorColor:Color(0xFF064821),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(11),
                          ],
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
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
                            print("phoneeee" + value + " " + Phone);
                            setState(() {
                              validatePhone(value);

                            });
                          },

                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                      Icon(
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
                  // textAlign: TextAlign.end,
                  PhoneErrorText,
                  style: TextStyle(
                    color: Colors.red.shade900, // Error message color
                    fontSize: 12.0,
                    fontFamily: 'Cairo',
                  ),
                ),
              SizedBox(height: 5,),
              //passssssssssssssssssssword
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () async {
                  String phoneNumber = PhoneController.text;
                  if (phoneNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          textAlign: TextAlign.center,
                          'يجب ادخال بيانات'.tr,
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
                  else if (!isValidPhoneNumber(phoneNumber)) {
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
                    // validatePhonefirebase(PhoneController.text);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString('phonevalid', PhoneController.text);

                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePassword(),
                        ),
                      );
                    });
                  }
                },

                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0,right: 20,left: 20),
                  child: Container(
                    height: 50,
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      shape: BoxShape.rectangle,
                      color:  Color(0xFF000047), // Background color of the container
                      // border: Border.all(
                      //   width: 1.0, // Border width
                      //   color: Colors.black
                      // ),
                    ),
                    child: Center(
                      child: Text(
                        "إعادة تعيين".tr,
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
            ],
          ),
        ),
      ),
    );
  }

}