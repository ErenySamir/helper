class UserData {
  // Assuming these are the properties of your User class
  String? phoneNumber;
  String? name;
  String? confirmpass;
  String ? password;


  // Constructor
  UserData({this.phoneNumber, this.name, this.confirmpass,this.password});

  // fromMap method to create a User object from a Map
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
        phoneNumber: map['phone'],
        name: map['name'],
        confirmpass: map['confirmpass'],
        password : map['password'],

    );
  }

  // toString method to print the User object
  @override
  String toString() {
    return 'User(phoneNumber: $phoneNumber, name: $name, confirmpass: $confirmpass,password$password)';
  }
}