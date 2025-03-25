class UserModel{
  final String uid;
  final String email;
  final String? name;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
  });

  //firebase -> UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      name: data['name'],
    );
  }

  //object -> Map<> save to firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }
}