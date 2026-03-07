import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper/HomePage/HomePage.dart';
import 'package:helper/Profile/EditProfile/EditProfile.dart';
import 'package:helper/Profile/ProfilePage.dart';
import 'package:helper/Setting/SettingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Cards/Home_Cards.dart';
import '../../Loading/Loading.dart';
import '../../Register/Model/UserModel.dart';
import '../../Register/SignIn.dart';

class CustomNavigationBar extends StatefulWidget {
  final int current;

  CustomNavigationBar({Key? key, required this.current}) : super(key: key);

  @override
  State<CustomNavigationBar> createState() => _CustomBottomBarTwoState();
}

class _CustomBottomBarTwoState extends State<CustomNavigationBar> {
  int currentIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<UserData> userDataa = [];
  late List<Widget> pages; // Declare the list // nullable instead of late

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.current;
    pages = [
      HomePage(),//0
      Profilepage(docId: userDataa.isNotEmpty ? userDataa[0].phoneNumber! : ''),//1
      // SettingPage(),//3
    CardsPage()

    ];
    _initializeState();
  }

  Future<void> _initializeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    if (phoneValue != null) {
      await getUserByPhone(phoneValue);
    }
    setState(() {
      pages = [
        HomePage(),//0
        Profilepage(docId: userDataa.isNotEmpty ? userDataa[0].phoneNumber! : ''),//1
        EditProfilepage(docId: userDataa.isNotEmpty ? userDataa[0].phoneNumber! : ''),//2
        // SettingPage(),//3
        CardsPage()
      ];
      // isLoading = false;
    });
  }

  Future<void> getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');
      CollectionReference playerchat = FirebaseFirestore.instance.collection('PersonData');

      QuerySnapshot querySnapshot = await playerchat
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        UserData user = UserData.fromMap(userData);
        userDataa.add(user);
      } else {
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
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: PageStorage(
        bucket: bucket,
        child: pages[currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 76,
      margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(55)),
        child: BottomAppBar(
          shadowColor: Color(0xffACB0B9),
          elevation: 10,
          padding: const EdgeInsets.symmetric(vertical: 4),
          height: 60,
          color: const Color(0xFF000047),
          shape: const AutomaticNotchedShape(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(38.5),
                topRight: Radius.circular(38.5),
              ),
            ),
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
          notchMargin: 7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Opacity(opacity: .1),

              _buildBottomNavItem(3, Icons.settings, "".tr),

              _buildBottomNavItem(1, Icons.person, "".tr), _buildBottomNavItem(0, Icons.home, "".tr),
              const SizedBox(width: .1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData iconData, String label) {
    return MaterialButton(
      minWidth: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      onPressed: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 25, color: Colors.white),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
