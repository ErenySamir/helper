class FamilyModel {
  // Assuming these are the properties of your User class
  String? familyPhone;
  String? familyName;
  String? date;
  String? AdminID;
  String? familyNum;
  String? give;
  String? giverName;
  // List<String>? TeamMembers = [];

  // Constructor
  FamilyModel({this.familyName, this.familyNum,this.familyPhone,this.AdminID,this.date,this.give,this.giverName});

  // fromMap method to create a User object from a Map
  factory FamilyModel.fromMap(Map<String, dynamic> map) {
    return FamilyModel(
      familyName: map['familyName'],
      familyNum: map['familyNum'],
      familyPhone:map['familyPhone'],
      AdminID:map['AdminId'],
        giverName: map['giverName'],
      give: map['give'],
      date: map['date']
      // TeamMembers: (map['TeamMembers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }


  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
     'familyName' :familyName,
       'familyNum': familyNum,
      'familyPhone' :familyPhone,
      'AdminId' :AdminID,
      'giverName': giverName,
       'give':give,
      'date':date
      // 'TeamMembers': TeamMembers,
    };
  }

  // toString method to print the User object
  @override
  String toString() {
    return 'FamilyModel(familyName: $familyName, name: $familyNum, familyPhone: $familyPhone,AdminId: $AdminID )';
  }
}