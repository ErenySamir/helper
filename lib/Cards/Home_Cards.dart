import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardsPage extends StatelessWidget {

  final TextEditingController cardController = TextEditingController();

  Future<void> addCard(BuildContext context) async {

    // String? uid = FirebaseAuth.instance.currentUser?.uid;

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
            appBar: AppBar(
              title: Text("Create Card"),
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
                      hintText: "Enter card name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => addCard(context),
                    child: Text("Add Card"),
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
  Future<void> editCard(String id, String newName) async {
    await FirebaseFirestore.instance
        .collection("Cards")
        .doc(id)
        .update({
      "name": newName
    });
  }
  @override
  Widget build(BuildContext context) {

    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text("My Cards")),

      floatingActionButton: Align(
        alignment: Alignment.bottomRight, // Forces right alignment

        child: FloatingActionButton(
          onPressed: ()=>showAddDialog(context),
          child: Icon(Icons.add),
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
            return Center(child: Text("No Cards Yet"));
          }

          return ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context,index){

                var data = cards[index];

                return Card(
                  child: ListTile(
                    title: Text(data["name"]),
                    trailing: data["isFirstCard"] == true
                        ? null
                        : PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "edit",
                          child: Text("Edit"),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Text("Delete"),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == "edit") {
                          editCard(data.id,value);
                        } else {
                          deleteCard(data.id);
                        }
                      },
                    ),
                  ),
                );

              });
        },
      ),
    );
  }
}