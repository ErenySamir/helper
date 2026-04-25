import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helper/HomePage/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ButtomNavigation/CustomButtomNavigation/ButtomNavigation.dart';

class CardsPage extends StatelessWidget {

  final TextEditingController cardController = TextEditingController();

  Future<void> addCard(BuildContext context) async {

    var cardsRef = FirebaseFirestore.instance.collection("Cards");
    SharedPreferences prefs = await SharedPreferences.getInstance();
   String? uid = prefs.getString('docIid');
    print(" prefs.getString('docIid')${ prefs.getString('docIid')}");
    var existingCards = await cardsRef
        .where("AdminId", isEqualTo: uid)
        .get();

    bool isFirst = existingCards.docs.isEmpty;

    await cardsRef.add({
      "name": cardController.text,
      "AdminId": uid,
      "familyId":'',
      "isFirstCard": isFirst
    });

    cardController.clear();
    Navigator.pop(context);
  }

  void showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // removes margins
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("إضافة بطاقة جديدة"),
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: cardController,
                    decoration: InputDecoration(
                      hintText: "ادخل إسم البطاقه",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => addCard(context),
                    child: Text("إضافة"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Future<void> deleteCard(String id) async {
    await FirebaseFirestore.instance
        .collection("Cards")
        .doc(id)
        .delete();
  }
  Future<void> updateCard(String id, String newName) async {

    await FirebaseFirestore.instance
        .collection("Cards")
        .doc(id)
        .update({
      "name": newName,
    });
  }
  @override
  Widget build(BuildContext context) {

    void editCard(String id, String oldName) {

      TextEditingController controller =
      TextEditingController(text: oldName);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("تعديل البطاقة"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "إسم البطاقة",
              ),
            ),
            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("إلغاء"),
              ),

              ElevatedButton(
                onPressed: () async {

                  await updateCard(id, controller.text);

                  Navigator.pop(context);
                },
                child: Text("تعديل"),
              ),
            ],
          );
        },
      );
    }

    String? uid = FirebaseAuth.instance.currentUser?.uid;
print("uid$uid");
    return Scaffold(
      appBar: AppBar(title: Text("بطاقات الاعضاء")),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 49,
            width: 49,
            child: FloatingActionButton(
                onPressed: ()=>showAddDialog(context),
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
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Cards")
            .where("AdminId", isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot){

          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }

          var cards = snapshot.data!.docs;

          if(cards.isEmpty){
            return Center(child: Text("لا توجد بطاقات "));
          }

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              // Sort cards to put isFirstCard at the top
              List<QueryDocumentSnapshot> sortedCards = List.from(cards);
              sortedCards.sort((a, b) {
                bool aIsFirst = (a.data() as Map<String, dynamic>)['isFirstCard'] ?? false;
                bool bIsFirst = (b.data() as Map<String, dynamic>)['isFirstCard'] ?? false;

                // Put isFirstCard = true at the top
                if (aIsFirst && !bIsFirst) return -1;
                if (!aIsFirst && bIsFirst) return 1;
                return 0;
              });

              var data = sortedCards[index];

              return GestureDetector(
                onTap: () {
                  print("data.id${data.id}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        cardId: data.id!,
                      ),
                    ),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(data["name"]),
                    trailing: data["isFirstCard"] == true
                        ? null
                        : PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "edit",
                          child: Text("تعديل"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("حذف"),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == "edit") {
                          editCard(data.id, data["name"]);
                        } else {
                          deleteCard(data.id);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}