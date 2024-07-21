class UserModel {
  // this the information of the user
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

  // this is my default constructor
  UserModel({this.uid, this.fullname, this.email, this.profilepic});

  // from map constructor

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
  }
// this is to map which have return type string
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
    };
  }
}
