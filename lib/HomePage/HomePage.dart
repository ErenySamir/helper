import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AddFamilyData/FamilyData.dart';
import '../AddFamilyData/Model/FamilyModel.dart';
import '../Cards/Auth Service.dart';
import '../Cards/Call Firestore.dart';
import '../Cards/Delete Family.dart';
import '../Cards/Family Card.dart';
import '../Cards/User Service.dart';
import '../Register/Model/UserModel.dart';
import '../Register/SignIn.dart';


class HomeScreen extends StatefulWidget {
  final String? cardId;
  final String? cardName; // Optional: to display the current card name
  const HomeScreen({
    Key? key,
    this.cardId,
    this.cardName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FamilyService _familyService = FamilyService();

  List<UserData> userDataList = [];
  List<FamilyDataModel> familyDataList = [];
  String? adminId;
  bool isLoading = true;
  String? currentCardName;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _loadCardDetails();
    _getSavedAdminId();
  }
  Future<void> _getSavedAdminId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString('adminid');
    String? docIid = prefs.getString('docIid');

    print("Saved admin ID: $adminId");
    print("Saved docIid: $docIid");

    if (adminId != null) {
      setState(() {
        this.adminId = adminId;
      });
    }
  }
  Future<void> _loadCardDetails() async {
    if (widget.cardId != null && widget.cardId!.isNotEmpty) {
      try {
        DocumentSnapshot cardDoc = await FirebaseFirestore.instance
            .collection("Cards")
            .doc(widget.cardId)
            .get();

        if (cardDoc.exists) {
          setState(() {
            currentCardName = cardDoc['name'];
          });
        }
      } catch (e) {
        print("Error loading card details: $e");
      }
    }
  }

  Future<void> _initializeState() async {
    setState(() => isLoading = true);

    adminId = _authService.getCurrentUserId();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');

    if (phoneValue != null) {
      await _loadUserData(phoneValue);
    }

      await _loadFamilyData();

  }

  Future<void> _loadUserData(String phoneNumber) async {
    UserData? user = await _userService.getUserByPhone(phoneNumber);
    if (user != null) {
      setState(() {
        userDataList = [user];
      });
    } else {
      // User not found, sign out
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  SigninPage()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _loadFamilyData() async {
    try {
      print(" widget.cardId widget.cardId${ widget.cardId}");
      // print(" widget.cardId widget.cardId${ cardId}");
      List<FamilyDataModel> data = await _familyService.getFamilyData(
        adminId: adminId!,
        cardId: widget.cardId!,
      );
      setState(() {
        familyDataList = data;
      });
    } catch (e) {
      print("Error loading family data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ في تحميل البيانات".tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteFamilyItem(int index, String docId) async {
    try {
      await _familyService.deleteFamilyData(docId);
      setState(() {
        familyDataList.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم حذف العائلة بنجاح".tr),
            backgroundColor: const Color(0xFF000047),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء الحذف".tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCardSelectionDialog(String familyId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("اختر البطاقة".tr),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Cards")
                  .where("AdminId", isEqualTo: adminId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var cards = snapshot.data!.docs;

                if (cards.isEmpty) {
                  return Center(
                    child: Text("لا توجد بطاقات متاحة".tr),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    var card = cards[index];
                    bool isCurrentCard = card.id == widget.cardId;

                    return ListTile(
                      leading: isCurrentCard
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      title: Text(card["name"]),
                      subtitle: isCurrentCard
                          ? Text("البطاقة الحالية".tr)
                          : null,
                      onTap: () async {
                        await _familyService.addFamilyToCard(
                          familyId,
                          card.id,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("تم نقل العائلة إلى ${card['name']}".tr),
                              backgroundColor: const Color(0xFF000047),
                            ),
                          );
                          // Refresh the list if needed
                          await _loadFamilyData();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إلغاء".tr),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to cards page instead of exiting
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: _buildBody(),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF000047)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            currentCardName ?? "",
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000047),
            ),
          ),
          if (widget.cardId != null)
            Text(
              "بطاقة: ${currentCardName ?? ''}".tr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (widget.cardId == null || widget.cardId!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "الرجاء اختيار بطاقة أولاً".tr,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),

          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFamilyData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildHeader(),
            if (familyDataList != null && familyDataList.isNotEmpty)
              _buildFamilyList()
            else
              _buildEmptyState(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 16, left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "  مرحبا بك/  ".tr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000047),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0, right: 16, top: 10, left: 15),
            child: userDataList.isNotEmpty && userDataList[0].name != null && userDataList[0].name!.isNotEmpty
                ? Text(
              userDataList[0].name!.length > 30
                  ? '${userDataList[0].name!.substring(0, 30)}..'
                  : userDataList[0].name!,
              style: const TextStyle(
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

        ],
      ),
    );
  }

  Widget _buildFamilyList() {
    return ListView.builder(
      itemCount: familyDataList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final familyItem = familyDataList[index];

        return Dismissible(
          key: ValueKey(familyItem.Id),
          direction: DismissDirection.endToStart,
          background: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white, size: 20),
            ),
          ),
          confirmDismiss: (direction) async {
            return await DeleteConfirmationDialog.show(context);
          },
          onDismissed: (direction) async {
            await _deleteFamilyItem(index, familyItem.Id!);
          },
          child: FamilyCard(
            familyItem: familyItem,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFamilyDataScreen(
                    docId: familyItem.Id!,
                    adminId: adminId!,
                    cardId: widget.cardId!,
                  ),
                ),
              ).then((_) => _loadFamilyData()); // Refresh when returning
            },
            onAddCard: () {
              _showCardSelectionDialog(familyItem.Id!);
            },
            onDelete: () async {
              await _deleteFamilyItem(index, familyItem.Id!);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
      ));
  }

  Widget _buildFloatingActionButton() {
    if (widget.cardId == null || widget.cardId!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.0,
        right: 20.0,
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddFamilyDataScreen(
                  adminId: adminId!,
                  docId: '',
                  cardId: widget.cardId!,
                ),
              ),
            ).then((_) => _loadFamilyData());
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 26,
          ),
          backgroundColor: const Color(0xFF000047),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}