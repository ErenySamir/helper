import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helper/AddFamilyData/Model/FamilyModel.dart';
import 'package:helper/HomePage/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFamilyData extends StatefulWidget{
  String docId;
  AddFamilyData({required this.docId});
  @override
  State<AddFamilyData> createState() {
    return AddFamilyDataState();
  }
}
TextEditingController nameController = TextEditingController();
TextEditingController dateController = TextEditingController();
TextEditingController giveController = TextEditingController();
TextEditingController giverNameController = TextEditingController();
TextEditingController phoneControlller = TextEditingController();
TextEditingController familyNumController = TextEditingController();
bool isLoading = false;


class AddFamilyDataState extends State<AddFamilyData>{

  Future<void> _sendData(BuildContext context) async {
    final name = nameController.text.trim();
    final phoneNumber = phoneControlller.text.trim();
    final give = giveController.text.trim();
    final giver = giverNameController.text.trim();
    final date = dateController.text.trim();
    final num = familyNumController.text.trim();

    String docId = '';

    // Retrieve Admin ID from Firestore
    CollectionReference playerChat = FirebaseFirestore.instance.collection('PeopleData');
    QuerySnapshot playerQuerySnapshot = await playerChat.get();
    if (playerQuerySnapshot.docs.isNotEmpty) {
      docId = playerQuerySnapshot.docs.first.id;
      print("Admin ID retrieved: $docId");
    } else {
      print("No Admin ID found for phone: ");
    }

    // Create a playground model object
    final FamilyModel familyModel = FamilyModel(
      familyName: nameController.text,
      familyNum: int.tryParse(familyNumController.text), // Convert to int
      familyPhone: phoneControlller.text,
      giverName: giverNameController.text,
      give: giveController.text,
      date: dateController.text,
      AdminID: docId,
    );

    if (widget.docId.isNotEmpty) {
      // Update existing document
      DocumentSnapshot existingDoc = await FirebaseFirestore.instance
          .collection('PeopleData')
          .doc(widget.docId)
          .get();
      final existingData = existingDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> updates = {};

      // Compare and update only changed fields
      void compareAndUpdate(String field, dynamic newValue, dynamic oldValue) {
        if (newValue != null && newValue != oldValue) {
          updates[field] = newValue;
        }
      }

      compareAndUpdate('familyName', name.isNotEmpty ? name : existingData['familyName'], existingData['familyName']);
      compareAndUpdate('familyPhone',phoneNumber.isNotEmpty ? phoneNumber : existingData['familyPhone'], existingData['familyPhone'] );
      compareAndUpdate('familyNum', num.isNotEmpty ? num : existingData['familyNum'], existingData['familyNum']);
      compareAndUpdate('giverName', giver.isNotEmpty ? giver : existingData['giverName'], existingData['giverName']);
      compareAndUpdate('give', give.isNotEmpty ? give : existingData['give'], existingData['give']);
      compareAndUpdate('date', date.isNotEmpty ? date : existingData['date'], existingData['date']);


      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('PeopleData')
            .doc(widget.docId)
            .set(updates, SetOptions(merge: true));
        print("Document updated: ${widget.docId}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعديل البيانات بنجاح', textAlign: TextAlign.center),
            backgroundColor: Colors.blue.shade900,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(),
        ));

        setState(() {
          isLoading=false;

        });
      } else {
        isLoading=false;
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ConfirmInformationPlayGround(docid: widget.docId)),
        // );
        print("No changes detected; skipping update.");
      }
    } else {
      // Add new document
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('PeopleData')
          .add(familyModel.toMap());
      print("New document added with ID: ${docRef.id}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تسجيل البيانات بنجاح', textAlign: TextAlign.center),
          backgroundColor: Colors.blue.shade900,
        ),
      );
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(),
    ));
    }
  }


  late List<FamilyModel> PeopleData = [];

  Future<void> getPeopleData(String iiid) async {
    // try {
      CollectionReference peopleData = FirebaseFirestore.instance.collection("PeopleData");
      QuerySnapshot querySnapshot = await peopleData.get();
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          FamilyModel user = FamilyModel.fromMap(userData);
          if (document.id == widget.docId) {
            PeopleData.add(user);
            if (PeopleData.isNotEmpty) {
              nameController.text = PeopleData[0].familyName!;
              familyNumController.text = PeopleData[0].familyNum!.toString();
              giveController.text = PeopleData[0].give!;
              giverNameController.text = PeopleData[0].giverName!;
              dateController.text =PeopleData[0].date!;
              phoneControlller.text = PeopleData[0].familyPhone!;
                }

            setState(() {

            });

          }
          user.Id = document.id;
        }

      }
    // } catch (e) {
    //   print("Error getting playground: $e");
    // }
  }

  @override
  void initState() {
getPeopleData(widget.docId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0,bottom: 12,right: 8,left: 8), // Add padding to the top of the title
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "اضافة بيانات",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true, // Center the title horizontally
            leading: IconButton(
              onPressed: () {
                // Get.off(HomePage());
                Navigator.of(context).pop();
                // Navigator.of(context).pop(true); // Navigate back to the previous page
              },
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios_new_rounded,
                size: 24,
                color:  Color(0xFF62748E),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              //Name
              Text("الاسم",
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)
                ),),
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
                        controller: nameController,
                        cursorColor:  Color(0xFF000047),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          hintText: 'الأسم',
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
              if (nameController.text.length >0 && nameController.text.length <2)
                Text(
                  // textAlign: TextAlign.end,
                  "برجاء ادخال الاسم",
                  style: TextStyle(
                    color: Colors.red.shade900, // Error message color
                    fontSize: 12.0,
                    fontFamily: 'Cairo',
                  ),
                ),
              //Date
              Text("التاريخ",
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)
                ),),
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
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), // Default date
                            firstDate: DateTime(2000),  // Earliest date
                            lastDate: DateTime(2100),  // Latest date
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Color(0xFF000047), // Header background color
                                    onPrimary: Colors.white,   // Header text color
                                    onSurface: Color(0xFF000047), // Body text color
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF000047), // Button text color
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (selectedDate != null) {
                            // Format the date and set it to the controller
                            String formattedDate =
                                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                            dateController.text = formattedDate;
                          }
                        },
                        child: AbsorbPointer( // Prevent keyboard from showing up
                          child: TextField(
                            controller: dateController,
                            cursorColor: Color(0xFF000047),
                            textAlign: TextAlign.right, // Align text to the right
                            decoration: InputDecoration(
                              hintText: 'التاريخ',
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(
                        Icons.calendar_today, // Use a calendar icon
                        size: 22,
                        color: Color(0xFF000047),
                      ),
                    ),
                  ],
                ),
              ),

              //give typeeeeeeeeee
              Text("العطية",
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)
                ),),
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
                        controller: giveController,
                        cursorColor:  Color(0xFF000047),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          hintText: 'العطية',
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
                        Icons.monetization_on,
                        size: 22,
                        color:  Color(0xFF000047),
                      ),

                    ),
                  ],
                ),
              ),
              //giverrrrrrrrrrrrname
              Text("اسم المعطي العطية",
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)
                ),),
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
                        controller: giverNameController,
                        cursorColor:  Color(0xFF000047),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          hintText: 'اسم المعطي العطية',
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
              //phoneeeeeeeefamily
              Text("تليفون العائلة",
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)
                ),),
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
                        controller: phoneControlller,
                        cursorColor:  Color(0xFF000047),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.datetime,
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          hintText: "تليفون العائلة",
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: Color(0xFF495A71),
                          ),
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(11),
                        ],
                        onEditingComplete: () async {
                          // Move focus to the next text field
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(
                        Icons.phone,
                        size: 22,
                        color:  Color(0xFF000047),
                      ),

                    ),
                  ],
                ),
              ),
              //familyNuuuuuuum
              Text("عدد افراد العائلة",
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)
                ),),
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
                          controller: familyNumController,
                          cursorColor:  Color(0xFF000047),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.datetime,
                          textAlign: TextAlign.right, // Align text to the right
                          decoration: InputDecoration(
                            hintText: 'عدد افراد العائلة',
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

                    ]),
              ),
              GestureDetector(
                onTap: () async {
                  // Check if any of the required fields are empty
                  if (nameController.text.isEmpty
                  // ||
                  // _phoneControlller.text.isNotEmpty ||
                  // // _dateController.text.isEmpty ||
                  // _familyNumController.text.isEmpty ||
                  // _giveController.text.isNotEmpty || _giverNameController.text.isNotEmpty
                  ) {
                    // Show a SnackBar with the error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'برجاء ادخال جميع البيانات', // "Please enter all the data"
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Color(0xFF000047),
                      ),
                    );
                    isLoading = false;
                  } else {
                    // Show the loading indicator
                    setState(() {
                      isLoading = true;
                    });

                    // If validation passes, send data to Firebase
                    try {
                      await _sendData(context); // Ensure this function is async and handles Firebase operations
                      // After successful data sending, navigate to the ConfirmInformationPlayGround screen

                    } catch (e) {
                      // Show an error SnackBar if data sending fails
                      print("errrrrrrrrrrrrrrrrrrror$e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'حدث خطأ أثناء إرسال البيانات. حاول مرة أخرى.', // "An error occurred while sending data. Please try again."
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      // Hide the loading indicator in both success and error cases
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0,right:6 , bottom: 30),
                  child: Container(
                    height: 50,
                    // width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      shape: BoxShape.rectangle,
                      color: Color(0xFF000047), // Background color of the container
                    ),
                    child: Center(
                      child: Text(
                        'حفظ',
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