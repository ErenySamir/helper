import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper/Profile/EditProfile/EditProfile.dart';
import 'package:helper/Profile/ProfilePage.dart';
import 'package:helper/Cards/Home_Cards.dart';
import 'package:helper/AddFamilyData/FamilyData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../HomePage/HomePage.dart';
import '../../Register/Model/UserModel.dart';
import '../../Register/SignIn.dart';

class CustomNavigationBar extends StatefulWidget {
  final int current;
  final String? cardId; // Optional card ID to filter HomePage

  const CustomNavigationBar({
    Key? key,
    required this.current,
    this.cardId,
  }) : super(key: key);

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int currentIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<UserData> userDataa = [];
  late List<Widget> pages;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Set initial index to 0 (Cards page)
    currentIndex = widget.current;

    // Initialize with placeholder pages
    pages = [
      const Center(child: CircularProgressIndicator()), // Temporary placeholder
      const Center(child: CircularProgressIndicator()), // Temporary placeholder
      const Center(child: CircularProgressIndicator()), // Temporary placeholder
    ];

    _initializeState();
  }

  Future<void> _initializeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');

    if (phoneValue != null) {
      await _getUserByPhone(phoneValue);
    }

    String docId = userDataa.isNotEmpty ? userDataa[0].phoneNumber! : '';

    setState(() {
      pages = [
        // Page 0: Cards/Home Page (first page)
        CardsPage(),
        // Page 1: Profile Page
        Profilepage(docId: docId),
        // Page 2: Edit Profile Page
        EditProfilepage(docId: docId),

      ];
      isLoading = false;
    });
  }

  Future<void> _getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhone = phoneNumber.replaceFirst('+20', '0');
      CollectionReference usersRef =
      FirebaseFirestore.instance.collection('PersonData');

      QuerySnapshot querySnapshot =
      await usersRef.where('phone', isEqualTo: normalizedPhone).get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userMap =
        querySnapshot.docs.first.data() as Map<String, dynamic>;
        UserData user = UserData.fromMap(userMap);
        userDataa.add(user);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>  SigninPage()),
                (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print("Error getting user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: PageStorage(
        bucket: bucket,
        child: pages[currentIndex],
      ),
      bottomNavigationBar: _buildFacebookStyleBottomNavBar(),
    );
  }

  // Facebook-style bottom navigation bar
  Widget _buildFacebookStyleBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFacebookNavItem(
                index: 0,
                icon: Icons.home_filled,
                label: "الرئيسية".tr,
                selectedIcon: Icons.home_filled,
              ),
              _buildFacebookNavItem(
                index: 1,
                icon: Icons.person_outline,
                label: "الملف الشخصي".tr,
                selectedIcon: Icons.person,
              ),
              _buildFacebookNavItem(
                index: 2,
                icon: Icons.edit_outlined,
                label: "تعديل الملف".tr,
                selectedIcon: Icons.edit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacebookNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? const Color(0xFF000047) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF000047) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}