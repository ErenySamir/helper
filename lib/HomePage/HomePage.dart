import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helper/AddFamilyData/AddFamilyData.dart';
import 'package:helper/AddFamilyData/Model/FamilyModel.dart';
import 'package:helper/Profile/ProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                  padding: EdgeInsets.only( right: 12, top: 66),
                  child: Text(
                    "  مرحبا بك  ",
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 14.0, right: 12, top: 10),
                  child: GestureDetector(
                    onTap:(){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profilepage(docId: userDataa[0].phoneNumber!,),
                        ),
                      );
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // SizedBox(width: 8,),
                          Icon(Icons.person_rounded,color: Color(0xFF000047),),
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

                        ]),
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
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      confirmDismiss: (direction) async {
                        // Show confirmation dialog before deleting
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("تأكيد الحذف"),
                            content: Text("هل أنت متأكد أنك تريد حذف هذه العائلة؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("إلغاء"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  print("familyItem.Id!${familyItem.Id!}");
                                  await deleteCancelByPhoneAndPlaygroundId(familyItem.Id!);
                                  Navigator.of(context).pop(true);
                                  },
                                child: Text("حذف", style: TextStyle(color: Colors.red)),
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
                          SnackBar(content: Text("تم حذف العائلة بنجاح"), backgroundColor:  Color(0xFF000047),),
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
                                builder: (context) => AddFamilyData(familyItem.Id!),
                              ),
                            );
                          },
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Color(0xFFF0F6FF),
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
                                        "   اسم العائلة :  " + familyItem.familyName!,
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
                                    " تاريخ العطية : " + familyItem.date!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF000047),
                                    ),
                                  ),
                                  Text(
                                    " العطية : " + familyItem.give!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF000047),
                                    ),
                                  ),
                                  Text(
                                    "  اسم المعطي :  " + familyItem.giverName!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF000047),
                                    ),
                                  ),
                                  Text(
                                    familyItem.date! + ": بتاريخ ",
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

                    : Container(
                        child: Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/zero.jpg',
                                height: 140,
                                width: 140,
                              ),
                              Text(
                              "لم تتم اضافه اي بيانات حتي الان ",
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
                  builder: (context) => AddFamilyData("")),
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
