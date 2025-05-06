import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helper/AddFamilyData/AddFamilyData.dart';
import 'package:helper/AddFamilyData/Model/FamilyModel.dart';
import 'package:helper/Profile/ProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ButtomNavigation/CustomButtomNavigation/ButtomNavigation.dart';
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
  String? docId;
  Future<void> getAlldata() async {
    CollectionReference playerchat = FirebaseFirestore.instance.collection("PeopleData");

    try {
      QuerySnapshot playgroundSnapshot = await playerchat.get();

      if (!mounted) return; // Ensure the widget is still in the tree before modifying state

      if (playgroundSnapshot.docs.isNotEmpty) {
        setState(() {  // Safely update UI
          familyAllData.clear();
          for (var document in playgroundSnapshot.docs) {
            Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
            FamilyModel familyAllDataa = FamilyModel.fromMap(userData);
            familyAllDataa.Id = document.id;
            familyAllData.add(familyAllDataa);
          }
        });
      } else {
        print("No playgrounds found for this AdminId.");
      }
    } catch (e) {
      print("Error getting user: $e");
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
        var doc = querySnapshot.docs.first;
         docId = doc.id; // ✅ Get the document ID here
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        UserData user = UserData.fromMap(userData);

        print("Document ID: $docId");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('docIid', docId!);

        // Update the list and UI
        setState(() {
          userDataa.add(user);
        });

        // If you want to use docId later, consider storing it in a variable or controller
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
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // This exits the app
        return false;
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only( right: 12, top: 66),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 14.0, right: 16, top: 10,left: 15),
                          child: GestureDetector(
                            onTap:(){
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => Profilepage(docId: userDataa[0].phoneNumber!,),
                              //   ),
                              // );
                              FocusScope.of(context).requestFocus(FocusNode());
                              // if (controller.formKey.currentState!.validate()) {
                              Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CustomNavigationBar(current: 1,),
                                ),);
                            },
                            child: userDataa.isNotEmpty && userDataa[0].name!.isNotEmpty
                                ? Text(
                              userDataa[0].name!.length > 30
                                  ? '${userDataa[0].name!.substring(0, 30)}..'
                                  : userDataa[0].name!,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000047),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                                : Container(),
                          ),

                        ),
                        Text(
                          "  مرحبا بك  ".tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000047),
                          ),
                        ),

                      ],
                    ),
                  ),

                  familyAllData.isNotEmpty
                      ? ListView.builder(
                    itemCount: familyAllData.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final familyItem = familyAllData[index];

                      return Dismissible(
                        key: ValueKey(familyItem.Id), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe from right to left
                        background: Container(
                          color: Colors.red.shade900,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white, size: 20),
                        ),
                        confirmDismiss: (direction) async {
                          // Show confirmation dialog before deleting
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("تأكيد الحذف".tr),
                              content: Text("هل أنت متأكد أنك تريد حذف هذه العائلة؟".tr),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text("إلغاء".tr,style: TextStyle(color: Color(0xFF000047))),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    print("familyItem.Id!${familyItem.Id!}");
                                    await deleteCancelByPhoneAndPlaygroundId(familyItem.Id!);
                                    Navigator.of(context).pop(true);
                                    },
                                  child: Text("حذف".tr, style: TextStyle(color: Colors.red.shade900)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          // Delete from Firebase
                          await FirebaseFirestore.instance
                              .collection('familyCollection') // Change to your actual collection name
                              .doc(familyItem.Id)
                              .delete();

                          // Remove from local list
                          setState(() {
                            familyAllData.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("تم حذف العائلة بنجاح".tr), backgroundColor:  Color(0xFF000047),),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 22.0, left: 22, top: 6, bottom: 10),
                          child: GestureDetector(
                            onTap: () {
                              print("iddddddddddd  ${familyItem.Id}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddFamilyData(familyItem.Id!, docId!),
                                ),
                              );
                            },
                            child: Container(
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade200,
                                    Colors.blue.shade50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8, right: 18, left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.edit),
                                        Text(
                                          "   أسم العائلة :  ".tr +
                                              // + familyItem.familyName!,
                                            (familyItem.familyName!.length > 30
                                              ? '${familyItem.familyName!.substring(0, 30)}..'
                                              : familyItem.familyName!),
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF000047),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      " تاريخ العطية : ".tr +
                                          // familyItem.date!,
                                          (familyItem.date!.length > 30
                                              ? '${familyItem.date!.substring(0, 30)}..'
                                              : familyItem.date!),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF000047),
                                      ),
                                    ),
                                    Text(
                                      " العطية : ".tr +
                                          // familyItem.give!,
                                          (familyItem.give!.length > 30
                                              ? '${familyItem.give!.substring(0, 30)}..'
                                              : familyItem.give!),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF000047),
                                      ),
                                    ),
                                    Text(
                                      "  اسم المعطي :  ".tr +
                                          // familyItem.giverName!,
                                          (familyItem.giverName!.length > 30
                                              ? '${familyItem.giverName!.substring(0, 30)}..'
                                              : familyItem.giverName!),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF000047),
                                      ),
                                    ),
                                    Text(
                                      familyItem.date! + ": بتاريخ ".tr,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF000047),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )

                      : Padding(
                        padding: const EdgeInsets.only(top: 158.0),
                        child: Container(
                                          height: 250,
                            child: Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/zero.jpg',
                                    height: 140,
                                    width: 140,
                                  ),
                                  Text(
                                  "لم تتم اضافه اي بيانات حتي الان ".tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF000047),
                                  ),
                                                        ),
                                ],
                              ),
                            )),
                      ),
                  ///////////////////////// design bsssssssssssssssss
                  ///UUUUUUU
                  SizedBox(height: 55),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 85.0),
          child: Container(
            height: 49,
            width: 49,
            child: FloatingActionButton(
              onPressed: () {
                print("docIddocId$docId");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddFamilyData("",docId!)),
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
        ),
      ),
    );
  }
  Future<void> deleteCancelByPhoneAndPlaygroundId(String docId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('PeopleData').doc(docId).delete(); // Delete the document

      print("Document with ID $docId deleted successfully.");
    } catch (e) {
      print('Error deleting document: $e');
    }
  }


}
