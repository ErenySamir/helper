import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:helper/AddFamilyData/AddFamilyData.dart';
import 'package:helper/AddFamilyData/Model/FamilyModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Register/Model/UserModel.dart';
import '../Register/SignIn.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  List<UserData> userDataa = [];
  List<FamilyModel> familyAllData = [];

   getAlldata() async {

      CollectionReference playerchat = FirebaseFirestore.instance.collection("PeopleData");
      // Fetch playgrounds where AdminId matches the retrieved docId
      QuerySnapshot playgroundSnapshot = await playerchat.get();

      if (playgroundSnapshot.docs.isNotEmpty) {
        setState(() {
          familyAllData.clear(); // Clear previous data to avoid duplicates
          for (var document in playgroundSnapshot.docs) {
            Map<String, dynamic> userData =
                document.data() as Map<String, dynamic>;
            FamilyModel familyAllDataa = FamilyModel.fromMap(userData);

            familyAllDataa.Id = document.id; // Store the document ID in the model
            familyAllData.add(familyAllDataa); // Add playground to the list
            // print("Stored document ID in model: ${familyAllDataa.Id}");
          }
        });
      } else {
        print("No playgrounds found for this AdminId.");
      }

  }

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

  @override
  void initState() {
    super.initState();
    _initializeState();
    getAlldata();
    // _loadUserData();
  }

  @override
  void dispose() {

    super.dispose();
  }

  Future<void> _initializeState() async {
    // Perform async initialization here
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("phonnnnnnnnnnnne$phoneValue");
    if (phoneValue != null) {
      getUserByPhone(phoneValue);
    }
  }

  late List<UserData> user = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 14.0, right: 12, top: 66),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        userDataa.isNotEmpty && userDataa[0].name!.isNotEmpty
                            ? Text(
                                userDataa[0].name!,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF000047),
                                ),
                              )
                            : Container(),
                        Text(
                          "  مرحبا بك  ",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ]),
                ),
                familyAllData.isNotEmpty
                    ? ListView.builder(
                        itemCount: familyAllData.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          // key: ValueKey(playgroundbook[index].groundID!); // Using ValueKey with item value
                          getAlldata();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      right: 22.0,
                                      left: 22,
                                      top: 6,
                                      bottom: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        print(
                                            "iddddddddddd  ${familyAllData[index].Id!}");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddFamilyData(
                                                docId: familyAllData[index].Id!),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 140,
                                        // constraints: BoxConstraints(maxHeight: 133), // Set a reasonable max height
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Color(0xFFF0F6FF),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8, right: 18, left: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [

                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                    children: [
                                                      Icon(Icons.edit),

                                                      Text(
                                                          "   اسم العائلة :  " +
                                                              familyAllData[index]
                                                                  .familyName!,
                                                          style: TextStyle(
                                                              fontFamily: 'Cairo',
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight.w700,
                                                              color: Color(
                                                                  0xFF000047))),

                                                    ],
                                                  ),
                                                  Text(
                                                      " تاريخ العطية : " +
                                                          familyAllData[index]
                                                              .date!,
                                                      style: TextStyle(
                                                          fontFamily: 'Cairo',
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                              0xFF000047))),
                                                  Text(
                                                      " العطية : " +
                                                          familyAllData[index]
                                                              .give!,
                                                      style: TextStyle(
                                                          fontFamily: 'Cairo',
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                              0xFF000047))),
                                                  Text(
                                                      "  اسم المعطي :  " +
                                                          familyAllData[index]
                                                              .giverName!,
                                                      style: TextStyle(
                                                          fontFamily: 'Cairo',
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                              0xFF000047))),
                                                  Text(
                                                      familyAllData[index]
                                                              .date! +
                                                          ": بتاريخ ",
                                                      style: TextStyle(
                                                          fontFamily: 'Cairo',
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                              0xFF000047))),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))),
                            ],
                          );
                        })
                    : Container(
                        child: Text(
                        "لم تتم اضافه اي بيانات حتي الان ",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000047),
                        ),
                      )),
                ///////////////////////// design bsssssssssssssssss
                ///UUUUUUU
                SizedBox(height: 55),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 49,
        width: 49,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddFamilyData(
                        docId: '',
                      )),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 26,
          ),
          backgroundColor: Color(0xFF000047),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30), // Adjust the circular shape here
          ),
          // elevation: 6.0, // Adjust the elevation if needed
        ),
      ),
    );
  }
}
