class FamilyDataModel {
  String? Id;
  String cardId;
  String adminId;
  String give;
  String giverName;
  String date;
  String fatherName;
  String fatherPhone;
  String fatherJob;
  String fatherNationalId;
  String fatherEducation;
  String fatherImage;
  String motherName;
  String motherPhone;
  String motherJob;
  String motherNationalId;
  String motherEducation;
  String motherImage;
  List<Map<String, dynamic>> sons;

  FamilyDataModel({
    this.Id,
    required this.cardId,
    required this.adminId,
    required this.give,
    required this.giverName,
    required this.date,
    required this.fatherName,
    required this.fatherPhone,
    required this.fatherJob,
    required this.fatherNationalId,
    required this.fatherEducation,
    required this.fatherImage,
    required this.motherName,
    required this.motherPhone,
    required this.motherJob,
    required this.motherNationalId,
    required this.motherEducation,
    required this.motherImage,
    required this.sons,
  });

  // Factory constructor to create FamilyDataModel from Firestore document
  factory FamilyDataModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final father = map['father'] as Map<String, dynamic>? ?? {};
    final mother = map['mother'] as Map<String, dynamic>? ?? {};

    return FamilyDataModel(
      Id: docId,
      cardId: map['CardId'] ?? '',
      adminId: map['AdminID'] ?? '',
      give: map['give'] ?? '',
      giverName: map['giverName'] ?? '',
      date: map['date'] ?? '',
      fatherName: father['name'] ?? '',
      fatherPhone: father['phone'] ?? '',
      fatherJob: father['job'] ?? '',
      fatherNationalId: father['nationalId'] ?? '',
      fatherEducation: father['education'] ?? '',
      fatherImage: father['image'] ?? '',
      motherName: mother['name'] ?? '',
      motherPhone: mother['phone'] ?? '',
      motherJob: mother['job'] ?? '',
      motherNationalId: mother['nationalId'] ?? '',
      motherEducation: mother['education'] ?? '',
      motherImage: mother['image'] ?? '',
      sons: List<Map<String, dynamic>>.from(map['sons'] ?? []),
    );
  }

  // Convert FamilyDataModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'CardId': cardId,
      'give': give,
      'giverName': giverName,
      'date': date,
      'AdminID': adminId,
      'father': {
        'name': fatherName,
        'phone': fatherPhone,
        'job': fatherJob,
        'nationalId': fatherNationalId,
        'education': fatherEducation,
        'image': fatherImage,
      },
      'mother': {
        'name': motherName,
        'phone': motherPhone,
        'job': motherJob,
        'nationalId': motherNationalId,
        'education': motherEducation,
        'image': motherImage,
      },
      'sons': sons,
    };
  }
}