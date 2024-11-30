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
TextEditingController _nameController = TextEditingController();
TextEditingController _dateController = TextEditingController();
TextEditingController _giveController = TextEditingController();
TextEditingController _giverNameController = TextEditingController();
TextEditingController _phoneController = TextEditingController();
TextEditingController _familyNumController = TextEditingController();
bool isLoading = false;


class AddFamilyDataState extends State<AddFamilyData>{


  Future<void> _sendData(BuildContext context) async {
    // Retrieve input values from controllers
    final name = _nameController.text;
    final phoneNumber = _phoneController.text;
    final givetype = _giveController.text;
    final familyNum = _familyNumController.text;
    final date = _dateController.text;
    final giverName = _giverNameController.text;

    // Validate required fields
    if (name.isNotEmpty && phoneNumber.isNotEmpty  && givetype.isNotEmpty && familyNum.isNotEmpty && date.isNotEmpty && giverName.isNotEmpty) {
      try {
        // Get the phone number from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('phonecomunication', phoneNumber);
        String phone = prefs.getString('phone') ?? '';
        String docId = '';

        // Query Firestore for the document ID associated with the phone number
        CollectionReference playerChat = FirebaseFirestore.instance.collection('PersonData');
        QuerySnapshot playerQuerySnapshot = await playerChat.where('phone', isEqualTo: phone).get();

        // Retrieve docId if a document exists
        if (playerQuerySnapshot.docs.isNotEmpty) {
          docId = playerQuerySnapshot.docs.first.id; // Get the document ID
          print("Document ID in add: $docId");
        } else {
          print("No document found for phone: $phone");
        }

        // Create a playground model object
        final FamilyModeldata = FamilyModel(
            familyName:name,
            familyNum:familyNum,
            familyPhone:phoneNumber,
            giverName: giverName,
            give: givetype,
            date:date,
          AdminID: docId,
        );

        // Check if widget.docId exists for updating
        if (widget.docId.isNotEmpty) {
          // Fetch the existing document
          DocumentSnapshot existingDoc = await FirebaseFirestore.instance
              .collection('PeopleData')
              .doc(widget.docId)
              .get();

          // Check if there are changes
          final existingData = existingDoc.data() as Map<String, dynamic>;
          Map<String, dynamic> updates = {};

          // Compare fields and prepare updates
          if (existingData['familyName'] != FamilyModeldata.familyName) {
            updates['familyName'] = FamilyModeldata.familyName;
          }
          if (existingData['familyNum'] != FamilyModeldata.familyNum) {
            updates['familyNum'] = FamilyModeldata.familyNum;
          }
          if (existingData['familyPhone'] != FamilyModeldata.familyPhone) {
            updates['familyPhone'] = FamilyModeldata.familyPhone;
          }
          if (existingData['giverName'] != FamilyModeldata.giverName) {
            updates['giverName'] = FamilyModeldata.giverName;
          }
          if (existingData['give'] != FamilyModeldata.give) {
            updates['give'] = FamilyModeldata.give;
          }
          if (existingData['date'] != FamilyModeldata.date) {
            updates['date'] = FamilyModeldata.date;
          }

          // Update only if there are changes
          if (updates.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('PeopleData')
                .doc(widget.docId)
                .set(updates, SetOptions(merge: true));
            print("Document updated with ID: ${widget.docId}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تعديل البيانات بنجاح', // "Data updated successfully"
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Color(0xFF000047),
              ),
            );
          } else {
            print("No changes detected, skipping update.");
          }
        } else {
          // Add a new playground to Firestore and get the document reference
          DocumentReference docRef = await FirebaseFirestore.instance.collection('PeopleData').add(FamilyModeldata.toMap());
          print("New document added with ID: ${docRef.id}");
          prefs.setString('docIId', docRef.id);

          // Show success message for new data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم تسجيل البيانات بنجاح', // "Data registered successfully"
                textAlign: TextAlign.center,
              ),
              backgroundColor: Color(0xFF000047),
            ),
          );
        }

        // Clear controllers (if needed)
        // Uncomment to clear controllers
        // PlaygroundNameController.clear();
        // phoneController.clear();
        // AddressController.clear();
        // len.clear();
        // weidth.clear();
        // selectedPlayType = null;
        // LocationController.clear();
        // selectedImages.clear();
        // _cnt.clearDropDown();
        _nameController.clear();
        _phoneController.clear();
        _familyNumController.clear();
        _giverNameController.clear();
        _giveController.clear();
        _dateController.clear();
        _nameController.clear();

      } catch (e) {
        // Handle any errors
        print('Error adding/updating data to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر ارسال البيانات', // "Failed to send data"
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF000047),
          ),
        );
      }
    } else {
      // Show error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب حدث به خطا', // "There was an error with this account"
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF000047),
        ),
      );
    }
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
                      controller: _nameController,
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
        _dateController.text = formattedDate;
        }
        },
        child: AbsorbPointer( // Prevent keyboard from showing up
        child: TextField(
        controller: _dateController,
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
                      controller: _giveController,
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
                      controller: _giverNameController,
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
                      controller: _phoneController,
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
                      controller: _familyNumController,
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
                if (_nameController.text.isEmpty
                // ||
                    // _phoneController.text.isNotEmpty ||
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
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