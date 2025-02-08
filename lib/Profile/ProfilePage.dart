import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import '../HomePage/HomePage.dart';
import '../Loading/Loading.dart';
import '../Register/Model/UserModel.dart';
import '../Register/SignIn.dart';

class Profilepage extends StatefulWidget {
  String docId;
  Profilepage({required this.docId});
  @override
  State<Profilepage> createState() {
    return ProfilepageState();
  }
}

class ProfilepageState extends State<Profilepage>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  bool _isButtonDisabled = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();


  bool _isLoading = true; // flag to control shimmer effect
  Future<void> _loadData() async {
    // load data here
    await Future.delayed(Duration(seconds: 2)); // simulate data loading
    setState(() {
      _isLoading = false; // set flag to false when data is loaded
    });
  }


  Future<void> _updateName(String name) async {
    CollectionReference usersRef =
    FirebaseFirestore.instance.collection('PersonData');
    setState(() {
      _isLoading = true;
    });
    try {
      // Query the Firestore database to find the user's document based on their phone number
      QuerySnapshot querySnapshot =
      await usersRef.where('phone', isEqualTo: _phoneNumberController.text).get();
      String existingName = userDataa[0].name!;
      if (name == existingName) {
        print("Name is already up to date");
      }

      else{
        if (querySnapshot.docs.isNotEmpty) {
          // Update the user's document with the new image URL
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          await documentSnapshot.reference.update({
            'name': name,
            'phone': _phoneNumberController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حفظ التعديل بنجاح',
                textAlign: TextAlign.center,
              ),
              backgroundColor: Color(0xFF000047),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
          print('User  data updated successfully.');
          setState(() {
            _isLoading = false;
          });
        }

        else {
          // If the user's document is not found, create a new document
          await usersRef.add({
            'name': name,
            'phone': _phoneNumberController.text,

          });
          print('User  data added successfully.');

        }
        setState(() {
          _isLoading = false;
        });
      }
    }
    catch (e) {
      print('Error updating user data: $e');
    }
  }
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      await getUserByPhone(phoneValue);
    } else if (user?.phoneNumber != null) {
      await getUserByPhone(user!.phoneNumber.toString());
    } else {
      print("No phone number available.");
    }
  }
  List<UserData> userDataa = [];

  Future<void> getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection('PersonData');

      QuerySnapshot querySnapshot = await playerchat
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
        querySnapshot.docs.first.data() as Map<String, dynamic>;
        UserData user = UserData.fromMap(userData);

        // Update the list and UI inside setState
        setState(() {
          userDataa.add(user);
        });
      } else {
        print("User not found with phone number $phoneNumber");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SigninPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Error getting user: $e");
    }
  }
  Future<void> getPeopleData(String iiid) async {
    // Clear the current PeopleData list to ensure fresh data is fetched
    userDataa.clear();

    try {
      CollectionReference peopleData = FirebaseFirestore.instance.collection("PersonData");
      QuerySnapshot querySnapshot = await peopleData.get();

      // Check if there are any documents in the query
      if (querySnapshot.docs.isNotEmpty) {
        bool isMatchFound = false; // Flag to check if any matching document is found

        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          UserData user = UserData.fromMap(userData);
          // user. = document.id;

          // Add the user data to PeopleData if the document ID matches
          if (user.phoneNumber == widget.docId) {
            isMatchFound = true; // Set the flag to true
            userDataa.add(user);

            // Populate the controllers with the first item's data
            _nameController.text = user.name ?? '';
            _phoneNumberController.text = user.phoneNumber ?? '';
          }
        }

        // Clear the controllers if no match is found
      } else {
        // Clear all controllers if no documents are found
        _nameController.clear();
        _phoneNumberController.clear();

      }
    } catch (e) {
      // Uncomment if you want error logging
      // print("Error getting people data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
    getPeopleData(widget.docId);
    // Now you can access the user1 list
    // print('User data44444: ${user1[0].name}');
    setState(() {}); // Call setState to rebuild the widget tree
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0, bottom: 12, right: 8, left: 8),
          // Add padding to the top of the title
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "الملف الشخصى".tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            // Center the title horizontally
            leading: IconButton(
              onPressed: () {
                Map<dynamic, dynamic>? arguments = ModalRoute.of(context)
                    ?.settings
                    .arguments as Map<dynamic, dynamic>?; // Explicit casting

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );

              },
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios_new_rounded,
                size: 24,
                color: Color(0xFF62748E),
              ),
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
            children:[ SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 15.0, bottom: 15, right: 22, left: 22),
                child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF495A71)),
                          children: [
                            TextSpan(
                              text: 'الأسم ',
                            ),
                          ],
                        ),
                      ),
                      Text("")
                    ],
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
                            controller: _nameController,
                            cursorColor: Color(0xFF000047),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.right,
                            // Align text to the right
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
                      ],
                    ),
                  ),
                  if (_nameController.text.length > 0 &&
                      _nameController.text.length < 2)
                    Text(
                      // textAlign: TextAlign.end,
                      "برجاء ادخال الاسم",
                      style: TextStyle(
                        color: Colors.red.shade900, // Error message color
                        fontSize: 12.0,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  //phone
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF495A71)),
                          children: [
                            TextSpan(
                              text: 'رقم التليفون ',
                            ),
                          ],
                        ),
                      ),
                      Text(""),
                    ],
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
                            readOnly: true,
                            // cursorColor: Color(0xFF064821),
                            // inputFormatters: [
                            //   LengthLimitingTextInputFormatter(11),
                            // ],
                            // textInputAction: TextInputAction.done,
                            // keyboardType: TextInputType.none, // Updated keyboard type for phone input
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,

                            // Align text to the right
                            decoration: InputDecoration(
                              hintText: 'رقم التليفون'.tr,
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              // Phone = value;
                              // print("phoneeee" + " " + Phone);
                              // setState(() {
                              //   validatePhone(value);
                              // });
                            },
                            onSubmitted: (value) {
                              // Move focus to the next text field
                              // FocusScope.of(context).nextFocus();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (PhoneErrorText.isNotEmpty)
                    Text(
                      PhoneErrorText,
                      textDirection: TextDirection.ltr,

                      style: TextStyle(
                        color: Colors.red.shade900, // Error message color
                        fontSize: 12.0,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  SizedBox(
                    height: 100,
                  ),

                  //btttttttttttttttttn
                  GestureDetector(
                    onTap: () async {
                      if (_isButtonDisabled) return;

                      setState(() {
                        _isButtonDisabled = true; // Disable the button
                        // _isLoading = true; // Start loading
                      });

                      try {
                        await _updateName(_nameController.text);

                      } catch (e) {
                        // Handle any errors here
                        print('Error: $e');
                      } finally {
                        setState(() {
                          _isLoading = false; // End loading state
                          _isButtonDisabled = false; // Re-enable the button
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
                          color: Color(0xFF000047), // Background color of the container
                        ),
                        child: Center(
                          child: Text(
                            'حفــــــظ'.tr,
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
                  SizedBox(
                    height: 5,
                  ),
                ]),
              ),
            ),
              ( _isLoading == true)
                  ? const Positioned( child: Loading())
                  : Container(height: 5,),
            ]
        ),),
    );
  }

}