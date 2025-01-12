class FamilyModel {
  // Assuming these are the properties of your User class
  String? familyPhone;
  String? familyName;
  String? date;
  String? AdminID;
  int? familyNum;
  String? give;
  String? giverName;
String? Id;
  // List<String>? TeamMembers = [];

  // Constructor
  FamilyModel({this.familyName,this.Id, this.familyNum,this.familyPhone,this.AdminID,this.date,this.give,this.giverName});

  // fromMap method to create a User object from a Map
  factory FamilyModel.fromMap(Map<String, dynamic> map) {
    return FamilyModel(
      familyName: map['familyName'],
        familyNum: map['familyNum'] is String
            ? int.tryParse(map['familyNum']) // Convert if it's a string
            : map['familyNum'] as int?, // Keep as is if it's already an int
        //      familyPhone:map['familyPhone'],
      AdminID:'',
        giverName: map['giverName'],
      give: map['give'],
      date: map['date'],
      familyPhone: map['familyPhone'],
      Id: ''
      // TeamMembers: (map['TeamMembers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }


  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
     'familyName' :familyName,
       'familyNum': familyNum,
      'familyPhone' :familyPhone,
      'AdminId' :'',

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